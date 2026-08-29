import 'package:firebase_database/firebase_database.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/firebase/current_uid.dart';
import '../../../core/firebase/rtdb_paths.dart';
import '../domain/ledger_effect.dart';
import '../domain/models/account.dart';
import '../domain/models/money_transaction.dart';
import 'financial_engine.dart';
import 'rtdb_map.dart';

class AccountService {
  AccountService({FirebaseDatabase? database, FinancialEngine? engine})
    : _db = database ?? FirebaseDatabase.instance,
      _engine = engine ?? FinancialEngine.instance;

  final FirebaseDatabase _db;
  final FinancialEngine _engine;

  static final AccountService instance = AccountService();

  Stream<List<Account>> watch() {
    final paths = RtdbPaths(CurrentUid.require());
    return _db.ref(paths.accounts).onValue.map((event) {
      final children = asChildMap(event.snapshot.value);
      final accounts =
          children.entries
              .map((entry) => Account.fromMap(entry.key, entry.value))
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      return accounts;
    });
  }

  Future<void> create({
    required String name,
    required AccountType type,
    required num openingBalance,
    required String currency,
    String? provider,
  }) async {
    if (name.trim().isEmpty) {
      throw const AppFailure('Account name is required.');
    }
    if (openingBalance < 0) {
      throw const AppFailure('Opening balance cannot be negative.');
    }

    final uid = CurrentUid.require();
    final paths = RtdbPaths(uid);
    final id = _engine.newId(paths.accounts);
    final now = DateTime.now().millisecondsSinceEpoch;

    final writes = <String, Object?>{
      paths.account(id): {
        'name': name.trim(),
        'type': type.id,
        'balance': openingBalance,
        'currency': currency,
        'isActive': true,
        if (provider != null && provider.trim().isNotEmpty)
          'provider': provider.trim(),
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      },
    };

    var effect = const LedgerEffect();
    if (openingBalance > 0) {
      final txId = _engine.newId(paths.transactions);
      writes[paths.transaction(txId)] = {
        'type': TxType.openingBalance.id,
        'direction': TxDirection.opening.name,
        'amount': openingBalance,
        'currency': currency,
        'accountId': id,
        'description': 'Opening balance',
        'transactionDate': now,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };
      effect = LedgerEffect(accountDeltas: {id: openingBalance});
    }

    await _engine.commit(
      writes: writes,
      effect: effect,
      skipAccountIncrements: {id},
    );
  }

  Future<void> update({
    required String id,
    required String name,
    required AccountType type,
    String? provider,
  }) async {
    if (name.trim().isEmpty) {
      throw const AppFailure('Account name is required.');
    }
    final paths = RtdbPaths(CurrentUid.require());
    try {
      await _db.ref(paths.account(id)).update({
        'name': name.trim(),
        'type': type.id,
        if (provider != null) 'provider': provider.trim(),
        'updatedAt': ServerValue.timestamp,
      });
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<void> setActive({required String id, required bool isActive}) async {
    final paths = RtdbPaths(CurrentUid.require());
    try {
      await _db.ref(paths.account(id)).update({
        'isActive': isActive,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (error) {
      throw AppFailure.from(error);
    }
  }
}
