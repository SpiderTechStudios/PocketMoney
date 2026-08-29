class UserSettings {
  const UserSettings({
    required this.currency,
    required this.language,
    required this.theme,
    required this.notificationsEnabled,
    required this.remindersEnabled,
    this.updatedAt,
  });

  final String currency;
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final bool remindersEnabled;
  final int? updatedAt;

  static const defaults = UserSettings(
    currency: 'TZS',
    language: 'en',
    theme: 'system',
    notificationsEnabled: true,
    remindersEnabled: true,
  );

  factory UserSettings.fromMap(Map<Object?, Object?> data) {
    return UserSettings(
      currency: data['currency'] as String? ?? 'TZS',
      language: data['language'] as String? ?? 'en',
      theme: data['theme'] as String? ?? 'system',
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      remindersEnabled: data['remindersEnabled'] as bool? ?? true,
      updatedAt: (data['updatedAt'] as num?)?.toInt(),
    );
  }

  Map<String, Object?> toMap() => {
    'currency': currency,
    'language': language,
    'theme': theme,
    'notificationsEnabled': notificationsEnabled,
    'remindersEnabled': remindersEnabled,
    'updatedAt': updatedAt,
  };

  UserSettings copyWith({
    String? currency,
    String? language,
    String? theme,
    bool? notificationsEnabled,
    bool? remindersEnabled,
  }) {
    return UserSettings(
      currency: currency ?? this.currency,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      updatedAt: updatedAt,
    );
  }
}

class DashboardSummary {
  const DashboardSummary({
    this.totalBalance = 0,
    this.totalIncome = 0,
    this.totalExpenses = 0,
    this.totalLent = 0,
    this.totalBorrowed = 0,
    this.updatedAt,
  });

  final num totalBalance;
  final num totalIncome;
  final num totalExpenses;
  final num totalLent;
  final num totalBorrowed;
  final int? updatedAt;

  factory DashboardSummary.fromMap(Map<Object?, Object?> data) {
    return DashboardSummary(
      totalBalance: (data['totalBalance'] as num?) ?? 0,
      totalIncome: (data['totalIncome'] as num?) ?? 0,
      totalExpenses: (data['totalExpenses'] as num?) ?? 0,
      totalLent: (data['totalLent'] as num?) ?? 0,
      totalBorrowed: (data['totalBorrowed'] as num?) ?? 0,
      updatedAt: (data['updatedAt'] as num?)?.toInt(),
    );
  }

  static DashboardSummary fromAccounts({
    required Iterable<num> balances,
    required num income,
    required num expenses,
    required num lent,
    required num borrowed,
  }) {
    return DashboardSummary(
      totalBalance: balances.fold<num>(0, (sum, item) => sum + item),
      totalIncome: income,
      totalExpenses: expenses,
      totalLent: lent,
      totalBorrowed: borrowed,
    );
  }
}
