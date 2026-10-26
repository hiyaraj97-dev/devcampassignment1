import 'package:flutter/material.dart';
import '../models/task_category.dart';

/// Renders a category icon and label badge.
class CategoryBadge extends StatelessWidget {
  final TaskCategory category;
  final bool isDense;

  const CategoryBadge({
    super.key,
    required this.category,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(category.primaryColorValue);
    final containerColor = Color(category.containerColorValue);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDense ? 6 : 8,
        vertical: isDense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: isDense ? 12 : 14,
            color: primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: TextStyle(
              fontSize: isDense ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.business_center_rounded;
      case TaskCategory.personal:
        return Icons.person_rounded;
      case TaskCategory.study:
        return Icons.school_rounded;
      case TaskCategory.shopping:
        return Icons.shopping_bag_rounded;
      case TaskCategory.health:
        return Icons.favorite_rounded;
      case TaskCategory.other:
        return Icons.folder_rounded;
    }
  }
}
