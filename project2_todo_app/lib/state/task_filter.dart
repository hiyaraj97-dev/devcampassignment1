import '../models/task.dart';
import '../models/task_category.dart';
import '../models/task_priority.dart';

/// Status filter for displaying tasks.
enum TaskFilterStatus {
  all('All'),
  pending('Pending'),
  completed('Completed');

  final String label;
  const TaskFilterStatus(this.label);
}

/// Filter criteria container for querying and sorting task lists.
class TaskFilter {
  final TaskFilterStatus status;
  final TaskCategory? category;
  final TaskPriority? priority;
  final String searchQuery;

  const TaskFilter({
    this.status = TaskFilterStatus.all,
    this.category,
    this.priority,
    this.searchQuery = '',
  });

  TaskFilter copyWith({
    TaskFilterStatus? status,
    TaskCategory? category,
    bool clearCategory = false,
    TaskPriority? priority,
    bool clearPriority = false,
    String? searchQuery,
  }) {
    return TaskFilter(
      status: status ?? this.status,
      category: clearCategory ? null : (category ?? this.category),
      priority: clearPriority ? null : (priority ?? this.priority),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Evaluates whether a [Task] satisfies all active filter rules.
  bool matches(Task task) {
    // 1. Completion status check
    switch (status) {
      case TaskFilterStatus.pending:
        if (task.isCompleted) return false;
        break;
      case TaskFilterStatus.completed:
        if (!task.isCompleted) return false;
        break;
      case TaskFilterStatus.all:
        break;
    }

    // 2. Category check
    if (category != null && task.category != category) {
      return false;
    }

    // 3. Priority check
    if (priority != null && task.priority != priority) {
      return false;
    }

    // 4. Search query check (title and description)
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      final titleMatch = task.title.toLowerCase().contains(query);
      final descMatch = task.description.toLowerCase().contains(query);
      if (!titleMatch && !descMatch) {
        return false;
      }
    }

    return true;
  }
}
