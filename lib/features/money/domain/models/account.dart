enum AccountType { cash, bank, mobileMoney, savings, other }

extension AccountTypeX on AccountType {
  String get id => switch (this) {
    AccountType.cash => 'cash',
    AccountType.bank => 'bank',
    AccountType.mobileMoney => 'mobile_money',
    AccountType.savings => 'savings',
    AccountType.other => 'other',
  };

  String get label => switch (this) {
    AccountType.cash => 'Cash',
    AccountType.bank => 'Bank',
    AccountType.mobileMoney => 'Mobile money',
    AccountType.savings => 'Savings',
    AccountType.other => 'Other',
  };

  static AccountType fromId(String? raw) {
    return switch (raw) {
      'bank' => AccountType.bank,
      'mobile_money' => AccountType.mobileMoney,
      'savings' => AccountType.savings,
      'other' => AccountType.other,
      _ => AccountType.cash,
    };
  }
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.isActive,
    this.provider,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final AccountType type;
  final num balance;
  final String currency;
  final bool isActive;
  final String? provider;
  final int? createdAt;
  final int? updatedAt;

  factory Account.fromMap(String id, Map<Object?, Object?> data) {
    return Account(
      id: id,
      name: data['name'] as String? ?? 'Account',
      type: AccountTypeX.fromId(data['type'] as String?),
      balance: (data['balance'] as num?) ?? 0,
      currency: data['currency'] as String? ?? 'TZS',
      isActive: data['isActive'] as bool? ?? true,
      provider: data['provider'] as String?,
      createdAt: _asInt(data['createdAt']),
      updatedAt: _asInt(data['updatedAt']),
    );
  }

  Map<String, Object?> toMap() => {
    'name': name,
    'type': type.id,
    'balance': balance,
    'currency': currency,
    'isActive': isActive,
    if (provider != null && provider!.isNotEmpty) 'provider': provider,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  static int? _asInt(Object? value) => value is num ? value.toInt() : null;
}
