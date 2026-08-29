class AppDateFormat {
  AppDateFormat._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static DateTime fromMillis(int millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis);

  static String short(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  static String relative(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final a = DateTime(date.year, date.month, date.day);
    final b = DateTime(today.year, today.month, today.day);
    final diff = a.difference(b).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return short(date);
  }

  static String greeting({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
