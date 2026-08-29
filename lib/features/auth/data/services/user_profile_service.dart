import 'package:firebase_database/firebase_database.dart';

import '../../domain/auth_failure.dart';
import '../../domain/models/app_user.dart';

class UserProfileService {
  UserProfileService({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  static const String _usersPath = 'users';
  static const String passwordProvider = 'password';
  static const String googleProvider = 'google';

  DatabaseReference _profileRef(String uid) =>
      _database.ref('$_usersPath/$uid/profile');

  Future<bool> userProfileExists(String uid) async {
    try {
      final snapshot = await _profileRef(uid).get();
      return snapshot.exists;
    } catch (error) {
      throw AuthFailure.from(error);
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final snapshot = await _profileRef(uid).get();
      if (!snapshot.exists || snapshot.value is! Map) {
        return null;
      }
      return UserProfile.fromMap(
        Map<Object?, Object?>.from(snapshot.value as Map),
      );
    } catch (error) {
      throw AuthFailure.from(error);
    }
  }

  /// Creates the V1 profile document. Workspace defaults are seeded on login.
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String provider,
    String? photoUrl,
  }) async {
    try {
      final payload = <String, Object?>{
        'uid': uid,
        'name': name,
        'email': email,
        'provider': provider,
        'currency': 'TZS',
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };
      if (photoUrl != null && photoUrl.isNotEmpty) {
        payload['photoUrl'] = photoUrl;
      }
      await _profileRef(uid).set(payload);
    } catch (error) {
      throw AuthFailure.from(error);
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    Map<String, Object?> updates = const {},
  }) async {
    try {
      await _profileRef(uid)
          .update({...updates, 'updatedAt': ServerValue.timestamp});
    } catch (error) {
      throw AuthFailure.from(error);
    }
  }

  Future<void> upsertGoogleProfile({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    final existing = await getUserProfile(uid);
    if (existing == null) {
      await createUserProfile(
        uid: uid,
        name: name,
        email: email,
        provider: googleProvider,
        photoUrl: photoUrl,
      );
      return;
    }

    final updates = <String, Object?>{};
    if (existing.name.trim().isEmpty && name.trim().isNotEmpty) {
      updates['name'] = name;
    }
    if (existing.email.trim().isEmpty && email.trim().isNotEmpty) {
      updates['email'] = email;
    }
    if ((existing.photoUrl == null || existing.photoUrl!.isEmpty) &&
        photoUrl != null &&
        photoUrl.isNotEmpty) {
      updates['photoUrl'] = photoUrl;
    }
    if (updates.isEmpty) {
      await updateUserProfile(uid: uid);
      return;
    }
    await updateUserProfile(uid: uid, updates: updates);
  }
}
