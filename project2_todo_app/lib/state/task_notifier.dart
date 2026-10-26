import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../models/task_priority.dart';
import '../services/storage_service.dart';
import 'task_filter.dart';

/// Central state notifier managing task CRUD operations, filters, and persistence.
class TaskNotifier extends ChangeNotifier {
  final StorageService _storageService;

  List<Task> _tasks = [];
  TaskFilter _filter = const TaskFilter();
  bool _isLoading = true;
  String? _errorMessage;

  TaskNotifier(this._storageService) {
    loadTasks();
  }

  // Getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  TaskFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;

  /// Percentage progress of completion (0.0 to 1.0).
  double get completionProgress =>
      _tasks.isEmpty ? 0.0 : completedCount / totalCount;

  /// Returns tasks satisfying active filters and sorted intuitively:
  /// Incomplete tasks first, then by priority weight descending, then by creation date.
  List<Task> get filteredTasks {
    final list = _tasks.where((task) => _filter.matches(task)).toList();
    list.sort((a, b) {
      // 1. Completion status (incomplete tasks first)
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // 2. Priority (high to low)
      if (a.priority.weight != b.priority.weight) {
        return b.priority.weight.compareTo(a.priority.weight);
      }
      // 3. Due date (earlier due dates first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }
      // 4. Creation date descending
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  /// Initial load from local storage.
  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _storageService.loadTasks();
    } catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new task with validation and persists to storage.
  Future<bool> addTask({
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.medium,
    TaskCategory category = TaskCategory.personal,
    DateTime? dueDate,
  }) async {
    final validation = Task.validateTitle(title);
    if (validation != null) {
      _errorMessage = validation;
      notifyListeners();
      return false;
    }

    final newTask = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      category: category,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );

    _tasks.insert(0, newTask);
    await _persist();
    notifyListeners();
    return true;
  }

  /// Updates an existing task and persists to storage.
  Future<bool> updateTask({
    required String id,
    required String title,
    String description = '',
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) async {
    final validation = Task.validateTitle(title);
    if (validation != null) {
      _errorMessage = validation;
      notifyListeners();
      return false;
    }

    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return false;

    final existing = _tasks[index];
    _tasks[index] = existing.copyWith(
      title: title.trim(),
      description: description.trim(),
      priority: priority ?? existing.priority,
      category: category ?? existing.category,
      dueDate: clearDueDate ? null : (dueDate ?? existing.dueDate),
      clearDueDate: clearDueDate,
    );

    await _persist();
    notifyListeners();
    return true;
  }

  /// Toggles completion status and visually separates tasks.
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = _tasks[index];
    final newStatus = !task.isCompleted;

    _tasks[index] = task.copyWith(
      isCompleted: newStatus,
      completedAt: newStatus ? DateTime.now() : null,
      clearCompletedAt: !newStatus,
    );

    await _persist();
    notifyListeners();
  }

  /// Deletes a task by its ID and persists changes.
  Future<Task?> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return null;

    final removed = _tasks.removeAt(index);
    await _persist();
    notifyListeners();
    return removed;
  }

  /// Re-inserts a previously deleted task (supports Undo).
  Future<void> restoreTask(Task task, int? preferredIndex) async {
    if (preferredIndex != null && preferredIndex >= 0 && preferredIndex <= _tasks.length) {
      _tasks.insert(preferredIndex, task);
    } else {
      _tasks.add(task);
    }
    await _persist();
    notifyListeners();
  }

  // --- Filtering & Search ---

  void setFilter(TaskFilter newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  void setStatusFilter(TaskFilterStatus status) {
    _filter = _filter.copyWith(status: status);
    notifyListeners();
  }

  void setCategoryFilter(TaskCategory? category) {
    if (_filter.category == category) {
      // Toggle off if already selected
      _filter = _filter.copyWith(clearCategory: true);
    } else {
      _filter = _filter.copyWith(category: category);
    }
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    if (_filter.priority == priority) {
      // Toggle off if already selected
      _filter = _filter.copyWith(clearPriority: true);
    } else {
      _filter = _filter.copyWith(priority: priority);
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _filter = _filter.copyWith(searchQuery: query);
    notifyListeners();
  }

  void clearFilters() {
    _filter = const TaskFilter();
    notifyListeners();
  }

  /// Seeds sample tasks for quick demonstration (satisfying DevCamp demo requirements).
  Future<void> seedSampleTasks() async {
    final now = DateTime.now();
    _tasks = [
      Task(
        id: '1',
        title: 'Review DevCamp Week 2 PDF Specification',
        description: 'Check CRUD, forms, persistent storage, and light/dark theme toggle.',
        isCompleted: true,
        priority: TaskPriority.high,
        category: TaskCategory.study,
        dueDate: now.subtract(const Duration(hours: 2)),
        createdAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(hours: 1)),
      ),
      Task(
        id: '2',
        title: 'Complete Flutter To-Do UI & Theming',
        description: 'Build animated checkboxes, priority badges, category chips, and summary card.',
        isCompleted: false,
        priority: TaskPriority.high,
        category: TaskCategory.work,
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Task(
        id: '3',
        title: 'Buy groceries & fresh fruit',
        description: 'Apples, almond milk, whole grain bread, and green tea.',
        isCompleted: false,
        priority: TaskPriority.medium,
        category: TaskCategory.shopping,
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Task(
        id: '4',
        title: 'Morning 5K jog and stretch',
        description: 'Hydrate well and stretch hamstrings.',
        isCompleted: false,
        priority: TaskPriority.low,
        category: TaskCategory.health,
        dueDate: now,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
    ];
    await _persist();
    notifyListeners();
  }

  /// Internal save helper
  Future<void> _persist() async {
    try {
      await _storageService.saveTasks(_tasks);
    } catch (e) {
      _errorMessage = 'Failed to save changes: $e';
    }
  }
}
