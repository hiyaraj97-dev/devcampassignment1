import '../../lib/models/task.dart';
import '../../lib/models/task_category.dart';
import '../../lib/models/task_priority.dart';
import '../../lib/services/in_memory_storage_service.dart';
import '../../lib/state/task_filter.dart';

Future<void> runTaskManagerTests() async {
  int passed = 0;
  int failed = 0;

  Future<void> test(String name, Future<void> Function() body) async {
    try {
      await body();
      print('  ✓ [PASS] $name');
      passed++;
    } catch (e, st) {
      print('  ✗ [FAIL] $name: $e');
      print(st);
      failed++;
    }
  }

  print('\n--- Running Task Filtering & Lifecycle Tests ---');

  await test('TaskFilter correctly matches status (All, Pending, Completed)', () async {
    final pendingTask = Task(id: '1', title: 'Pending', isCompleted: false);
    final completedTask = Task(id: '2', title: 'Done', isCompleted: true);

    const allFilter = TaskFilter(status: TaskFilterStatus.all);
    assert(allFilter.matches(pendingTask) == true);
    assert(allFilter.matches(completedTask) == true);

    const pendingFilter = TaskFilter(status: TaskFilterStatus.pending);
    assert(pendingFilter.matches(pendingTask) == true);
    assert(pendingFilter.matches(completedTask) == false);

    const completedFilter = TaskFilter(status: TaskFilterStatus.completed);
    assert(completedFilter.matches(pendingTask) == false);
    assert(completedFilter.matches(completedTask) == true);
  });

  await test('TaskFilter filters by Category and Priority', () async {
    final task1 = Task(id: '1', title: 'Work High', category: TaskCategory.work, priority: TaskPriority.high);
    final task2 = Task(id: '2', title: 'Study Low', category: TaskCategory.study, priority: TaskPriority.low);

    const workFilter = TaskFilter(category: TaskCategory.work);
    assert(workFilter.matches(task1) == true);
    assert(workFilter.matches(task2) == false);

    const highFilter = TaskFilter(priority: TaskPriority.high);
    assert(highFilter.matches(task1) == true);
    assert(highFilter.matches(task2) == false);

    const combinedFilter = TaskFilter(category: TaskCategory.work, priority: TaskPriority.high);
    assert(combinedFilter.matches(task1) == true);
    assert(combinedFilter.matches(task2) == false);
  });

  await test('TaskFilter searches by keyword in title or notes', () async {
    final task = Task(id: '1', title: 'Buy Groceries', description: 'Fresh organic milk and oats');

    const searchTitle = TaskFilter(searchQuery: 'groceries');
    assert(searchTitle.matches(task) == true);

    const searchDesc = TaskFilter(searchQuery: 'milk');
    assert(searchDesc.matches(task) == true);

    const searchMismatch = TaskFilter(searchQuery: 'football');
    assert(searchMismatch.matches(task) == false);
  });

  await test('Demonstration Specification Cycle: Add 3, Edit 1, Complete 1, Delete 1, Persist & Reopen', () async {
    final storage = InMemoryStorageService();

    // 1. Create at least 3 tasks
    final tasks = <Task>[
      Task(id: 't1', title: 'Task 1: Read Guide', priority: TaskPriority.high, category: TaskCategory.study),
      Task(id: 't2', title: 'Task 2: Build Layout', priority: TaskPriority.medium, category: TaskCategory.work),
      Task(id: 't3', title: 'Task 3: Write Documentation', priority: TaskPriority.low, category: TaskCategory.other),
    ];
    assert(tasks.length == 3, 'Created 3 tasks');

    // 2. Edit one task
    final editIndex = tasks.indexWhere((t) => t.id == 't2');
    tasks[editIndex] = tasks[editIndex].copyWith(title: 'Task 2: Polished Material 3 Layout');
    assert(tasks[editIndex].title == 'Task 2: Polished Material 3 Layout');

    // 3. Mark one task as complete
    final completeIndex = tasks.indexWhere((t) => t.id == 't1');
    tasks[completeIndex] = tasks[completeIndex].copyWith(isCompleted: true);
    assert(tasks[completeIndex].isCompleted == true);

    // 4. Delete one task
    tasks.removeWhere((t) => t.id == 't3');
    assert(tasks.length == 2);
    assert(tasks.any((t) => t.id == 't3') == false);

    // 5. Persist tasks to storage
    await storage.saveTasks(tasks);

    // 6. Simulate closing and reopening app: read from storage afresh
    final freshRestored = await storage.loadTasks();
    assert(freshRestored.length == 2, 'Restored list should contain exactly 2 tasks');
    assert(freshRestored[0].id == 't1' && freshRestored[0].isCompleted == true, 'Task 1 must remain completed');
    assert(freshRestored[1].id == 't2' && freshRestored[1].title == 'Task 2: Polished Material 3 Layout', 'Task 2 must retain edited title');
  });

  print('Task Filtering & Lifecycle Tests Completed: $passed Passed, $failed Failed');
  if (failed > 0) throw Exception('$failed tests failed in Task Filtering & Lifecycle Suite');
}

void main() async => runTaskManagerTests();
