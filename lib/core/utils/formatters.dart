import 'package:intl/intl.dart';

class Formatters {
  // ------------------------------
  // Date Formatters
  // ------------------------------

  /// Formats date to: 12 Jan 2025
  static String formatDate(DateTime date) {
    return DateFormat("dd MMM yyyy").format(date);
  }

  /// Formats to: Jan 12, 2025 • 5:30 PM
  static String formatDateTime(DateTime date) {
    return DateFormat("MMM dd, yyyy • hh:mm a").format(date);
  }

  /// Returns time: 5:30 PM
  static String formatTime(DateTime date) {
    return DateFormat("hh:mm a").format(date);
  }

  // ------------------------------
  // String Formatters
  // ------------------------------

  /// Capitalizes the first letter of a name
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Trims spaces, converts consecutive spaces to single space
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r"\s+"), " ");
  }

  // ------------------------------
  // Phone Formatters
  // ------------------------------

  /// Formats phone numbers: +91 XXXXX XXXXX
  static String formatPhone(String phone) {
    if (phone.length < 10) return phone;
    final cleaned = phone.replaceAll(" ", "");
    return "+91 ${cleaned.substring(0, 5)} ${cleaned.substring(5)}";
  }

  // ------------------------------
  // File Size Formatter
  // ------------------------------

  /// Converts bytes → KB/MB/GB
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(2)} KB";
    if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    }
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
  }

  // ------------------------------
  // Short Text Formatter
  // ------------------------------

  /// Shortens long text for cards/list items
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return "${text.substring(0, maxLength)}...";
  }
}
