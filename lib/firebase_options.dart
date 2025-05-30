// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyD0ZZZukLYu8Z6MgE4TA1LR4ICxdmUgO7c',
    appId: '1:661195989744:web:c662c5c640dfc74c2f9835',
    messagingSenderId: '661195989744',
    projectId: 'qr-attendance-app-efd62',
    authDomain: 'qr-attendance-app-efd62.firebaseapp.com',
    storageBucket: 'qr-attendance-app-efd62.firebasestorage.app',
    measurementId: 'G-HPPB3HHGQ4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAdYS3O2wkPf2LZQOm5Ywt3gNFoa5yazDk',
    appId: '1:661195989744:android:23bfe80f263700aa2f9835',
    messagingSenderId: '661195989744',
    projectId: 'qr-attendance-app-efd62',
    storageBucket: 'qr-attendance-app-efd62.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBYxiM6tiRZOh8eCt8P6slhLWQl7rGShI',
    appId: '1:661195989744:ios:be6f3acd2b66a5082f9835',
    messagingSenderId: '661195989744',
    projectId: 'qr-attendance-app-efd62',
    storageBucket: 'qr-attendance-app-efd62.firebasestorage.app',
    iosBundleId: 'com.example.qrAttendenceApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDBYxiM6tiRZOh8eCt8P6slhLWQl7rGShI',
    appId: '1:661195989744:ios:be6f3acd2b66a5082f9835',
    messagingSenderId: '661195989744',
    projectId: 'qr-attendance-app-efd62',
    storageBucket: 'qr-attendance-app-efd62.firebasestorage.app',
    iosBundleId: 'com.example.qrAttendenceApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD0ZZZukLYu8Z6MgE4TA1LR4ICxdmUgO7c',
    appId: '1:661195989744:web:d65f31b0418924852f9835',
    messagingSenderId: '661195989744',
    projectId: 'qr-attendance-app-efd62',
    authDomain: 'qr-attendance-app-efd62.firebaseapp.com',
    storageBucket: 'qr-attendance-app-efd62.firebasestorage.app',
    measurementId: 'G-7GPXM96TV8',
  );
}
