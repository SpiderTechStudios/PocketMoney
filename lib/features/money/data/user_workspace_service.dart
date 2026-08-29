import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/firebase/current_uid.dart';
import '../../../core/firebase/rtdb_paths.dart';
import '../../auth/domain/models/app_user.dart';
import '../domain/models/category.dart';
import '../domain/models/user_settings.dart';
import 'rtdb_map.dart';

class UserWorkspaceService {
  UserWorkspaceService({FirebaseDatabase? database})
    : _db = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _db;

  static final UserWorkspaceService instance = UserWorkspaceService();

  Future<void> ensureReady({
    String? name,
    String? email,
    String? photoUrl,
    String provider = 'password',
  }) async {
    try {
      final uid = CurrentUid.require();
      final paths = RtdbPaths(uid);
      final rootSnap = await _db.ref(paths.root).get();
      final root = asObjectMap(rootSnap.value);
      final profile = asObjectMap(root?['profile']);
      final auth = FirebaseAuth.instance.currentUser;

      final updates = <String, Object?>{};

      if (profile == null) {
        final legacyName = root?['name'] as String?;
        updates[paths.profile] = {
          'uid': uid,
          'name':
              name ??
              legacyName ??
              auth?.displayName ??
              email ??
              auth?.email ??
              'User',
          'email': email ?? root?['email'] ?? auth?.email ?? '',
          'photoUrl': photoUrl ?? root?['photoUrl'] ?? auth?.photoURL,
          'currency': AppConstants.defaultCurrency,
          'provider': provider,
          'createdAt': ServerValue.timestamp,
          'updatedAt': ServerValue.timestamp,
        };
      }

      if (root?['settings'] is! Map) {
        updates[paths.settings] = {
          ...UserSettings.defaults.toMap(),
          'updatedAt': ServerValue.timestamp,
        };
      }

      if (root?['dashboard'] is! Map) {
        updates[paths.dashboard] = {
          'totalBalance': 0,
          'totalIncome': 0,
          'totalExpenses': 0,
          'totalLent': 0,
          'totalBorrowed': 0,
          'updatedAt': ServerValue.timestamp,
        };
      }

      final existingCategories = asChildMap(root?['categories']);
      if (existingCategories.isEmpty) {
        for (final category in DefaultCategories.all) {
          updates[paths.category(category.id)] = category.toMap();
        }
      }

      if (updates.isEmpty) return;
      await _db.ref().update(updates);
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Stream<UserProfile?> watchProfile() {
    final uid = CurrentUid.require();
    final paths = RtdbPaths(uid);
    return _db.ref(paths.profile).onValue.map((event) {
      final data = asObjectMap(event.snapshot.value);
      if (data == null) return null;
      return UserProfile.fromMap(data);
    });
  }

  Future<UserProfile?> getProfile() async {
    final uid = CurrentUid.require();
    final snap = await _db.ref(RtdbPaths(uid).profile).get();
    final data = asObjectMap(snap.value);
    if (data == null) return null;
    return UserProfile.fromMap(data);
  }

  Future<void> updateProfile({String? name, String? currency}) async {
    try {
      final uid = CurrentUid.require();
      final updates = <String, Object?>{
        '${RtdbPaths(uid).profile}/updatedAt': ServerValue.timestamp,
      };
      if (name != null) {
        updates['${RtdbPaths(uid).profile}/name'] = name;
        await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      }
      if (currency != null) {
        updates['${RtdbPaths(uid).profile}/currency'] = currency;
        updates['${RtdbPaths(uid).settings}/currency'] = currency;
        updates['${RtdbPaths(uid).settings}/updatedAt'] = ServerValue.timestamp;
      }
      await _db.ref().update(updates);
    } catch (error) {
      throw AppFailure.from(error);
    }
  }
}
