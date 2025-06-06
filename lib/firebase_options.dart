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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDfNnQuW_fuxOL8OJc8tefZHXuq_59M_mg',
    appId: '1:1023988252381:web:58f0705832dc5873e1a534',
    messagingSenderId: '1023988252381',
    projectId: 'cookpab-a0bf8',
    authDomain: 'cookpab-a0bf8.firebaseapp.com',
    databaseURL: 'https://cookpab-a0bf8-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cookpab-a0bf8.firebasestorage.app',
    measurementId: 'G-F7F5PXQ0TJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFW7v8pVap4T_HR6xS71Y2do9XOmB2m5c',
    appId: '1:1023988252381:android:5bd254445431a327e1a534',
    messagingSenderId: '1023988252381',
    projectId: 'cookpab-a0bf8',
    databaseURL: 'https://cookpab-a0bf8-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cookpab-a0bf8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDaCqgWzNlXkU9qmNCFIBlyaK1pblQbkr8',
    appId: '1:1023988252381:ios:cba6cbe55f51f0f4e1a534',
    messagingSenderId: '1023988252381',
    projectId: 'cookpab-a0bf8',
    databaseURL: 'https://cookpab-a0bf8-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cookpab-a0bf8.firebasestorage.app',
    androidClientId: '1023988252381-j72sovejp1tdv2d12g414td6q4bhf30m.apps.googleusercontent.com',
    iosClientId: '1023988252381-78892ete855c113bp75l0m7oikmi8a6g.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterTester',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA-RpTSylmKmwDuDkFX7_P_nB0cQxTLBrY',
    appId: '1:977782516452:web:625014a8f597fe33cd9af1',
    messagingSenderId: '977782516452',
    projectId: 'logintest-cc64e',
    authDomain: 'logintest-cc64e.firebaseapp.com',
    storageBucket: 'logintest-cc64e.firebasestorage.app',
    measurementId: 'G-SDF3WFDRKW',
  );

}