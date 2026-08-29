// File generated for FlutterFire (web-first).
// Android/iOS apps can be added later with `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Android. '
          'Run `flutterfire configure` after adding an Android app in Firebase Console.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS. '
          'Run `flutterfire configure` after adding an iOS app in Firebase Console.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS. '
          'Run `flutterfire configure` after adding a macOS app in Firebase Console.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows. '
          'Use Flutter Web (`flutter run -d chrome`) or run `flutterfire configure`.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux. '
          'Use Flutter Web (`flutter run -d chrome`) or run `flutterfire configure`.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBetbAcv1nLlalALhKXwxKNJFrYBwwSxck',
    appId: '1:800308077169:web:4afd7387907aea97d6b1d0',
    messagingSenderId: '800308077169',
    projectId: 'pocketmoneybyjuku',
    authDomain: 'pocketmoneybyjuku.firebaseapp.com',
    databaseURL: 'https://pocketmoneybyjuku-default-rtdb.firebaseio.com',
    storageBucket: 'pocketmoneybyjuku.appspot.com',
    measurementId: 'G-HHW8BT33QC',
  );
}
