import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web in this project.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBW0mA6G2AibYHHxEIuaVOOdPNKt4FEF9E',
    appId: '1:67345152530:android:a3e71f0ada8eeb1f00f6cb',
    messagingSenderId: '67345152530',
    projectId: 'itknowledgequiz',
    storageBucket: 'itknowledgequiz.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDi5J7wJuLFavu_L2Vi0q6hPbBX5K2zuD0',
    appId: '1:67345152530:ios:736bc2d9325414fb00f6cb',
    messagingSenderId: '67345152530',
    projectId: 'itknowledgequiz',
    storageBucket: 'itknowledgequiz.firebasestorage.app',
    iosBundleId: 'com.ziuq.buly',
  );

}