Map<String, Map<Object?, Object?>> asChildMap(Object? value) {
  if (value is! Map) return {};
  final result = <String, Map<Object?, Object?>>{};
  value.forEach((key, child) {
    if (child is Map) {
      result[key.toString()] = Map<Object?, Object?>.from(child);
    }
  });
  return result;
}

Map<Object?, Object?>? asObjectMap(Object? value) {
  if (value is! Map) return null;
  return Map<Object?, Object?>.from(value);
}
