import '../../data/services/firebase_auth_service.dart';
import '../../domain/auth_repository.dart';
import '../../domain/models/app_user.dart';

/// UI-facing authentication actions.
///
/// Pages keep using this class so Firebase stays behind the repository.
class AuthActions {
  const AuthActions({this.repository});

  final AuthRepository? repository;

  AuthRepository get _auth => repository ?? FirebaseAuthService.instance;

  AppUser? get currentUser => _auth.currentUser;

  Stream<AppUser?> get userChanges => _auth.userChanges;

  Future<void> onLogin({required String email, required String password}) {
    return _auth.signInWithEmail(email: email, password: password);
  }

  Future<void> onGoogleLogin() => _auth.signInWithGoogle();

  Future<void> onRegister({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _auth.registerWithEmail(
      fullName: fullName,
      email: email,
      password: password,
    );
  }

  Future<void> onGoogleRegister() => _auth.signInWithGoogle();

  Future<void> onForgotPassword({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> onResendResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> onLogout() => _auth.signOut();
}
