# Password Reset OTP Cloud Functions

This folder provides Firebase Cloud Functions for:
- `sendPasswordResetOtp`
- `verifyPasswordResetOtp`
- `resetPasswordWithOtp`

## Prerequisites

- Firebase project with Authentication (Email/Password) enabled
- Firestore enabled
- Firebase CLI installed (`npm i -g firebase-tools`)
- SendGrid account/API key for transactional email

## Setup

1. Select your Firebase project:

```bash
firebase use <your-firebase-project-id>
```

2. Install function dependencies:

```bash
cd functions
npm install
cd ..
```

3. Set function secrets:

```bash
firebase functions:secrets:set SENDGRID_API_KEY
firebase functions:secrets:set OTP_FROM_EMAIL
```

- `SENDGRID_API_KEY`: your SendGrid API key
- `OTP_FROM_EMAIL`: verified sender email (example: `noreply@yourdomain.com`)

4. Deploy:

```bash
firebase deploy --only functions
```

## Callable Contract

### sendPasswordResetOtp
Input:
```json
{ "email": "user@example.com" }
```

### verifyPasswordResetOtp
Input:
```json
{ "email": "user@example.com", "otp": "123456" }
```
Output includes a temporary `token` used by reset step.

### resetPasswordWithOtp
Input:
```json
{
  "email": "user@example.com",
  "newPassword": "newpassword",
  "confirmPassword": "newpassword",
  "token": "verification-token-from-verify-step"
}
```

## Notes

- OTP validity: 10 minutes
- Verification token validity: 10 minutes
- OTP records are stored in Firestore collection `password_reset_otps`
