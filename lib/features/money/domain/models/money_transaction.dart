enum TxType {
  earned,
  sold,
  received,
  refund,
  bought,
  paid,
  spent,
  borrowed,
  lent,
  debtPayment,
  transfer,
  openingBalance,
}

enum TxDirection { income, expense, transfer, debt, opening }

extension TxTypeX on TxType {
  String get id => switch (this) {
    TxType.earned => 'earned',
    TxType.sold => 'sold',
    TxType.received => 'received',
    TxType.refund => 'refund',
    TxType.bought => 'bought',
    TxType.paid => 'paid',
    TxType.spent => 'spent',
    TxType.borrowed => 'borrowed',
    TxType.lent => 'lent',
    TxType.debtPayment => 'debt_payment',
    TxType.transfer => 'transfer',
    TxType.openingBalance => 'opening_balance',
  };

  String get label => switch (this) {
    TxType.earned => 'Earned',
    TxType.sold => 'Sold',
    TxType.received => 'Received',
    TxType.refund => 'Refund',
    TxType.bought => 'Bought',
    TxType.paid => 'Paid',
    TxType.spent => 'Spent',
    TxType.borrowed => 'Borrowed',
    TxType.lent => 'Lent',
    TxType.debtPayment => 'Debt payment',
    TxType.transfer => 'Transfer',
    TxType.openingBalance => 'Opening balance',
  };

  TxDirection get direction => switch (this) {
    TxType.earned ||
    TxType.sold ||
    TxType.received ||
    TxType.refund => TxDirection.income,
    TxType.bought || TxType.paid || TxType.spent => TxDirection.expense,
    TxType.transfer => TxDirection.transfer,
    TxType.openingBalance => TxDirection.opening,
    TxType.borrowed || TxType.lent || TxType.debtPayment => TxDirection.debt,
  };

  static TxType fromId(String? raw) {
    return switch (raw) {
      'sold' => TxType.sold,
      'received' => TxType.received,
      'refund' => TxType.refund,
      'bought' => TxType.bought,
      'paid' => TxType.paid,
      'spent' => TxType.spent,
      'borrowed' => TxType.borrowed,
      'lent' => TxType.lent,
      'debt_payment' => TxType.debtPayment,
      'transfer' => TxType.transfer,
      'opening_balance' => TxType.openingBalance,
      _ => TxType.earned,
    };
  }
}

class TransferFee {
  const TransferFee({
    required this.amount,
    required this.currency,
    this.categoryId,
    this.description,
  });

  final num amount;
  final String currency;
  final String? categoryId;
  final String? description;

  factory TransferFee.fromMap(Map<Object?, Object?> data) {
    return TransferFee(
      amount: (data['amount'] as num?) ?? 0,
      currency: data['currency'] as String? ?? 'TZS',
      categoryId: data['categoryId'] as String?,
      description: data['description'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
    'amount': amount,
    'currency': currency,
    if (categoryId != null) 'categoryId': categoryId,
    if (description != null) 'description': description,
  };
}

class MoneyTransaction {
  const MoneyTransaction({
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.currency,
    required this.transactionDate,
    this.accountId,
    this.fromAccountId,
    this.toAccountId,
    this.categoryId,
    this.description,
    this.fee,
    this.debtId,
    this.personName,
    this.personPhone,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final TxType type;
  final TxDirection direction;
  final num amount;
  final String currency;
  final int transactionDate;
  final String? accountId;
  final String? fromAccountId;
  final String? toAccountId;
  final String? categoryId;
  final String? description;
  final TransferFee? fee;
  final String? debtId;
  final String? personName;
  final String? personPhone;
  final int? dueDate;
  final int? createdAt;
  final int? updatedAt;

  factory MoneyTransaction.fromMap(String id, Map<Object?, Object?> data) {
    final type = TxTypeX.fromId(data['type'] as String?);
    final feeRaw = data['fee'];
    return MoneyTransaction(
      id: id,
      type: type,
      direction: type.direction,
      amount: (data['amount'] as num?) ?? 0,
      currency: data['currency'] as String? ?? 'TZS',
      transactionDate: (data['transactionDate'] as num?)?.toInt() ?? 0,
      accountId: data['accountId'] as String?,
      fromAccountId: data['fromAccountId'] as String?,
      toAccountId: data['toAccountId'] as String?,
      categoryId: data['categoryId'] as String?,
      description: data['description'] as String?,
      fee: feeRaw is Map
          ? TransferFee.fromMap(Map<Object?, Object?>.from(feeRaw))
          : null,
      debtId: data['debtId'] as String?,
      personName: data['personName'] as String?,
      personPhone: data['personPhone'] as String?,
      dueDate: (data['dueDate'] as num?)?.toInt(),
      createdAt: (data['createdAt'] as num?)?.toInt(),
      updatedAt: (data['updatedAt'] as num?)?.toInt(),
    );
  }

  Map<String, Object?> toMap() => {
    'type': type.id,
    'direction': direction.name,
    'amount': amount,
    'currency': currency,
    'transactionDate': transactionDate,
    if (accountId != null) 'accountId': accountId,
    if (fromAccountId != null) 'fromAccountId': fromAccountId,
    if (toAccountId != null) 'toAccountId': toAccountId,
    if (categoryId != null) 'categoryId': categoryId,
    if (description != null) 'description': description,
    if (fee != null) 'fee': fee!.toMap(),
    if (debtId != null) 'debtId': debtId,
    if (personName != null) 'personName': personName,
    if (personPhone != null) 'personPhone': personPhone,
    if (dueDate != null) 'dueDate': dueDate,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  String get displayDescription {
    if (description != null && description!.trim().isNotEmpty) {
      return description!.trim();
    }
    return type.label;
  }
}
