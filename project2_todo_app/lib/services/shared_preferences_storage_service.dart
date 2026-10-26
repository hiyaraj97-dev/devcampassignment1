import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'storage_service.dart';

/// Concrete [StorageService] implementation backed by SharedPreferences.
/// Meets the DevCamp 2.0 key-value small-data persistence requirement.
class SharedPreferencesStorageService implements StorageService {
  static const String _tasksKey = 'devcamp_todo_tasks_v1';
  static const String _darkModeKey = 'devcamp_todo_dark_mode_v1';

  final SharedPreferences _prefs;

  SharedPreferencesStorageService(this._prefs);

  /// Factory initializer that retrieves the SharedPreferences async instance.
  static Future<SharedPreferencesStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesStorageService(prefs);
  }

  @override
  Future<List<Task>> loadTasks() async {
    final jsonString = _prefs.getString(_tasksKey);
    if (jsonString == null || jsonString.trim().isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // In case of corrupt data, return empty list gracefully
      return [];
    }
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final rawList = tasks.map((t) => t.toJson()).toList();
    final jsonString = jsonEncode(rawList);
    await _prefs.setString(_tasksKey, jsonString);
  }

  @override
  Future<bool> loadDarkMode() async {
    return _prefs.getBool(_darkModeKey) ?? false;
  }

  @override
  Future<void> saveDarkMode(bool isDarkMode) async {
    await _prefs.setBool(_darkModeKey, isDarkMode);
  }
}
