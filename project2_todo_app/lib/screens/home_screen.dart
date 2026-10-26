import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../models/task_priority.dart';
import '../state/task_notifier.dart';
import '../theme/theme_notifier.dart';
import '../widgets/empty_task_view.dart';
import '../widgets/progress_summary_card.dart';
import '../widgets/search_and_filter_bar.dart';
import '../widgets/task_tile.dart';
import 'task_form_sheet.dart';

/// Main screen displaying task progress, search/filters, and the interactive task list.
class HomeScreen extends StatelessWidget {
  final TaskNotifier taskNotifier;
  final ThemeNotifier themeNotifier;

  const HomeScreen({
    super.key,
    required this.taskNotifier,
    required this.themeNotifier,
  });

  void _openAddTaskSheet(BuildContext context) {
    TaskFormSheet.show(
      context: context,
      onSave: ({
        required String title,
        required String description,
        required TaskPriority priority,
        required TaskCategory category,
        DateTime? dueDate,
      }) async {
        final success = await taskNotifier.addTask(
          title: title,
          description: description,
          priority: priority,
          category: category,
          dueDate: dueDate,
        );
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task added successfully!'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  void _openEditTaskSheet(BuildContext context, Task task) {
    TaskFormSheet.show(
      context: context,
      taskToEdit: task,
      onSave: ({
        required String title,
        required String description,
        required TaskPriority priority,
        required TaskCategory category,
        DateTime? dueDate,
      }) async {
        final success = await taskNotifier.updateTask(
          id: task.id,
          title: title,
          description: description,
          priority: priority,
          category: category,
          dueDate: dueDate,
          clearDueDate: dueDate == null && task.dueDate != null,
        );
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated!'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      onDelete: () => _handleDeleteTask(context, task),
    );
  }

  void _handleDeleteTask(BuildContext context, Task task) async {
    final deleted = await taskNotifier.deleteTask(task.id);
    if (deleted != null && context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${task.title}"'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              taskNotifier.restoreTask(deleted, null);
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([taskNotifier, themeNotifier]),
      builder: (context, _) {
        final isDark = themeNotifier.isDarkMode;
        final filteredTasks = taskNotifier.filteredTasks;
        final hasActiveFilters = taskNotifier.filter.status != null ||
            taskNotifier.filter.category != null ||
            taskNotifier.filter.priority != null ||
            taskNotifier.filter.searchQuery.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_box_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Taskify',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            actions: [
              // Theme Toggle (Light / Dark Mode)
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey<bool>(isDark),
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF475569),
                  ),
                ),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () => themeNotifier.toggleTheme(),
              ),

              // More options menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) async {
                  switch (value) {
                    case 'seed':
                      await taskNotifier.seedSampleTasks();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sample tasks loaded!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      break;
                    case 'clear_completed':
                      final completed = taskNotifier.tasks.where((t) => t.isCompleted).toList();
                      if (completed.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No completed tasks to clear.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      for (final t in completed) {
                        await taskNotifier.deleteTask(t.id);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cleared ${completed.length} completed tasks.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      break;
                    case 'about':
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('DevCamp 2.0 To-Do App'),
                          content: const Text(
                            'Week 2 • Project 2 • Compulsory\n\n'
                            'Features:\n'
                            '• Full CRUD operations\n'
                            '• Title validation & input forms\n'
                            '• Categories & priorities\n'
                            '• Local persistent storage (key-value / JSON)\n'
                            '• Visual completion states\n'
                            '• Light / Dark theme toggle\n'
                            '• Search & real-time filters\n'
                            '• Due dates & progress summary',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'seed',
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Load Sample Tasks'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_completed',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Clear Completed'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'about',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('About Project'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: taskNotifier.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Top Progress Analytics
                    ProgressSummaryCard(
                      totalCount: taskNotifier.totalCount,
                      completedCount: taskNotifier.completedCount,
                      pendingCount: taskNotifier.pendingCount,
                      progress: taskNotifier.completionProgress,
                    ),

                    // Search & Filter controls
                    SearchAndFilterBar(notifier: taskNotifier),

                    const SizedBox(height: 4),

                    // Task List or Empty State
                    Expanded(
                      child: filteredTasks.isEmpty
                          ? EmptyTaskView(
                              hasActiveFilters: hasActiveFilters,
                              onResetFilters: () => taskNotifier.clearFilters(),
                              onAddTask: () => _openAddTaskSheet(context),
                              onSeedSample: taskNotifier.totalCount == 0
                                  ? () => taskNotifier.seedSampleTasks()
                                  : null,
                            )
                          : ListView.builder(
                              itemCount: filteredTasks.length,
                              padding: const EdgeInsets.only(bottom: 80),
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];
                                return TaskTile(
                                  task: task,
                                  onToggle: () => taskNotifier.toggleTaskCompletion(task.id),
                                  onEdit: () => _openEditTaskSheet(context, task),
                                  onDelete: () => _handleDeleteTask(context, task),
                                );
                              },
                            ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Task', style: TextStyle(fontWeight: FontWeight.bold)),
            tooltip: 'Add a new task',
            onPressed: () => _openAddTaskSheet(context),
          ),
        );
      },
    );
  }
}
