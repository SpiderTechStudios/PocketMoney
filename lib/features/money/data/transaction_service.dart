import 'package:firebase_database/firebase_database.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/firebase/current_uid.dart';
import '../../../core/firebase/rtdb_paths.dart';
import '../domain/ledger_effect.dart';
import '../domain/models/debt.dart';
import '../domain/models/money_transaction.dart';
import 'financial_engine.dart';
import 'rtdb_map.dart';

class TransactionService {
  TransactionService({FirebaseDatabase? database, FinancialEngine? engine})
    : _db = database ?? FirebaseDatabase.instance,
      _engine = engine ?? FinancialEngine.instance;

  final FirebaseDatabase _db;
  final FinancialEngine _engine;

  static final TransactionService instance = TransactionService();

  Stream<List<MoneyTransaction>> watch() {
    final paths = RtdbPaths(CurrentUid.require());
    return _db.ref(paths.transactions).onValue.map((event) {
      return asChildMap(event.snapshot.value).entries
          .map((entry) => MoneyTransaction.fromMap(entry.key, entry.value))
          .toList()
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    });
  }

  Future<void> recordIncomeOrExpense(MoneyTransaction draft) async {
    _validateAmount(draft.amount);
    if (draft.accountId == null || draft.accountId!.isEmpty) {
      throw const AppFailure('Please select an account.');
    }
    await _saveNew(draft, LedgerEffect.fromTransaction(draft));
  }

  Future<void> recordTransfer(MoneyTransaction draft) async {
    _validateAmount(draft.amount);
    if (draft.fromAccountId == null || draft.toAccountId == null) {
      throw const AppFailure('Please choose both accounts.');
    }
    if (draft.fromAccountId == draft.toAccountId) {
      throw const AppFailure('From and to accounts must be different.');
    }
    if ((draft.fee?.amount ?? 0) < 0) {
      throw const AppFailure('Fee cannot be negative.');
    }
    await _saveNew(draft, LedgerEffect.fromTransaction(draft));
  }

  Future<void> recordLentOrBorrowed({
    required MoneyTransaction draft,
    required String personName,
    String? personPhone,
    int? dueDate,
  }) async {
    _validateAmount(draft.amount);
    if (draft.accountId == null || draft.accountId!.isEmpty) {
      throw const AppFailure('Please select an account.');
    }
    if (personName.trim().isEmpty) {
      throw const AppFailure('Person name is required.');
    }

    final uid = CurrentUid.require();
    final paths = RtdbPaths(uid);
    final txId = _engine.newId(paths.transactions);
    final debtId = _engine.newId(paths.debts);
    final now = DateTime.now().millisecondsSinceEpoch;
    final kind = draft.type == TxType.borrowed
        ? DebtKind.borrowed
        : DebtKind.lent;

    final tx = MoneyTransaction(
      id: txId,
      type: draft.type,
      direction: draft.direction,
      amount: draft.amount,
      currency: draft.currency,
      transactionDate: draft.transactionDate,
      accountId: draft.accountId,
      description: draft.description,
      debtId: debtId,
      personName: personName.trim(),
      personPhone: personPhone?.trim(),
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );

    await _engine.commit(
      writes: {
        paths.transaction(txId): tx.toMap()
          ..['createdAt'] = ServerValue.timestamp
          ..['updatedAt'] = ServerValue.timestamp,
        paths.debt(debtId): {
          'type': kind.id,
          'person': {
            'name': personName.trim(),
            if (personPhone != null && personPhone.trim().isNotEmpty)
              'phone': personPhone.trim(),
          },
          'originalAmount': draft.amount,
          'paidAmount': 0,
          'remainingAmount': draft.amount,
          'currency': draft.currency,
          'accountId': draft.accountId,
          'description': ?draft.description,
          'dueDate': ?dueDate,
          'status': DebtStatus.active.id,
          'createdAt': ServerValue.timestamp,
          'updatedAt': ServerValue.timestamp,
        },
      },
      effect: LedgerEffect.fromTransaction(tx),
    );
  }

  Future<void> update(MoneyTransaction previous, MoneyTransaction next) async {
    if (previous.type == TxType.lent ||
        previous.type == TxType.borrowed ||
        previous.type == TxType.debtPayment) {
      throw const AppFailure(
        'Debt transactions cannot be edited. Delete and record again if needed.',
      );
    }
    _validateAmount(next.amount);
    if (next.type == TxType.transfer &&
        next.fromAccountId == next.toAccountId) {
      throw const AppFailure('From and to accounts must be different.');
    }

    final paths = RtdbPaths(CurrentUid.require());
    final reverse = LedgerEffect.fromTransaction(previous).reverse();
    final apply = LedgerEffect.fromTransaction(next);
    final combined = LedgerEffect(
      accountDeltas: _mergeDeltas(reverse.accountDeltas, apply.accountDeltas),
      incomeDelta: reverse.incomeDelta + apply.incomeDelta,
      expenseDelta: reverse.expenseDelta + apply.expenseDelta,
      lentDelta: reverse.lentDelta + apply.lentDelta,
      borrowedDelta: reverse.borrowedDelta + apply.borrowedDelta,
    );

    await _engine.commit(
      writes: {
        paths.transaction(previous.id): next.toMap()
          ..['createdAt'] = previous.createdAt
          ..['updatedAt'] = ServerValue.timestamp,
      },
      effect: combined,
    );
  }

  Future<void> delete(MoneyTransaction tx) async {
    if (tx.type == TxType.lent || tx.type == TxType.borrowed) {
      throw const AppFailure(
        'Delete this from the debt instead so payment history stays consistent.',
      );
    }
    if (tx.type == TxType.debtPayment) {
      throw const AppFailure('Debt payments cannot be deleted directly.');
    }

    final paths = RtdbPaths(CurrentUid.require());
    await _engine.commit(
      writes: {paths.transaction(tx.id): null},
      effect: LedgerEffect.fromTransaction(tx).reverse(),
    );
  }

  Future<void> _saveNew(MoneyTransaction draft, LedgerEffect effect) async {
    final paths = RtdbPaths(CurrentUid.require());
    final id = _engine.newId(paths.transactions);
    await _engine.commit(
      writes: {
        paths.transaction(id): draft.toMap()
          ..['createdAt'] = ServerValue.timestamp
          ..['updatedAt'] = ServerValue.timestamp,
      },
      effect: effect,
    );
  }

  Map<String, num> _mergeDeltas(Map<String, num> a, Map<String, num> b) {
    final merged = Map<String, num>.from(a);
    b.forEach((key, value) {
      merged[key] = (merged[key] ?? 0) + value;
    });
    return merged;
  }

  void _validateAmount(num amount) {
    if (amount <= 0) {
      throw const AppFailure('Amount must be greater than zero.');
    }
  }
}
