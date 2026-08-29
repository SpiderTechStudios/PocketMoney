import 'package:firebase_auth/firebase_auth.dart';

import '../errors/app_failure.dart';

class CurrentUid {
  CurrentUid._();

  static String require() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw const AppFailure('You need to sign in again.');
    }
    return uid;
  }
}
