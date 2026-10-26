import 'package:flutter/material.dart';
import '../models/task_priority.dart';

/// Reusable badge displaying task urgency with distinct color cues.
class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool isDense;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(priority.colorValue);
    final containerColor = Color(priority.containerColorValue);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDense ? 6 : 8,
        vertical: isDense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(priority),
            size: isDense ? 12 : 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              fontSize: isDense ? 10 : 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case TaskPriority.medium:
        return Icons.drag_handle_rounded;
      case TaskPriority.low:
        return Icons.keyboard_arrow_down_rounded;
    }
  }
}
