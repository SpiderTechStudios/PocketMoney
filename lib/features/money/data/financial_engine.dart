import 'package:firebase_database/firebase_database.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/firebase/current_uid.dart';
import '../../../core/firebase/rtdb_paths.dart';
import '../domain/ledger_effect.dart';

class FinancialEngine {
  FinancialEngine({FirebaseDatabase? database})
    : _db = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _db;

  static final FinancialEngine instance = FinancialEngine();

  /// Applies [writes] and [effect] in a single RTDB multi-path update.
  Future<void> commit({
    required Map<String, Object?> writes,
    LedgerEffect effect = const LedgerEffect(),
    Set<String> skipAccountIncrements = const {},
  }) async {
    try {
      final uid = CurrentUid.require();
      final paths = RtdbPaths(uid);
      final updates = Map<String, Object?>.from(writes);

      effect.accountDeltas.forEach((accountId, delta) {
        if (delta == 0 || skipAccountIncrements.contains(accountId)) return;
        updates['${paths.account(accountId)}/balance'] = ServerValue.increment(
          delta,
        );
        updates['${paths.account(accountId)}/updatedAt'] =
            ServerValue.timestamp;
      });

      if (effect.incomeDelta != 0) {
        updates['${paths.dashboard}/totalIncome'] = ServerValue.increment(
          effect.incomeDelta,
        );
      }
      if (effect.expenseDelta != 0) {
        updates['${paths.dashboard}/totalExpenses'] = ServerValue.increment(
          effect.expenseDelta,
        );
      }
      if (effect.lentDelta != 0) {
        updates['${paths.dashboard}/totalLent'] = ServerValue.increment(
          effect.lentDelta,
        );
      }
      if (effect.borrowedDelta != 0) {
        updates['${paths.dashboard}/totalBorrowed'] = ServerValue.increment(
          effect.borrowedDelta,
        );
      }
      if (effect.totalBalanceDelta != 0) {
        updates['${paths.dashboard}/totalBalance'] = ServerValue.increment(
          effect.totalBalanceDelta,
        );
      }
      updates['${paths.dashboard}/updatedAt'] = ServerValue.timestamp;

      await _db.ref().update(updates);
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  String newId(String path) {
    return _db.ref(path).push().key ??
        DateTime.now().millisecondsSinceEpoch.toString();
  }
}
