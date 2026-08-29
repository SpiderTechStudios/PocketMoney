import 'models/money_transaction.dart';

/// Pure financial effect derived from a transaction.
/// Account balances are the source of truth; dashboard totals follow these deltas.
class LedgerEffect {
  const LedgerEffect({
    this.accountDeltas = const {},
    this.incomeDelta = 0,
    this.expenseDelta = 0,
    this.lentDelta = 0,
    this.borrowedDelta = 0,
  });

  final Map<String, num> accountDeltas;
  final num incomeDelta;
  final num expenseDelta;
  final num lentDelta;
  final num borrowedDelta;

  num get totalBalanceDelta =>
      accountDeltas.values.fold<num>(0, (sum, item) => sum + item);

  LedgerEffect reverse() {
    return LedgerEffect(
      accountDeltas: {
        for (final entry in accountDeltas.entries) entry.key: -entry.value,
      },
      incomeDelta: -incomeDelta,
      expenseDelta: -expenseDelta,
      lentDelta: -lentDelta,
      borrowedDelta: -borrowedDelta,
    );
  }

  factory LedgerEffect.fromTransaction(MoneyTransaction tx) {
    final fee = tx.fee?.amount ?? 0;
    switch (tx.type) {
      case TxType.earned:
      case TxType.sold:
      case TxType.received:
      case TxType.refund:
        return LedgerEffect(
          accountDeltas: {if (tx.accountId != null) tx.accountId!: tx.amount},
          incomeDelta: tx.amount,
        );
      case TxType.bought:
      case TxType.paid:
      case TxType.spent:
        return LedgerEffect(
          accountDeltas: {if (tx.accountId != null) tx.accountId!: -tx.amount},
          expenseDelta: tx.amount,
        );
      case TxType.openingBalance:
        return LedgerEffect(
          accountDeltas: {if (tx.accountId != null) tx.accountId!: tx.amount},
        );
      case TxType.transfer:
        final from = tx.fromAccountId;
        final to = tx.toAccountId;
        return LedgerEffect(
          accountDeltas: {
            ?from: -(tx.amount + fee),
            ?to: tx.amount,
          },
          expenseDelta: fee,
        );
      case TxType.lent:
        return LedgerEffect(
          accountDeltas: {if (tx.accountId != null) tx.accountId!: -tx.amount},
          lentDelta: tx.amount,
        );
      case TxType.borrowed:
        return LedgerEffect(
          accountDeltas: {if (tx.accountId != null) tx.accountId!: tx.amount},
          borrowedDelta: tx.amount,
        );
      case TxType.debtPayment:
        // Sign depends on whether the original debt was lent or borrowed.
        // Caller should use [forDebtPayment] instead when the kind is known.
        return LedgerEffect(
          accountDeltas: {if (tx.accountId != null) tx.accountId!: tx.amount},
        );
    }
  }

  factory LedgerEffect.forDebtPayment({
    required bool isLent,
    required String accountId,
    required num amount,
  }) {
    if (isLent) {
      return LedgerEffect(
        accountDeltas: {accountId: amount},
        lentDelta: -amount,
      );
    }
    return LedgerEffect(
      accountDeltas: {accountId: -amount},
      borrowedDelta: -amount,
    );
  }
}
