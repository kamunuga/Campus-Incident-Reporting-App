import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final DateFormat _full = DateFormat('d MMM yyyy, HH:mm');
  static final DateFormat _short = DateFormat('d MMM');

  static String dateTime(DateTime value) => _full.format(value);

  static String timeAgo(DateTime value, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(value);
    if (diff.isNegative || diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _short.format(value);
  }
}
