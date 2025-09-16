import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsHelper {
  static const String _keyIds = 'saved_ids';
  static String _SessionFeedbackKeys = 'sessionFeedback_ids';

  /// **Save a new feedback ID *
  static Future<void> saveId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> existingIds = await loadIds();

    String idStr = id.toString(); // Convert int to String

    if (!existingIds.contains(idStr)) {
      existingIds.add(idStr); // Add only if it doesn't exist
      await prefs.setString(_keyIds, jsonEncode(existingIds));
    }
  }

  /// **Load all stored feedback IDs**
  static Future<List<String>> loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final String? idsString = prefs.getString(_keyIds);

    if (idsString != null) {
      return List<String>.from(jsonDecode(idsString)); // Decode and return list
    } else {
      return [];
    }
  }

  /// **Remove a specific feedback ID from**
  static Future<void> removeId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> existingIds = await loadIds();

    existingIds.remove(id.toString()); // Remove ID
    await prefs.setString(_keyIds, jsonEncode(existingIds));
  }

  /// **Clear all stored  feedback IDs**
  static Future<void> clearIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIds);
  }

  //

  /// **Save a new feedback session ID *
  static Future<void> sessionFeedbackId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> existingIds = await loadSessionFeedbackIds();

    String idStr = id.toString(); // Convert int to String

    if (!existingIds.contains(idStr)) {
      existingIds.add(idStr); // Add only if it doesn't exist
      await prefs.setString(_SessionFeedbackKeys, jsonEncode(existingIds));
    }
  }

  /// **Load all stored session feedback IDs**
  static Future<List<String>> loadSessionFeedbackIds() async {
    final prefs = await SharedPreferences.getInstance();
    final String? idsString = prefs.getString(_SessionFeedbackKeys);

    if (idsString != null) {
      return List<String>.from(jsonDecode(idsString)); // Decode and return list
    } else {
      return [];
    }
  }

  /// **Remove a specific session feedback ID from**
  static Future<void> removeSessionFeedbackId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> existingIds = await loadSessionFeedbackIds();

    existingIds.remove(id.toString()); // Remove ID
    await prefs.setString(_SessionFeedbackKeys, jsonEncode(existingIds));
  }

  /// **Clear all stored session feedback IDs**
  static Future<void> clearSessionFeedbackIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_SessionFeedbackKeys);
  }

}
