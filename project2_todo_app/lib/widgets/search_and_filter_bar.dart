import 'package:flutter/material.dart';
import '../models/task_category.dart';
import '../models/task_priority.dart';
import '../state/task_filter.dart';
import '../state/task_notifier.dart';

/// Interactive search input and status/category/priority filter chips.
class SearchAndFilterBar extends StatefulWidget {
  final TaskNotifier notifier;

  const SearchAndFilterBar({
    super.key,
    required this.notifier,
  });

  @override
  State<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.notifier.filter.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = widget.notifier.filter;
    final isDark = theme.brightness == Brightness.dark;

    final hasActiveFilters = filter.status != TaskFilterStatus.all ||
        filter.category != null ||
        filter.priority != null ||
        filter.searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) => widget.notifier.setSearchQuery(val),
            decoration: InputDecoration(
              hintText: 'Search tasks by title or notes...',
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        widget.notifier.setSearchQuery('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status Filters
                ...TaskFilterStatus.values.map((status) {
                  final isSelected = filter.status == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status.label),
                      selected: isSelected,
                      onSelected: (_) => widget.notifier.setStatusFilter(status),
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      checkmarkColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  );
                }),

                // Priority Filter Dropdown or Quick Chip
                PopupMenuButton<TaskPriority?>(
                  tooltip: 'Filter by Priority',
                  initialValue: filter.priority,
                  onSelected: (p) => widget.notifier.setPriorityFilter(p),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text('All Priorities'),
                    ),
                    ...TaskPriority.values.map(
                      (p) => PopupMenuItem(
                        value: p,
                        child: Text('${p.label} Priority'),
                      ),
                    ),
                  ],
                  child: Chip(
                    avatar: Icon(
                      Icons.flag_rounded,
                      size: 16,
                      color: filter.priority != null
                          ? Color(filter.priority!.colorValue)
                          : (isDark ? Colors.white54 : Colors.black54),
                    ),
                    label: Text(
                      filter.priority != null ? filter.priority!.label : 'Priority',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: filter.priority != null ? FontWeight.bold : FontWeight.normal,
                        color: filter.priority != null
                            ? Color(filter.priority!.colorValue)
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    backgroundColor: filter.priority != null
                        ? Color(filter.priority!.containerColorValue)
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: filter.priority != null
                            ? Color(filter.priority!.colorValue)
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Category Filter Dropdown
                PopupMenuButton<TaskCategory?>(
                  tooltip: 'Filter by Category',
                  initialValue: filter.category,
                  onSelected: (c) => widget.notifier.setCategoryFilter(c),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...TaskCategory.values.map(
                      (c) => PopupMenuItem(
                        value: c,
                        child: Text(c.label),
                      ),
                    ),
                  ],
                  child: Chip(
                    avatar: Icon(
                      Icons.category_rounded,
                      size: 16,
                      color: filter.category != null
                          ? Color(filter.category!.primaryColorValue)
                          : (isDark ? Colors.white54 : Colors.black54),
                    ),
                    label: Text(
                      filter.category != null ? filter.category!.label : 'Category',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: filter.category != null ? FontWeight.bold : FontWeight.normal,
                        color: filter.category != null
                            ? Color(filter.category!.primaryColorValue)
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    backgroundColor: filter.category != null
                        ? Color(filter.category!.containerColorValue)
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: filter.category != null
                            ? Color(filter.category!.primaryColorValue)
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),

                // Clear Filters Reset Button
                if (hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Reset', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      _searchController.clear();
                      widget.notifier.clearFilters();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
