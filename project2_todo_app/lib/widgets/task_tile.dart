import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/category_chip.dart';
import '../widgets/priority_badge.dart';

/// Interactive task list item with swipe actions, animated completion, and visual hierarchy.
class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444), // Red 500
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Task?'),
                content: Text('Are you sure you want to delete "${task.title}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: task.isCompleted ? 0.65 : 1.0,
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Completion Checkbox
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 10),
                    child: InkWell(
                      onTap: onToggle,
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: task.isCompleted
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: task.isCompleted
                                ? theme.colorScheme.primary
                                : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                            width: 2,
                          ),
                        ),
                        child: task.isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Content Area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: isDark ? Colors.white60 : Colors.black54,
                            decorationThickness: 2,
                            color: task.isCompleted
                                ? (isDark ? Colors.white54 : Colors.black45)
                                : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
                          ),
                        ),

                        // Optional Description
                        if (task.description.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Metadata row: Category, Priority, and Due Date
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            CategoryBadge(category: task.category, isDense: true),
                            PriorityBadge(priority: task.priority, isDense: true),

                            // Due date tag
                            if (task.dueDate != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: task.isOverdue
                                      ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2))
                                      : (task.isDueToday
                                          ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
                                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: task.isOverdue
                                        ? const Color(0xFFEF4444)
                                        : (task.isDueToday
                                            ? const Color(0xFFF59E0B)
                                            : Colors.transparent),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 11,
                                      color: task.isOverdue
                                          ? const Color(0xFFEF4444)
                                          : (task.isDueToday
                                              ? const Color(0xFFD97706)
                                              : (isDark ? Colors.white60 : Colors.black54)),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      task.isOverdue
                                          ? 'Overdue (${task.formattedDueDate})'
                                          : task.formattedDueDate ?? '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: task.isOverdue || task.isDueToday
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: task.isOverdue
                                            ? const Color(0xFFEF4444)
                                            : (task.isDueToday
                                                ? const Color(0xFFD97706)
                                                : (isDark ? Colors.white70 : Colors.black87)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons: Edit and Delete
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: 'Edit Task',
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        onPressed: onEdit,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        tooltip: 'Delete Task',
                        color: const Color(0xFFEF4444).withOpacity(0.8),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Task?'),
                              content: Text('Are you sure you want to delete "${task.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            onDelete();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
