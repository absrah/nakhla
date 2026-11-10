/// Money as the app shows it: SAR 1,499 or SAR 79.50.
String formatSar(double value) {
  final isWhole = value.truncateToDouble() == value;
  final parts = value.toStringAsFixed(isWhole ? 0 : 2).split('.');
  final grouped = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return parts.length > 1 ? 'SAR $grouped.${parts[1]}' : 'SAR $grouped';
}

/// Review counts: 932 stays 932, 2184 becomes 2.2k.
String formatCount(int count) {
  if (count < 1000) return '$count';
  final thousands = (count / 1000).toStringAsFixed(1);
  final clean = thousands.endsWith('.0')
      ? thousands.substring(0, thousands.length - 2)
      : thousands;
  return '${clean}k';
}

/// "smart-home" becomes "SMART HOME" (the small label on product images).
String slugToLabel(String slug) => slug.replaceAll('-', ' ').toUpperCase();

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "8 Nov 2026, 08:50" in the phone's local time.
String formatOrderDate(DateTime date) {
  final d = date.toLocal();
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${_months[d.month - 1]} ${d.year}, $hh:$mm';
}