enum DebtKind { lent, borrowed }

enum DebtStatus { active, partiallyPaid, paid, overdue, cancelled }

extension DebtKindX on DebtKind {
  String get id => this == DebtKind.lent ? 'lent' : 'borrowed';

  static DebtKind fromId(String? raw) =>
      raw == 'borrowed' ? DebtKind.borrowed : DebtKind.lent;
}

extension DebtStatusX on DebtStatus {
  String get id => switch (this) {
    DebtStatus.active => 'active',
    DebtStatus.partiallyPaid => 'partially_paid',
    DebtStatus.paid => 'paid',
    DebtStatus.overdue => 'overdue',
    DebtStatus.cancelled => 'cancelled',
  };

  String get label => switch (this) {
    DebtStatus.active => 'Active',
    DebtStatus.partiallyPaid => 'Partially paid',
    DebtStatus.paid => 'Paid',
    DebtStatus.overdue => 'Overdue',
    DebtStatus.cancelled => 'Cancelled',
  };

  static DebtStatus fromId(String? raw) {
    return switch (raw) {
      'partially_paid' => DebtStatus.partiallyPaid,
      'paid' => DebtStatus.paid,
      'overdue' => DebtStatus.overdue,
      'cancelled' => DebtStatus.cancelled,
      _ => DebtStatus.active,
    };
  }
}

class DebtPayment {
  const DebtPayment({
    required this.id,
    required this.amount,
    required this.accountId,
    required this.paymentDate,
  });

  final String id;
  final num amount;
  final String accountId;
  final int paymentDate;

  factory DebtPayment.fromMap(String id, Map<Object?, Object?> data) {
    return DebtPayment(
      id: id,
      amount: (data['amount'] as num?) ?? 0,
      accountId: data['accountId'] as String? ?? '',
      paymentDate: (data['paymentDate'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, Object?> toMap() => {
    'amount': amount,
    'accountId': accountId,
    'paymentDate': paymentDate,
  };
}

class Debt {
  const Debt({
    required this.id,
    required this.type,
    required this.personName,
    required this.originalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.currency,
    required this.accountId,
    required this.status,
    this.personPhone,
    this.description,
    this.dueDate,
    this.payments = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final DebtKind type;
  final String personName;
  final String? personPhone;
  final num originalAmount;
  final num paidAmount;
  final num remainingAmount;
  final String currency;
  final String accountId;
  final String? description;
  final int? dueDate;
  final DebtStatus status;
  final List<DebtPayment> payments;
  final int? createdAt;
  final int? updatedAt;

  bool get isOpen =>
      status != DebtStatus.paid && status != DebtStatus.cancelled;

  factory Debt.fromMap(String id, Map<Object?, Object?> data) {
    final paymentsRaw = data['payments'];
    final payments = <DebtPayment>[];
    if (paymentsRaw is Map) {
      paymentsRaw.forEach((key, value) {
        if (value is Map) {
          payments.add(
            DebtPayment.fromMap(
              key.toString(),
              Map<Object?, Object?>.from(value),
            ),
          );
        }
      });
    }

    final remaining = (data['remainingAmount'] as num?) ?? 0;
    final stored = DebtStatusX.fromId(data['status'] as String?);
    final due = (data['dueDate'] as num?)?.toInt();
    final overdue =
        remaining > 0 &&
        stored != DebtStatus.cancelled &&
        stored != DebtStatus.paid &&
        due != null &&
        due < DateTime.now().millisecondsSinceEpoch;

    return Debt(
      id: id,
      type: DebtKindX.fromId(data['type'] as String?),
      personName: (data['person'] is Map)
          ? ((data['person'] as Map)['name'] as String? ?? 'Someone')
          : 'Someone',
      personPhone: (data['person'] is Map)
          ? (data['person'] as Map)['phone'] as String?
          : null,
      originalAmount: (data['originalAmount'] as num?) ?? 0,
      paidAmount: (data['paidAmount'] as num?) ?? 0,
      remainingAmount: remaining,
      currency: data['currency'] as String? ?? 'TZS',
      accountId: data['accountId'] as String? ?? '',
      description: data['description'] as String?,
      dueDate: due,
      status: overdue ? DebtStatus.overdue : stored,
      payments: payments,
      createdAt: (data['createdAt'] as num?)?.toInt(),
      updatedAt: (data['updatedAt'] as num?)?.toInt(),
    );
  }

  static String statusFor({required num remaining, required num paid}) {
    if (remaining <= 0) return DebtStatus.paid.id;
    if (paid > 0) return DebtStatus.partiallyPaid.id;
    return DebtStatus.active.id;
  }
}
