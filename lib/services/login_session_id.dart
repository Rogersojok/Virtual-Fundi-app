import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _userKey = 'current_user';

  /// Save logged-in user ID
  static Future<void> saveCurrentUser(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userEmail);
  }

  /// Get current logged-in user ID
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  /// Clear logged-in user ID (e.g., logout)
  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
