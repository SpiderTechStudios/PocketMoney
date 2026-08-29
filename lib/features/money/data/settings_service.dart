import 'package:firebase_database/firebase_database.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/firebase/current_uid.dart';
import '../../../core/firebase/rtdb_paths.dart';
import '../domain/models/user_settings.dart';
import 'rtdb_map.dart';

class SettingsService {
  SettingsService({FirebaseDatabase? database})
    : _db = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _db;

  static final SettingsService instance = SettingsService();

  Stream<UserSettings> watch() {
    final paths = RtdbPaths(CurrentUid.require());
    return _db.ref(paths.settings).onValue.map((event) {
      final data = asObjectMap(event.snapshot.value);
      if (data == null) return UserSettings.defaults;
      return UserSettings.fromMap(data);
    });
  }

  Future<void> update(UserSettings settings) async {
    try {
      final paths = RtdbPaths(CurrentUid.require());
      await _db.ref().update({
        '${paths.settings}/currency': settings.currency,
        '${paths.settings}/language': settings.language,
        '${paths.settings}/theme': settings.theme,
        '${paths.settings}/notificationsEnabled':
            settings.notificationsEnabled,
        '${paths.settings}/remindersEnabled': settings.remindersEnabled,
        '${paths.settings}/updatedAt': ServerValue.timestamp,
        '${paths.profile}/currency': settings.currency,
        '${paths.profile}/updatedAt': ServerValue.timestamp,
      });
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Stream<DashboardSummary> watchDashboard() {
    final paths = RtdbPaths(CurrentUid.require());
    return _db.ref(paths.dashboard).onValue.map((event) {
      final data = asObjectMap(event.snapshot.value);
      if (data == null) return const DashboardSummary();
      return DashboardSummary.fromMap(data);
    });
  }
}
