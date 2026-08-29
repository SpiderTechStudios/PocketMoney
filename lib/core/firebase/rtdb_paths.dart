class RtdbPaths {
  RtdbPaths(this.uid);

  final String uid;

  String get root => 'users/$uid';
  String get profile => '$root/profile';
  String get settings => '$root/settings';
  String get accounts => '$root/accounts';
  String get categories => '$root/categories';
  String get transactions => '$root/transactions';
  String get debts => '$root/debts';
  String get reminders => '$root/reminders';
  String get dashboard => '$root/dashboard';

  String account(String id) => '$accounts/$id';
  String category(String id) => '$categories/$id';
  String transaction(String id) => '$transactions/$id';
  String debt(String id) => '$debts/$id';
  String reminder(String id) => '$reminders/$id';
  String debtPayment(String debtId, String paymentId) =>
      '$debts/$debtId/payments/$paymentId';
}
