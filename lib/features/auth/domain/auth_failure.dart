import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thrown when the user dismisses a sign-in flow (for example a Google popup).
class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

/// User-facing authentication failure. Never expose raw Firebase codes.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const AuthFailure('Please enter a valid email address.');
      case 'user-disabled':
        return const AuthFailure('This account has been disabled.');
      case 'user-not-found':
        return const AuthFailure('No account was found with these details.');
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return const AuthFailure('Incorrect email or password.');
      case 'email-already-in-use':
        return const AuthFailure('An account already exists with this email.');
      case 'weak-password':
        return const AuthFailure('Please choose a stronger password.');
      case 'operation-not-allowed':
        return const AuthFailure(
          'This sign-in method is not enabled. Please try another option.',
        );
      case 'network-request-failed':
        return const AuthFailure(
          'Please check your internet connection and try again.',
        );
      case 'too-many-requests':
        return const AuthFailure('Too many attempts. Please try again later.');
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        throw const AuthCancelledException();
      case 'popup-blocked':
        return const AuthFailure(
          'Google sign-in was blocked. Please allow popups and try again.',
        );
      case 'account-exists-with-different-credential':
        return const AuthFailure(
          'An account already exists with this email using a different sign-in method.',
        );
      case 'requires-recent-login':
        return const AuthFailure(
          'Please sign in again before completing this action.',
        );
      case 'invalid-verification-code':
      case 'invalid-verification-id':
        return const AuthFailure('The verification details are invalid.');
      default:
        return const AuthFailure('Something went wrong. Please try again.');
    }
  }

  factory AuthFailure.from(Object error) {
    if (error is AuthFailure) return error;
    if (error is AuthCancelledException) throw error;

    if (error is FirebaseAuthException) {
      return AuthFailure.fromCode(error.code);
    }

    if (error is GoogleSignInException) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      return const AuthFailure(
        'Google sign-in could not be completed. Please try again.',
      );
    }

    final raw = error.toString().toLowerCase();
    if (raw.contains('network')) {
      return const AuthFailure(
        'Please check your internet connection and try again.',
      );
    }

    return const AuthFailure('Something went wrong. Please try again.');
  }

  @override
  String toString() => message;
}
