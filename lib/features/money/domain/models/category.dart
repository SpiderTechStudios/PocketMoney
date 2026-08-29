enum CategoryKind { income, expense }

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.isDefault,
    required this.isActive,
  });

  final String id;
  final String name;
  final CategoryKind type;
  final String icon;
  final bool isDefault;
  final bool isActive;

  factory Category.fromMap(String id, Map<Object?, Object?> data) {
    return Category(
      id: id,
      name: data['name'] as String? ?? 'Category',
      type: data['type'] == 'income'
          ? CategoryKind.income
          : CategoryKind.expense,
      icon: data['icon'] as String? ?? 'label',
      isDefault: data['isDefault'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, Object?> toMap() => {
    'name': name,
    'type': type == CategoryKind.income ? 'income' : 'expense',
    'icon': icon,
    'isDefault': isDefault,
    'isActive': isActive,
  };
}

class DefaultCategories {
  DefaultCategories._();

  static const expense = <Category>[
    Category(
      id: 'food',
      name: 'Food',
      type: CategoryKind.expense,
      icon: 'restaurant',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'drinks',
      name: 'Drinks',
      type: CategoryKind.expense,
      icon: 'local_bar',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'transport',
      name: 'Transport',
      type: CategoryKind.expense,
      icon: 'directions_bus',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'fuel',
      name: 'Fuel / Mileage',
      type: CategoryKind.expense,
      icon: 'local_gas_station',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'rent',
      name: 'Rent',
      type: CategoryKind.expense,
      icon: 'home',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'utilities',
      name: 'Utilities',
      type: CategoryKind.expense,
      icon: 'bolt',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      type: CategoryKind.expense,
      icon: 'shopping_bag',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'health',
      name: 'Health',
      type: CategoryKind.expense,
      icon: 'health_and_safety',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'education',
      name: 'Education',
      type: CategoryKind.expense,
      icon: 'school',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      type: CategoryKind.expense,
      icon: 'movie',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'transaction_fee',
      name: 'Transaction Fee',
      type: CategoryKind.expense,
      icon: 'receipt_long',
      isDefault: true,
      isActive: true,
    ),
  ];

  static const income = <Category>[
    Category(
      id: 'salary',
      name: 'Salary',
      type: CategoryKind.income,
      icon: 'payments',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'business',
      name: 'Business',
      type: CategoryKind.income,
      icon: 'storefront',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'freelance',
      name: 'Freelance',
      type: CategoryKind.income,
      icon: 'work',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'sales',
      name: 'Sales',
      type: CategoryKind.income,
      icon: 'point_of_sale',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'gift',
      name: 'Gift',
      type: CategoryKind.income,
      icon: 'card_giftcard',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'investment',
      name: 'Investment',
      type: CategoryKind.income,
      icon: 'trending_up',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'refund',
      name: 'Refund',
      type: CategoryKind.income,
      icon: 'replay',
      isDefault: true,
      isActive: true,
    ),
    Category(
      id: 'other_income',
      name: 'Other Income',
      type: CategoryKind.income,
      icon: 'add_card',
      isDefault: true,
      isActive: true,
    ),
  ];

  static List<Category> get all => [...expense, ...income];
}
