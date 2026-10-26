import 'package:flutter/material.dart';

/// Clean empty state display for both empty lists and no search results.
class EmptyTaskView extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback onResetFilters;
  final VoidCallback onAddTask;
  final VoidCallback? onSeedSample;

  const EmptyTaskView({
    super.key,
    required this.hasActiveFilters,
    required this.onResetFilters,
    required this.onAddTask,
    this.onSeedSample,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasActiveFilters
                    ? Icons.search_off_rounded
                    : Icons.check_circle_outline_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasActiveFilters ? 'No matching tasks found' : 'Your task list is empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilters
                  ? 'Try adjusting your search keywords, priority, or category filters.'
                  : 'Start your productive day by creating your first task or load sample tasks to test.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (hasActiveFilters)
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset All Filters'),
                onPressed: onResetFilters,
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Task'),
                    onPressed: onAddTask,
                  ),
                  if (onSeedSample != null) ...[
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Load Samples'),
                      onPressed: onSeedSample,
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
