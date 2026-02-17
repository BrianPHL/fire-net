import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Helpers {
  Helpers._();

  /// Format timestamp to time string (e.g., "10:52 PM")
  static String formatTime(DateTime dateTime) {
    return DateFormat(AppConstants.timeFormat).format(dateTime);
  }

  /// Format timestamp to date string (e.g., "Feb 9")
  static String formatDate(DateTime dateTime) {
    return DateFormat(AppConstants.dateFormat).format(dateTime);
  }

  /// Format timestamp to full date string (e.g., "Feb 9, 2026")
  static String formatFullDate(DateTime dateTime) {
    return DateFormat(AppConstants.fullDateFormat).format(dateTime);
  }

  /// Format timestamp to date and time (e.g., "Feb 9, 2026 • 10:52 PM")
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  /// Get relative time string (e.g., "8m ago", "2h ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Format sensor reading with unit
  static String formatSensorReading(double value, String unit) {
    return '${value.toStringAsFixed(1)} $unit';
  }
}
