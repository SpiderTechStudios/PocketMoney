import 'package:flutter_test/flutter_test.dart';
import 'package:pocketmoney/features/money/domain/ledger_effect.dart';
import 'package:pocketmoney/features/money/domain/models/money_transaction.dart';

MoneyTransaction _tx({
  required TxType type,
  required num amount,
  String? accountId,
  String? from,
  String? to,
  num fee = 0,
}) {
  return MoneyTransaction(
    id: 't1',
    type: type,
    direction: type.direction,
    amount: amount,
    currency: 'TZS',
    transactionDate: 1,
    accountId: accountId,
    fromAccountId: from,
    toAccountId: to,
    fee: fee > 0 ? TransferFee(amount: fee, currency: 'TZS') : null,
  );
}

void main() {
  test('income increases account and income totals', () {
    final effect = LedgerEffect.fromTransaction(
      _tx(type: TxType.earned, amount: 1000, accountId: 'a1'),
    );
    expect(effect.accountDeltas['a1'], 1000);
    expect(effect.incomeDelta, 1000);
    expect(effect.expenseDelta, 0);
    expect(effect.totalBalanceDelta, 1000);
  });

  test('expense decreases account and increases expenses', () {
    final effect = LedgerEffect.fromTransaction(
      _tx(type: TxType.bought, amount: 400, accountId: 'a1'),
    );
    expect(effect.accountDeltas['a1'], -400);
    expect(effect.expenseDelta, 400);
    expect(effect.totalBalanceDelta, -400);
  });

  test('transfer moves money and only fees are expenses', () {
    final effect = LedgerEffect.fromTransaction(
      _tx(
        type: TxType.transfer,
        amount: 50000,
        from: 'mpesa',
        to: 'bank',
        fee: 1000,
      ),
    );
    expect(effect.accountDeltas['mpesa'], -51000);
    expect(effect.accountDeltas['bank'], 50000);
    expect(effect.expenseDelta, 1000);
    expect(effect.incomeDelta, 0);
    expect(effect.totalBalanceDelta, -1000);
  });

  test('opening balance is not income', () {
    final effect = LedgerEffect.fromTransaction(
      _tx(type: TxType.openingBalance, amount: 200, accountId: 'cash'),
    );
    expect(effect.accountDeltas['cash'], 200);
    expect(effect.incomeDelta, 0);
    expect(effect.totalBalanceDelta, 200);
  });

  test('lent and borrowed update debt totals', () {
    final lent = LedgerEffect.fromTransaction(
      _tx(type: TxType.lent, amount: 80, accountId: 'a1'),
    );
    expect(lent.accountDeltas['a1'], -80);
    expect(lent.lentDelta, 80);

    final borrowed = LedgerEffect.fromTransaction(
      _tx(type: TxType.borrowed, amount: 50, accountId: 'a1'),
    );
    expect(borrowed.accountDeltas['a1'], 50);
    expect(borrowed.borrowedDelta, 50);
  });

  test('debt repayment reverses remaining debt', () {
    final collection = LedgerEffect.forDebtPayment(
      isLent: true,
      accountId: 'a1',
      amount: 20,
    );
    expect(collection.accountDeltas['a1'], 20);
    expect(collection.lentDelta, -20);

    final repay = LedgerEffect.forDebtPayment(
      isLent: false,
      accountId: 'a1',
      amount: 20,
    );
    expect(repay.accountDeltas['a1'], -20);
    expect(repay.borrowedDelta, -20);
  });

  test('reverse undoes an effect', () {
    final effect = LedgerEffect.fromTransaction(
      _tx(type: TxType.spent, amount: 10, accountId: 'a1'),
    ).reverse();
    expect(effect.accountDeltas['a1'], 10);
    expect(effect.expenseDelta, -10);
  });
}
