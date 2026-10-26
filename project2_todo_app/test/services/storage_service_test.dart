import '../../lib/models/task.dart';
import '../../lib/models/task_category.dart';
import '../../lib/models/task_priority.dart';
import '../../lib/services/in_memory_storage_service.dart';

Future<void> runStorageServiceTests() async {
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

  print('\n--- Running Storage Service Tests ---');

  await test('Initial state loads empty list', () async {
    final storage = InMemoryStorageService();
    final tasks = await storage.loadTasks();
    assert(tasks.isEmpty, 'Initial tasks should be empty');
  });

  await test('Saves and restores tasks list properly', () async {
    final storage = InMemoryStorageService();
    final testTasks = [
      Task(
        id: '1',
        title: 'Task A',
        priority: TaskPriority.high,
        category: TaskCategory.work,
      ),
      Task(
        id: '2',
        title: 'Task B',
        priority: TaskPriority.low,
        category: TaskCategory.personal,
        isCompleted: true,
      ),
    ];

    await storage.saveTasks(testTasks);
    final restored = await storage.loadTasks();

    assert(restored.length == 2, 'Should have 2 tasks restored');
    assert(restored[0].title == 'Task A');
    assert(restored[0].priority == TaskPriority.high);
    assert(restored[1].title == 'Task B');
    assert(restored[1].isCompleted == true);
  });

  await test('Saves and loads Dark Mode preference', () async {
    final storage = InMemoryStorageService();
    assert(await storage.loadDarkMode() == false, 'Default should be light mode');

    await storage.saveDarkMode(true);
    assert(await storage.loadDarkMode() == true, 'Dark mode should persist true');

    await storage.saveDarkMode(false);
    assert(await storage.loadDarkMode() == false, 'Dark mode should persist false');
  });

  print('Storage Service Tests Completed: $passed Passed, $failed Failed');
  if (failed > 0) throw Exception('$failed tests failed in Storage Service Suite');
}

void main() async => runStorageServiceTests();
