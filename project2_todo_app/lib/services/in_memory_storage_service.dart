import 'dart:convert';
import '../models/task.dart';
import 'storage_service.dart';

/// In-memory storage implementation.
/// Ideal for testing, DartPad web environments, or as a fast zero-dependency fallback.
/// It simulates persistent JSON string storage to verify serialization round-trips.
class InMemoryStorageService implements StorageService {
  String? _serializedTasks;
  bool _isDarkMode = false;

  InMemoryStorageService({List<Task>? initialTasks, bool initialDarkMode = false}) {
    _isDarkMode = initialDarkMode;
    if (initialTasks != null) {
      saveTasks(initialTasks);
    }
  }

  @override
  Future<List<Task>> loadTasks() async {
    if (_serializedTasks == null || _serializedTasks!.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(_serializedTasks!);
      return decoded
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final List<Map<String, dynamic>> rawList =
        tasks.map((task) => task.toJson()).toList();
    _serializedTasks = jsonEncode(rawList);
  }

  @override
  Future<bool> loadDarkMode() async {
    return _isDarkMode;
  }

  @override
  Future<void> saveDarkMode(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
  }

  /// Helper to clear in-memory state for unit tests.
  void clear() {
    _serializedTasks = null;
    _isDarkMode = false;
  }
}
