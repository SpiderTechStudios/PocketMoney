import '../domain/models/app_user.dart';

/// Authentication contract used by the UI.
///
/// The default production implementation talks to Firebase.
/// Tests can supply a fake without initializing Firebase.
abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;

  Stream<AppUser?> get userChanges;

  AppUser? get currentUser;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> signOut();
}
