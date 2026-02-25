# Password Reset OTP Cloud Functions

This folder provides Firebase Cloud Functions for:
- `sendPasswordResetOtp`
- `verifyPasswordResetOtp`
- `resetPasswordWithOtp`

## Prerequisites

- Firebase project with Authentication (Email/Password) enabled
- Firestore enabled
- Firebase CLI installed (`npm i -g firebase-tools`)
- One of:
  - Gmail account + App Password (recommended for quick setup)
  - SendGrid account/API key

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
firebase functions:secrets:set OTP_FROM_EMAIL
firebase functions:secrets:set OTP_GMAIL_APP_PASSWORD
```

- `OTP_FROM_EMAIL`: Gmail address that sends OTP (example: `yourname@gmail.com`)
- `OTP_GMAIL_APP_PASSWORD`: 16-character Gmail App Password

Optional fallback (if you prefer SendGrid):

```bash
firebase functions:secrets:set SENDGRID_API_KEY
```

- `SENDGRID_API_KEY`: SendGrid API key

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
