import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsHelper {
  static const String _keyIds = 'saved_ids';

  /// **Save a new ID to SharedPreferences**
  static Future<void> saveId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> existingIds = await loadIds();

    String idStr = id.toString(); // Convert int to String

    if (!existingIds.contains(idStr)) {
      existingIds.add(idStr); // Add only if it doesn't exist
      await prefs.setString(_keyIds, jsonEncode(existingIds));
    }
  }

  /// **Load all stored IDs from SharedPreferences**
  static Future<List<String>> loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final String? idsString = prefs.getString(_keyIds);

    if (idsString != null) {
      return List<String>.from(jsonDecode(idsString)); // Decode and return list
    } else {
      return [];
    }
  }

  /// **Remove a specific ID from SharedPreferences**
  static Future<void> removeId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> existingIds = await loadIds();

    existingIds.remove(id.toString()); // Remove ID
    await prefs.setString(_keyIds, jsonEncode(existingIds));
  }

  /// **Clear all stored IDs**
  static Future<void> clearIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIds);
  }
}
