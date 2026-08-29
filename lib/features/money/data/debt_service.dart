import 'package:firebase_database/firebase_database.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/firebase/current_uid.dart';
import '../../../core/firebase/rtdb_paths.dart';
import '../domain/ledger_effect.dart';
import '../domain/models/debt.dart';
import '../domain/models/money_transaction.dart';
import 'financial_engine.dart';
import 'rtdb_map.dart';

class DebtService {
  DebtService({FirebaseDatabase? database, FinancialEngine? engine})
    : _db = database ?? FirebaseDatabase.instance,
      _engine = engine ?? FinancialEngine.instance;

  final FirebaseDatabase _db;
  final FinancialEngine _engine;

  static final DebtService instance = DebtService();

  Stream<List<Debt>> watch() {
    final paths = RtdbPaths(CurrentUid.require());
    return _db.ref(paths.debts).onValue.map((event) {
      return asChildMap(event.snapshot.value).entries
          .map((entry) => Debt.fromMap(entry.key, entry.value))
          .toList()
        ..sort((a, b) => (b.updatedAt ?? 0).compareTo(a.updatedAt ?? 0));
    });
  }

  Future<void> recordPayment({
    required Debt debt,
    required num amount,
    required String accountId,
    required int paymentDate,
  }) async {
    if (!debt.isOpen) {
      throw const AppFailure('This debt is no longer active.');
    }
    if (amount <= 0) {
      throw const AppFailure('Amount must be greater than zero.');
    }
    if (amount > debt.remainingAmount) {
      throw const AppFailure('Payment cannot exceed the remaining amount.');
    }
    if (accountId.isEmpty) {
      throw const AppFailure('Please select an account.');
    }

    final paths = RtdbPaths(CurrentUid.require());
    final paymentId = _engine.newId('${paths.debt(debt.id)}/payments');
    final txId = _engine.newId(paths.transactions);
    final remaining = debt.remainingAmount - amount;
    final paid = debt.paidAmount + amount;

    await _engine.commit(
      writes: {
        paths.debtPayment(debt.id, paymentId): {
          'amount': amount,
          'accountId': accountId,
          'paymentDate': paymentDate,
        },
        '${paths.debt(debt.id)}/paidAmount': paid,
        '${paths.debt(debt.id)}/remainingAmount': remaining,
        '${paths.debt(debt.id)}/status': Debt.statusFor(
          remaining: remaining,
          paid: paid,
        ),
        '${paths.debt(debt.id)}/updatedAt': ServerValue.timestamp,
        paths.transaction(txId): {
          'type': TxType.debtPayment.id,
          'direction': TxDirection.debt.name,
          'amount': amount,
          'currency': debt.currency,
          'accountId': accountId,
          'debtId': debt.id,
          'personName': debt.personName,
          'description': debt.type == DebtKind.lent
              ? 'Collection from ${debt.personName}'
              : 'Payment to ${debt.personName}',
          'transactionDate': paymentDate,
          'createdAt': ServerValue.timestamp,
          'updatedAt': ServerValue.timestamp,
        },
      },
      effect: LedgerEffect.forDebtPayment(
        isLent: debt.type == DebtKind.lent,
        accountId: accountId,
        amount: amount,
      ),
    );
  }

  Future<void> cancel(Debt debt) async {
    if (debt.paidAmount > 0) {
      throw const AppFailure(
        'A debt with payments cannot be cancelled. Record the remaining balance first.',
      );
    }
    final paths = RtdbPaths(CurrentUid.require());
    final reverse = debt.type == DebtKind.lent
        ? LedgerEffect(
            accountDeltas: {debt.accountId: debt.originalAmount},
            lentDelta: -debt.originalAmount,
          )
        : LedgerEffect(
            accountDeltas: {debt.accountId: -debt.originalAmount},
            borrowedDelta: -debt.originalAmount,
          );

    await _engine.commit(
      writes: {
        '${paths.debt(debt.id)}/status': DebtStatus.cancelled.id,
        '${paths.debt(debt.id)}/updatedAt': ServerValue.timestamp,
      },
      effect: reverse,
    );
  }
}
