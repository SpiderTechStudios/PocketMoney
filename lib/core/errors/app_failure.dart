class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  factory AppFailure.from(Object error) {
    if (error is AppFailure) return error;
    final raw = error.toString().toLowerCase();
    if (raw.contains('permission') || raw.contains('permission_denied')) {
      return const AppFailure(
        'You do not have permission to update this data.',
      );
    }
    if (raw.contains('network') || raw.contains('socket')) {
      return const AppFailure(
        'Please check your internet connection and try again.',
      );
    }
    return const AppFailure('Something went wrong. Please try again.');
  }

  @override
  String toString() => message;
}
