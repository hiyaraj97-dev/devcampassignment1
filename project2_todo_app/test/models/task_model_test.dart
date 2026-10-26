import '../../lib/models/task.dart';
import '../../lib/models/task_category.dart';
import '../../lib/models/task_priority.dart';

void runTaskModelTests() {
  int passed = 0;
  int failed = 0;

  void test(String name, void Function() body) {
    try {
      body();
      print('  ✓ [PASS] $name');
      passed++;
    } catch (e, st) {
      print('  ✗ [FAIL] $name: $e');
      print(st);
      failed++;
    }
  }

  print('\n--- Running Task Model Tests ---');

  test('Validates title presence and length', () {
    assert(Task.validateTitle(null) != null, 'Null title should be invalid');
    assert(Task.validateTitle('') != null, 'Empty title should be invalid');
    assert(Task.validateTitle('   ') != null, 'Whitespace title should be invalid');
    assert(Task.validateTitle('A') != null, 'Single char title should be invalid');
    assert(Task.validateTitle('Valid Task') == null, 'Valid title should pass');
    assert(Task.validateTitle('a' * 101) != null, 'Over 100 chars should fail');
  });

  test('Task serialization and deserialization (JSON roundtrip)', () {
    final now = DateTime.now();
    final task = Task(
      id: 'task-101',
      title: 'DevCamp Assignment',
      description: 'Finish project 2',
      isCompleted: false,
      priority: TaskPriority.high,
      category: TaskCategory.study,
      dueDate: now.add(const Duration(days: 2)),
      createdAt: now,
    );

    final jsonMap = task.toJson();
    final restored = Task.fromJson(jsonMap);

    assert(restored.id == task.id, 'ID must match');
    assert(restored.title == task.title, 'Title must match');
    assert(restored.description == task.description, 'Description must match');
    assert(restored.priority == TaskPriority.high, 'Priority must match');
    assert(restored.category == TaskCategory.study, 'Category must match');
    assert(restored.isCompleted == false, 'Status must match');
  });

  test('Task copyWith updates fields properly', () {
    final task = Task(id: '1', title: 'Original', priority: TaskPriority.low);
    final updated = task.copyWith(
      title: 'Updated Title',
      priority: TaskPriority.high,
      isCompleted: true,
    );

    assert(updated.id == '1');
    assert(updated.title == 'Updated Title');
    assert(updated.priority == TaskPriority.high);
    assert(updated.isCompleted == true);
    assert(task.title == 'Original', 'Original should remain immutable');
  });

  test('Overdue logic accurately reflects dates', () {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    final overdueTask = Task(id: '1', title: 'Overdue Task', dueDate: yesterday);
    final futureTask = Task(id: '2', title: 'Future Task', dueDate: tomorrow);
    final completedOverdue = Task(id: '3', title: 'Done Task', dueDate: yesterday, isCompleted: true);

    assert(overdueTask.isOverdue == true, 'Yesterday due date should be overdue');
    assert(futureTask.isOverdue == false, 'Tomorrow due date should not be overdue');
    assert(completedOverdue.isOverdue == false, 'Completed tasks cannot be overdue');
  });

  test('Priority and Category string parsers fallback safely', () {
    assert(TaskPriority.fromString('high') == TaskPriority.high);
    assert(TaskPriority.fromString('High') == TaskPriority.high);
    assert(TaskPriority.fromString('unknown') == TaskPriority.medium);

    assert(TaskCategory.fromString('work') == TaskCategory.work);
    assert(TaskCategory.fromString('STUDY') == TaskCategory.study);
    assert(TaskCategory.fromString('invalid') == TaskCategory.personal);
  });

  print('Task Model Tests Completed: $passed Passed, $failed Failed');
  if (failed > 0) throw Exception('$failed tests failed in Task Model Suite');
}

void main() => runTaskModelTests();
