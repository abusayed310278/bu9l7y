import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';

class PhoneOtpAuthService {
  static const String _appName = 'phone_otp_app';

  static Future<FirebaseApp> _ensureApp() async {
    try {
      return Firebase.app(_appName);
    } catch (_) {
      return Firebase.initializeApp(
        name: _appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  static Future<FirebaseAuth> auth() async {
    final FirebaseApp app = await _ensureApp();
    return FirebaseAuth.instanceFor(app: app);
  }

  static Future<FirebaseFunctions> functions({String? region}) async {
    final FirebaseApp app = await _ensureApp();
    return FirebaseFunctions.instanceFor(app: app, region: region);
  }

  static Future<void> clearSession() async {
    final FirebaseAuth phoneAuth = await auth();
    await phoneAuth.signOut();
  }
}
