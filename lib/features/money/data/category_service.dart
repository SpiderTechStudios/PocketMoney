import 'package:firebase_database/firebase_database.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/firebase/current_uid.dart';
import '../../../core/firebase/rtdb_paths.dart';
import '../domain/models/category.dart';
import 'financial_engine.dart';
import 'rtdb_map.dart';

class CategoryService {
  CategoryService({FirebaseDatabase? database, FinancialEngine? engine})
    : _db = database ?? FirebaseDatabase.instance,
      _engine = engine ?? FinancialEngine.instance;

  final FirebaseDatabase _db;
  final FinancialEngine _engine;

  static final CategoryService instance = CategoryService();

  Stream<List<Category>> watch() {
    final paths = RtdbPaths(CurrentUid.require());
    return _db.ref(paths.categories).onValue.map((event) {
      return asChildMap(event.snapshot.value).entries
          .map((entry) => Category.fromMap(entry.key, entry.value))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> create({
    required String name,
    required CategoryKind type,
    String icon = 'label',
  }) async {
    if (name.trim().isEmpty) {
      throw const AppFailure('Category name is required.');
    }
    final paths = RtdbPaths(CurrentUid.require());
    final id = _engine.newId(paths.categories);
    try {
      await _db.ref(paths.category(id)).set({
        'name': name.trim(),
        'type': type == CategoryKind.income ? 'income' : 'expense',
        'icon': icon,
        'isDefault': false,
        'isActive': true,
      });
    } catch (error) {
      throw AppFailure.from(error);
    }
  }
}
