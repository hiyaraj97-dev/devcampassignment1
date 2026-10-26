import '../models/task.dart';

/// Abstract contract for task and preference persistence.
/// This allows pluggable backends: SharedPreferences, SQLite, Hive, or In-Memory mocks.
abstract class StorageService {
  /// Loads all saved tasks from persistent storage.
  Future<List<Task>> loadTasks();

  /// Persists the list of tasks to storage.
  Future<void> saveTasks(List<Task> tasks);

  /// Loads the persisted dark mode preference. Defaults to false (Light mode).
  Future<bool> loadDarkMode();

  /// Persists the dark mode preference.
  Future<void> saveDarkMode(bool isDarkMode);
}
