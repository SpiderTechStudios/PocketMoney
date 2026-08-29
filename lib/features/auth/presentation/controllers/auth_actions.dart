/// Placeholder authentication actions.
///
/// These methods currently simulate network latency only.
/// Replace each implementation with Firebase Authentication when integrating.
class AuthActions {
  const AuthActions();

  /// TODO: Sign in with Firebase Auth using [email] and [password].
  Future<void> onLogin({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  /// TODO: Sign in with Firebase Auth Google provider.
  Future<void> onGoogleLogin() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  /// TODO: Create a Firebase Auth user and store [fullName] on the user profile.
  Future<void> onRegister({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  /// TODO: Register / sign in with Firebase Auth Google provider.
  Future<void> onGoogleRegister() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  /// TODO: Send a Firebase Auth password-reset email to [email].
  Future<void> onForgotPassword({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  /// TODO: Resend a Firebase Auth password-reset email to [email].
  Future<void> onResendResetEmail({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }
}
