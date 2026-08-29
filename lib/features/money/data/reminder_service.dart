import 'package:firebase_database/firebase_database.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/firebase/current_uid.dart';
import '../../../core/firebase/rtdb_paths.dart';
import '../domain/models/reminder.dart';
import 'financial_engine.dart';
import 'rtdb_map.dart';

class ReminderService {
  ReminderService({FirebaseDatabase? database, FinancialEngine? engine})
    : _db = database ?? FirebaseDatabase.instance,
      _engine = engine ?? FinancialEngine.instance;

  final FirebaseDatabase _db;
  final FinancialEngine _engine;

  static final ReminderService instance = ReminderService();

  Stream<List<Reminder>> watch() {
    final paths = RtdbPaths(CurrentUid.require());
    return _db.ref(paths.reminders).onValue.map((event) {
      return asChildMap(event.snapshot.value).entries
          .map((entry) => Reminder.fromMap(entry.key, entry.value))
          .toList()
        ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
    });
  }

  Future<void> create({
    required String title,
    required ReminderType type,
    required int reminderDate,
    num? amount,
    String? currency,
    String? description,
  }) async {
    _validate(title, reminderDate, amount);
    final paths = RtdbPaths(CurrentUid.require());
    final id = _engine.newId(paths.reminders);
    try {
      await _db.ref(paths.reminder(id)).set({
        'title': title.trim(),
        'type': type.id,
        'reminderDate': reminderDate,
        'isCompleted': false,
        'isCancelled': false,
        'amount': ?amount,
        'currency': ?currency,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<void> update(Reminder reminder) async {
    _validate(reminder.title, reminder.reminderDate, reminder.amount);
    final paths = RtdbPaths(CurrentUid.require());
    try {
      await _db.ref(paths.reminder(reminder.id)).update({
        ...reminder.toMap(),
        'updatedAt': ServerValue.timestamp,
      });
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<void> complete(String id) => _flag(id, {'isCompleted': true});

  Future<void> cancel(String id) => _flag(id, {'isCancelled': true});

  Future<void> delete(String id) async {
    final paths = RtdbPaths(CurrentUid.require());
    try {
      await _db.ref(paths.reminder(id)).remove();
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<void> _flag(String id, Map<String, Object?> values) async {
    final paths = RtdbPaths(CurrentUid.require());
    try {
      await _db.ref(paths.reminder(id)).update({
        ...values,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  void _validate(String title, int reminderDate, num? amount) {
    if (title.trim().isEmpty) {
      throw const AppFailure('Title is required.');
    }
    if (reminderDate <= 0) {
      throw const AppFailure('Please choose a valid date.');
    }
    if (amount != null && amount < 0) {
      throw const AppFailure('Amount cannot be negative.');
    }
  }
}
