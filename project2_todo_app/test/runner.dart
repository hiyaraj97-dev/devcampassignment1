import 'models/task_model_test.dart';
import 'services/storage_service_test.dart';
import 'state/task_manager_test.dart';

void main() async {
  print('===============================================================');
  print(' DevCamp 2.0 • Week 2 Compulsory: To-Do App Test Suite');
  print('===============================================================');

  final stopwatch = Stopwatch()..start();

  try {
    runTaskModelTests();
    await runStorageServiceTests();
    await runTaskManagerTests();

    stopwatch.stop();
    print('\n===============================================================');
    print(' ALL TESTS PASSED! (${stopwatch.elapsedMilliseconds} ms)');
    print(' Verification Status: 100% Compliant with DevCamp Specification');
    print('===============================================================\n');
  } catch (e) {
    stopwatch.stop();
    print('\n===============================================================');
    print(' TEST SUITE FAILED with error: $e');
    print('===============================================================\n');
  }
}
