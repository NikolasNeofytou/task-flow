import 'package:intl/intl.dart';

/// Date formatting utilities
class DateFormatters {
  static final _shortDate = DateFormat('MMM d');
  static final _longDate = DateFormat('MMMM d, yyyy');
  static final _time = DateFormat('HH:mm');
  static final _dateTime = DateFormat('MMM d, HH:mm');
  static final _iso = DateFormat("yyyy-MM-ddTHH:mm:ss");

  /// Format date to short format (e.g., "Jan 1")
  static String shortDate(DateTime date) => _shortDate.format(date);

  /// Format date to long format (e.g., "January 1, 2024")
  static String longDate(DateTime date) => _longDate.format(date);

  /// Format time (e.g., "14:30")
  static String time(DateTime date) => _time.format(date);

  /// Format date and time (e.g., "Jan 1, 14:30")
  static String dateTime(DateTime date) => _dateTime.format(date);

  /// Format relative time (e.g., "2 hours ago")
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return shortDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Format to ISO string
  static String iso(DateTime date) => _iso.format(date);
}

/// Number formatting utilities
class NumberFormatters {
  static final _decimal = NumberFormat('#,##0.0#');
  static final _currency = NumberFormat.currency(symbol: '\$');
  static final _percent = NumberFormat.percentPattern();

  /// Format number with decimals
  static String decimal(num number) => _decimal.format(number);

  /// Format as currency
  static String currency(num amount) => _currency.format(amount);

  /// Format as percentage
  static String percent(num ratio) => _percent.format(ratio);

  /// Format file size
  static String fileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
