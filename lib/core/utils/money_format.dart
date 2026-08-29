class MoneyFormat {
  MoneyFormat._();

  static String format(num amount, {String currency = 'TZS'}) {
    final negative = amount < 0;
    final whole = amount.abs().round();
    final digits = whole.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final fromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return '${negative ? '-' : ''}$currency ${buffer.toString()}';
  }

  static String signed(num amount, {String currency = 'TZS'}) {
    if (amount > 0) return '+${format(amount, currency: currency)}';
    return format(amount, currency: currency);
  }

  static num? parse(String? raw) {
    if (raw == null) return null;
    final cleaned = raw.trim().replaceAll(',', '');
    if (cleaned.isEmpty) return null;
    return num.tryParse(cleaned);
  }
}
