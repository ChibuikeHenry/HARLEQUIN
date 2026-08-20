import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options for HARLEQUIN (project harlequin-30a7b).
/// Web app: HARLEQUIN (appId 1:199569347835:web:a26032551315926a0ccc5e).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for web. '
          'Register the platform in the Firebase console, then add its options here.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCjWMvXeUNlrakpUILnXvYmM5KF9GQNscQ',
    appId: '1:199569347835:web:a26032551315926a0ccc5e',
    messagingSenderId: '199569347835',
    projectId: 'harlequin-30a7b',
    authDomain: 'harlequin-30a7b.firebaseapp.com',
    storageBucket: 'harlequin-30a7b.firebasestorage.app',
    measurementId: 'G-7KHDKHB8GK',
  );
}
