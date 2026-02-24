const crypto = require('crypto');
const admin = require('firebase-admin');
const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');
const sendGridMail = require('@sendgrid/mail');

admin.initializeApp();

const db = admin.firestore();
const SENDGRID_API_KEY = defineSecret('SENDGRID_API_KEY');
const OTP_FROM_EMAIL = defineSecret('OTP_FROM_EMAIL');
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

async function sendOtpEmail({apiKey, fromEmail, toEmail, otp}) {
  sendGridMail.setApiKey(apiKey);
  await sendGridMail.send({
    to: toEmail,
    from: fromEmail,
    subject: 'Your password reset OTP',
    text: `Your OTP is ${otp}. It expires in 10 minutes.`,
    html: `<p>Your OTP is <strong>${otp}</strong>.</p><p>It expires in 10 minutes.</p>`,
  });
}

exports.sendPasswordResetOtp = onCall(
  {secrets: [SENDGRID_API_KEY, OTP_FROM_EMAIL]},
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

    const apiKey = SENDGRID_API_KEY.value();
    const fromEmail = OTP_FROM_EMAIL.value();

    if (!apiKey || !fromEmail) {
      throw new HttpsError(
        'failed-precondition',
        'Email provider is not configured on the server.'
      );
    }

    try {
      await sendOtpEmail({apiKey, fromEmail, toEmail: email, otp});
      return {success: true, message: 'OTP sent successfully.'};
    } catch (error) {
      throw new HttpsError('internal', 'Failed to send OTP email.');
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
