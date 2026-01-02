import 'package:shared_preferences/shared_preferences.dart';

class StreakManager {
  static const String _lastOpenDateKey = 'last_open_date';
  static const String _streakCountKey = 'learning_streak';

  /// Call this once when app/dashboard opens
  static Future<int> updateAndGetStreak() async {
    final prefs = await SharedPreferences.getInstance();

    final today = _dateOnly(DateTime.now());
    final todayKey = _dateKey(today);

    final lastDateKey = prefs.getString(_lastOpenDateKey);
    int streak = prefs.getInt(_streakCountKey) ?? 0;

    if (lastDateKey == null) {
      // First ever app open
      streak = 1;
    } else {
      final lastDate = _parseDateKey(lastDateKey);
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        // Continued streak
        streak += 1;
      } else if (difference > 1) {
        // Streak broken
        streak = 1;
      }
      // difference == 0 → same day, do nothing
    }

    await prefs.setString(_lastOpenDateKey, todayKey);
    await prefs.setInt(_streakCountKey, streak);

    return streak;
  }

  /// Read streak without modifying
  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakCountKey) ?? 0;
  }

  // ================= HELPERS =================

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String _dateKey(DateTime date) {
    // YYYY-MM-DD (timezone safe)
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  static DateTime _parseDateKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
