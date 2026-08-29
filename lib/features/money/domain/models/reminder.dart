enum ReminderType { payment, collection, purchase, general }

extension ReminderTypeX on ReminderType {
  String get id => name;

  String get label => switch (this) {
    ReminderType.payment => 'Payment',
    ReminderType.collection => 'Collection',
    ReminderType.purchase => 'Purchase',
    ReminderType.general => 'General',
  };

  static ReminderType fromId(String? raw) {
    return switch (raw) {
      'payment' => ReminderType.payment,
      'collection' => ReminderType.collection,
      'purchase' => ReminderType.purchase,
      _ => ReminderType.general,
    };
  }
}

class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.type,
    required this.reminderDate,
    required this.isCompleted,
    required this.isCancelled,
    this.amount,
    this.currency,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final ReminderType type;
  final int reminderDate;
  final bool isCompleted;
  final bool isCancelled;
  final num? amount;
  final String? currency;
  final String? description;
  final int? createdAt;
  final int? updatedAt;

  bool get isOverdue {
    if (isCompleted || isCancelled) return false;
    return reminderDate < DateTime.now().millisecondsSinceEpoch;
  }

  bool get isUpcoming {
    if (isCompleted || isCancelled) return false;
    return reminderDate >= DateTime.now().millisecondsSinceEpoch;
  }

  factory Reminder.fromMap(String id, Map<Object?, Object?> data) {
    return Reminder(
      id: id,
      title: data['title'] as String? ?? 'Reminder',
      type: ReminderTypeX.fromId(data['type'] as String?),
      reminderDate: (data['reminderDate'] as num?)?.toInt() ?? 0,
      isCompleted: data['isCompleted'] as bool? ?? false,
      isCancelled: data['isCancelled'] as bool? ?? false,
      amount: data['amount'] as num?,
      currency: data['currency'] as String?,
      description: data['description'] as String?,
      createdAt: (data['createdAt'] as num?)?.toInt(),
      updatedAt: (data['updatedAt'] as num?)?.toInt(),
    );
  }

  Map<String, Object?> toMap() => {
    'title': title,
    'type': type.id,
    'reminderDate': reminderDate,
    'isCompleted': isCompleted,
    'isCancelled': isCancelled,
    if (amount != null) 'amount': amount,
    if (currency != null) 'currency': currency,
    if (description != null) 'description': description,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
