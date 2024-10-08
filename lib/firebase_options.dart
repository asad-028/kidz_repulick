// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCLzJNac_XaOU8MdzCa6gAaJ5_rR1f4eoc',
    appId: '1:553845047105:web:90e8dffd44a2eeea2aebc0',
    messagingSenderId: '553845047105',
    projectId: 'kids-republik-e8265',
    authDomain: 'kids-republik-e8265.firebaseapp.com',
    storageBucket: 'kids-republik-e8265.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGt_OCLQQzUj1EgQaw3jlHFI5SVuiaIA0',
    appId: '1:553845047105:android:091c89c80dd8f2de2aebc0',
    messagingSenderId: '553845047105',
    projectId: 'kids-republik-e8265',
    storageBucket: 'kids-republik-e8265.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBIMTW4kEWLz2u1XFVw7yqJ4-t0CSOIWwU',
    appId: '1:553845047105:ios:d214bc00cb72ea6d2aebc0',
    messagingSenderId: '553845047105',
    projectId: 'kids-republik-e8265',
    storageBucket: 'kids-republik-e8265.appspot.com',
    iosBundleId: 'com.kidzrepublik.kidzrepublik',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBIMTW4kEWLz2u1XFVw7yqJ4-t0CSOIWwU',
    appId: '1:553845047105:ios:d214bc00cb72ea6d2aebc0',
    messagingSenderId: '553845047105',
    projectId: 'kids-republik-e8265',
    storageBucket: 'kids-republik-e8265.appspot.com',
    iosBundleId: 'com.kidzrepublik.kidzrepublik',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCLzJNac_XaOU8MdzCa6gAaJ5_rR1f4eoc',
    appId: '1:553845047105:web:a9a0d8b98fb77a242aebc0',
    messagingSenderId: '553845047105',
    projectId: 'kids-republik-e8265',
    authDomain: 'kids-republik-e8265.firebaseapp.com',
    storageBucket: 'kids-republik-e8265.appspot.com',
  );

}