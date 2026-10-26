import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'services/in_memory_storage_service.dart';
import 'services/shared_preferences_storage_service.dart';
import 'services/storage_service.dart';
import 'state/task_notifier.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage Service with SharedPreferences (or graceful in-memory fallback)
  StorageService storageService;
  try {
    final prefs = await SharedPreferences.getInstance();
    storageService = SharedPreferencesStorageService(prefs);
  } catch (e) {
    debugPrint('SharedPreferences init fallback to in-memory: $e');
    storageService = InMemoryStorageService();
  }

  final taskNotifier = TaskNotifier(storageService);
  final themeNotifier = ThemeNotifier(storageService);

  runApp(
    TodoApp(
      taskNotifier: taskNotifier,
      themeNotifier: themeNotifier,
    ),
  );
}

class TodoApp extends StatelessWidget {
  final TaskNotifier taskNotifier;
  final ThemeNotifier themeNotifier;

  const TodoApp({
    super.key,
    required this.taskNotifier,
    required this.themeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          title: 'Taskify - DevCamp 2.0 To-Do',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
          home: HomeScreen(
            taskNotifier: taskNotifier,
            themeNotifier: themeNotifier,
          ),
        );
      },
    );
  }
}
