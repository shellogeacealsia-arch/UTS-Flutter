/// Formatting helpers (Indonesian Rupiah, dates).
class Formatters {
  Formatters._();

  /// 125000 -> "Rp 125.000"
  static String rupiah(int amount) {
    final negative = amount < 0;
    final digits = amount.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${negative ? '-' : ''}Rp $buffer';
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// "10 Oct 2026, 14:30"
  static String dateTime(DateTime d) {
    return '${d.day} ${_months[d.month - 1]} ${d.year}, '
        '${_two(d.hour)}:${_two(d.minute)}';
  }

  /// 1243 -> "1.2k", 87 -> "87"
  static String compactCount(int n) {
    if (n < 1000) return n.toString();
    return '${(n / 1000).toStringAsFixed(1)}k';
  }
}
