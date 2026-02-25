const crypto = require('crypto');
const admin = require('firebase-admin');
const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');
const nodemailer = require('nodemailer');

admin.initializeApp();

const db = admin.firestore();
const OTP_FROM_EMAIL = defineSecret('OTP_FROM_EMAIL');
const OTP_GMAIL_APP_PASSWORD = defineSecret('OTP_GMAIL_APP_PASSWORD');
const OTP_COLLECTION = 'password_reset_otps';
const OTP_TTL_MS = 10 * 60 * 1000;
const TOKEN_TTL_MS = 10 * 60 * 1000;
const MAX_ATTEMPTS = 5;

function normalizeEmail(value) {
  return String(value || '').trim().toLowerCase();
}

function assertValidEmail(email) {
  if (!email || !/^\S+@\S+\.\S+$/.test(email)) {
    throw new HttpsError('invalid-argument', 'Please provide a valid email.');
  }
}

function normalizePhone(value) {
  return String(value || '').replace(/\D/g, '');
}

function phonesMatch(a, b) {
  const p1 = normalizePhone(a);
  const p2 = normalizePhone(b);
  if (!p1 || !p2) {
    return false;
  }
  if (p1 === p2) {
    return true;
  }
  return p1.endsWith(p2) || p2.endsWith(p1);
}

function buildOtpHash(otp, salt) {
  return crypto.createHash('sha256').update(`${otp}:${salt}`).digest('hex');
}

function randomDigits(length) {
  let out = '';
  while (out.length < length) {
    out += crypto.randomInt(0, 10).toString();
  }
  return out;
}

function randomToken() {
  return crypto.randomBytes(32).toString('hex');
}

function readSecret(secretParam) {
  try {
    return String(secretParam.value() || '').trim();
  } catch (error) {
    return '';
  }
}

async function sendOtpEmailWithGmail({fromEmail, appPassword, toEmail, otp}) {
  const normalizedPassword = String(appPassword || '').replace(/\s+/g, '');
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: fromEmail,
      pass: normalizedPassword,
    },
  });

  await transporter.sendMail({
    from: fromEmail,
    to: toEmail,
    subject: 'Your password reset OTP',
    text: `Your OTP is ${otp}. It expires in 10 minutes.`,
    html: `<p>Your OTP is <strong>${otp}</strong>.</p><p>It expires in 10 minutes.</p>`,
  });
}

function mapMailerErrorToMessage(error) {
  const code = String(error?.code || '').toUpperCase();
  const responseCode = Number(error?.responseCode || 0);
  const response = String(error?.response || '').toLowerCase();

  if (code === 'EAUTH' || responseCode === 535 || response.includes('badcredentials')) {
    return {
      code: 'failed-precondition',
      message: 'Email auth failed. Check OTP_FROM_EMAIL and OTP_GMAIL_APP_PASSWORD secrets.',
    };
  }
  if (code === 'EENVELOPE' || responseCode === 553) {
    return {
      code: 'failed-precondition',
      message: 'Sender email is invalid. Check OTP_FROM_EMAIL secret.',
    };
  }
  if (code === 'ETIMEDOUT' || code === 'ECONNECTION') {
    return {
      code: 'deadline-exceeded',
      message: 'Email service timeout. Please try again.',
    };
  }
  return {
    code: 'unknown',
    message: 'Failed to send OTP email.',
  };
}

exports.sendPasswordResetOtp = onCall(
  {secrets: [OTP_FROM_EMAIL, OTP_GMAIL_APP_PASSWORD]},
  async (request) => {
    const email = normalizeEmail(request.data?.email);
    assertValidEmail(email);

    let user;
    try {
      user = await admin.auth().getUserByEmail(email);
    } catch (error) {
      throw new HttpsError('not-found', 'No account found for this email.');
    }

    const otp = randomDigits(6);
    const salt = randomToken();
    const otpHash = buildOtpHash(otp, salt);
    const now = Date.now();

    await db.collection(OTP_COLLECTION).doc(user.uid).set({
      uid: user.uid,
      email,
      otpHash,
      salt,
      attempts: 0,
      verified: false,
      verificationTokenHash: null,
      otpExpiresAt: now + OTP_TTL_MS,
      verifiedAt: null,
      tokenExpiresAt: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const fromEmail = readSecret(OTP_FROM_EMAIL);
    const gmailAppPassword = readSecret(OTP_GMAIL_APP_PASSWORD);

    if (!fromEmail) {
      throw new HttpsError(
        'failed-precondition',
        'OTP_FROM_EMAIL is not configured on the server.'
      );
    }
    if (!/^\S+@\S+\.\S+$/.test(fromEmail)) {
      throw new HttpsError(
        'failed-precondition',
        'OTP_FROM_EMAIL is invalid. Set a valid Gmail address.'
      );
    }

    try {
      if (!gmailAppPassword) {
        throw new HttpsError(
          'failed-precondition',
          'OTP_GMAIL_APP_PASSWORD is not configured on the server.'
        );
      }
      await sendOtpEmailWithGmail({
        fromEmail,
        appPassword: gmailAppPassword,
        toEmail: email,
        otp,
      });
      return {success: true, message: 'OTP sent successfully.'};
    } catch (error) {
      const mapped = mapMailerErrorToMessage(error);
      console.error('sendPasswordResetOtp mail error', {
        message: error?.message,
        code: error?.code,
        responseCode: error?.responseCode,
      });
      throw new HttpsError(mapped.code, mapped.message);
    }
  }
);

exports.verifyPasswordResetOtp = onCall(async (request) => {
  const email = normalizeEmail(request.data?.email);
  const otp = String(request.data?.otp || '').trim();

  assertValidEmail(email);
  if (!/^\d{6}$/.test(otp)) {
    throw new HttpsError('invalid-argument', 'OTP must be exactly 6 digits.');
  }

  let user;
  try {
    user = await admin.auth().getUserByEmail(email);
  } catch (error) {
    throw new HttpsError('not-found', 'No account found for this email.');
  }

  const docRef = db.collection(OTP_COLLECTION).doc(user.uid);
  const snapshot = await docRef.get();

  if (!snapshot.exists) {
    throw new HttpsError('not-found', 'OTP not requested. Please request a new OTP.');
  }

  const data = snapshot.data();
  const now = Date.now();

  if (data.otpExpiresAt <= now) {
    await docRef.delete();
    throw new HttpsError('deadline-exceeded', 'OTP expired. Please request a new one.');
  }

  if (data.attempts >= MAX_ATTEMPTS) {
    throw new HttpsError('permission-denied', 'Too many invalid attempts. Request a new OTP.');
  }

  const candidateHash = buildOtpHash(otp, data.salt);
  if (candidateHash !== data.otpHash) {
    await docRef.update({
      attempts: admin.firestore.FieldValue.increment(1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    throw new HttpsError('invalid-argument', 'Invalid OTP.');
  }

  const verificationToken = randomToken();
  const verificationTokenHash = crypto
    .createHash('sha256')
    .update(verificationToken)
    .digest('hex');

  await docRef.update({
    verified: true,
    verificationTokenHash,
    verifiedAt: now,
    tokenExpiresAt: now + TOKEN_TTL_MS,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {
    success: true,
    message: 'OTP verified successfully.',
    token: verificationToken,
  };
});

exports.resetPasswordWithOtp = onCall(async (request) => {
  const email = normalizeEmail(request.data?.email);
  const token = String(request.data?.token || '').trim();
  const newPassword = String(request.data?.newPassword || '');
  const confirmPassword = String(request.data?.confirmPassword || '');

  assertValidEmail(email);
  if (!token) {
    throw new HttpsError('invalid-argument', 'Verification token is required.');
  }
  if (newPassword.length < 6) {
    throw new HttpsError(
      'invalid-argument',
      'New password must be at least 6 characters.'
    );
  }
  if (newPassword !== confirmPassword) {
    throw new HttpsError('invalid-argument', 'Passwords do not match.');
  }

  let user;
  try {
    user = await admin.auth().getUserByEmail(email);
  } catch (error) {
    throw new HttpsError('not-found', 'No account found for this email.');
  }

  const docRef = db.collection(OTP_COLLECTION).doc(user.uid);
  const snapshot = await docRef.get();
  if (!snapshot.exists) {
    throw new HttpsError('failed-precondition', 'Verification session not found.');
  }

  const data = snapshot.data();
  const now = Date.now();

  if (!data.verified || !data.verificationTokenHash) {
    throw new HttpsError('failed-precondition', 'OTP is not verified.');
  }

  if (!data.tokenExpiresAt || data.tokenExpiresAt <= now) {
    await docRef.delete();
    throw new HttpsError('deadline-exceeded', 'Verification session expired.');
  }

  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
  if (tokenHash !== data.verificationTokenHash) {
    throw new HttpsError('permission-denied', 'Invalid verification token.');
  }

  await admin.auth().updateUser(user.uid, {password: newPassword});
  await docRef.delete();

  return {success: true, message: 'Password reset successful.'};
});

exports.resetPasswordWithPhoneOtp = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Phone verification is required.');
  }

  const authPhone = String(request.auth.token.phone_number || '').trim();
  const requestedPhone = String(request.data?.phone || '').trim();
  const newPassword = String(request.data?.newPassword || '');
  const confirmPassword = String(request.data?.confirmPassword || '');

  if (!authPhone) {
    throw new HttpsError(
      'permission-denied',
      'Signed-in phone number is missing.'
    );
  }
  if (!phonesMatch(authPhone, requestedPhone)) {
    throw new HttpsError(
      'permission-denied',
      'Phone verification does not match the requested number.'
    );
  }
  if (newPassword.length < 6) {
    throw new HttpsError(
      'invalid-argument',
      'New password must be at least 6 characters.'
    );
  }
  if (newPassword !== confirmPassword) {
    throw new HttpsError('invalid-argument', 'Passwords do not match.');
  }

  const candidates = [
    requestedPhone,
    authPhone,
    normalizePhone(requestedPhone),
    normalizePhone(authPhone),
  ].filter((value) => String(value || '').trim().length > 0);

  let profileDoc;
  for (const candidate of candidates) {
    const snapshot = await db
      .collection('users')
      .where('phone', '==', candidate)
      .limit(1)
      .get();
    if (!snapshot.empty) {
      profileDoc = snapshot.docs[0];
      break;
    }
  }

  if (!profileDoc) {
    throw new HttpsError(
      'not-found',
      'No account profile found for this phone number.'
    );
  }

  const profile = profileDoc.data() || {};
  const profilePhone = String(profile.phone || '').trim();
  const email = normalizeEmail(profile.email);

  if (!phonesMatch(authPhone, profilePhone)) {
    throw new HttpsError(
      'permission-denied',
      'Phone number does not match account profile.'
    );
  }
  if (!email) {
    throw new HttpsError(
      'failed-precondition',
      'No email is linked with this phone number.'
    );
  }

  let user;
  try {
    user = await admin.auth().getUserByEmail(email);
  } catch (error) {
    throw new HttpsError('not-found', 'No account found for this profile.');
  }

  await admin.auth().updateUser(user.uid, {password: newPassword});

  return {success: true, message: 'Password reset successful.'};
});
