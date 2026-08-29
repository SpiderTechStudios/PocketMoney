import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/auth_failure.dart';
import '../../domain/auth_repository.dart';
import '../../domain/models/app_user.dart';
import 'user_profile_service.dart';

class FirebaseAuthService implements AuthRepository {
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    UserProfileService? userProfileService,
    GoogleSignIn? googleSignIn,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _profiles = userProfileService ?? UserProfileService(),
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final UserProfileService _profiles;
  final GoogleSignIn _googleSignIn;

  static final FirebaseAuthService instance = FirebaseAuthService();

  Stream<AppUser?>? _authStateChanges;
  Stream<AppUser?>? _userChanges;
  bool _googleInitialized = false;

  @override
  Stream<AppUser?> get authStateChanges =>
      _authStateChanges ??= _auth.authStateChanges().map(_mapUser);

  @override
  Stream<AppUser?> get userChanges =>
      _userChanges ??= _auth.userChanges().map(_mapUser);

  @override
  AppUser? get currentUser => _mapUser(_auth.currentUser);

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on AuthCancelledException {
      rethrow;
    } catch (error) {
      throw AuthFailure.from(error);
    }
  }

  @override
  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure(
          'Could not create your account. Please try again.',
        );
      }

      await user.updateDisplayName(fullName);

      try {
        await _profiles.createUserProfile(
          uid: user.uid,
          name: fullName,
          email: user.email ?? email,
          provider: UserProfileService.passwordProvider,
        );
      } catch (_) {
        // The Auth account exists. Profile can be written on a later visit
        // if database rules or connectivity blocked this write.
      }
    } on AuthCancelledException {
      rethrow;
    } on AuthFailure {
      rethrow;
    } catch (error) {
      throw AuthFailure.from(error);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final credential = kIsWeb
          ? await _signInWithGooglePopup()
          : await _signInWithGoogleNative();

      final user = credential.user;
      if (user == null) {
        throw const AuthFailure(
          'Google sign-in could not be completed. Please try again.',
        );
      }

      try {
        await _profiles.upsertGoogleProfile(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL,
        );
      } catch (_) {
        // Sign-in succeeded. Profile sync can retry on a later session.
      }
    } on AuthCancelledException {
      rethrow;
    } on AuthFailure {
      rethrow;
    } catch (error) {
      throw AuthFailure.from(error);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on AuthCancelledException {
      rethrow;
    } catch (error) {
      throw AuthFailure.from(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Continue signing out of Firebase even if Google session cleanup fails.
    }

    try {
      await _auth.signOut();
    } catch (error) {
      throw AuthFailure.from(error);
    }
  }

  Future<UserCredential> _signInWithGooglePopup() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile')
      ..setCustomParameters({'prompt': 'select_account'});
    return _auth.signInWithPopup(provider);
  }

  Future<UserCredential> _signInWithGoogleNative() async {
    await _ensureGoogleInitialized();
    final account = await _googleSignIn.authenticate(
      scopeHint: const ['email', 'profile'],
    );
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const AuthFailure(
        'Google sign-in could not be completed. Please try again.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _auth.signInWithCredential(credential);
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  AppUser? _mapUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      provider: _providerOf(user),
    );
  }

  String? _providerOf(User user) {
    if (user.providerData.any((info) => info.providerId == 'google.com')) {
      return UserProfileService.googleProvider;
    }
    if (user.providerData.any((info) => info.providerId == 'password')) {
      return UserProfileService.passwordProvider;
    }
    return user.providerData.isEmpty
        ? null
        : user.providerData.first.providerId;
  }
}
