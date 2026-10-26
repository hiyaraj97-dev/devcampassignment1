import 'dart:convert';
import 'package:flutter/material.dart';

// ============================================================================
// DEVCAMP 2.0 • WEEK 2 • PROJECT 2 • COMPULSORY: TO-DO LIST APP
// Standalone DartPad & Flutter Web Executable
// Paste this entire file into https://dartpad.dev/flutter and click 'Run'!
// ============================================================================

void main() {
  runApp(const TaskifyDartPadApp());
}

// ----------------------------------------------------------------------------
// MODELS
// ----------------------------------------------------------------------------

enum TaskPriority {
  low('Low', 1, 0xFF2E7D32, 0xFFE8F5E9),
  medium('Medium', 2, 0xFFF57C00, 0xFFFFF3E0),
  high('High', 3, 0xFFD32F2F, 0xFFFFEBEE);

  final String label;
  final int weight;
  final int colorValue;
  final int containerColorValue;

  const TaskPriority(this.label, this.weight, this.colorValue, this.containerColorValue);

  static TaskPriority fromString(String? value) {
    if (value == null) return TaskPriority.medium;
    return TaskPriority.values.firstWhere(
      (p) => p.name.toLowerCase() == value.toLowerCase() || p.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
}

enum TaskCategory {
  work('Work', 0xFF1976D2, 0xFFE3F2FD, Icons.business_center_rounded),
  personal('Personal', 0xFF7B1FA2, 0xFFF3E5F5, Icons.person_rounded),
  study('Study', 0xFF00796B, 0xFFE0F2F1, Icons.school_rounded),
  shopping('Shopping', 0xFFE64A19, 0xFFFBE9E7, Icons.shopping_bag_rounded),
  health('Health', 0xFF0288D1, 0xFFE1F5FE, Icons.favorite_rounded),
  other('Other', 0xFF616161, 0xFFEEEEEE, Icons.folder_rounded);

  final String label;
  final int primaryColorValue;
  final int containerColorValue;
  final IconData icon;

  const TaskCategory(this.label, this.primaryColorValue, this.containerColorValue, this.icon);

  static TaskCategory fromString(String? value) {
    if (value == null) return TaskCategory.personal;
    return TaskCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == value.toLowerCase() || c.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskCategory.personal,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final TaskPriority priority;
  final TaskCategory category;
  final DateTime? dueDate;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.personal,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a meaningful task title';
    }
    if (value.trim().length < 2) {
      return 'Task title must be at least 2 characters long';
    }
    return null;
  }

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  String? get formattedDueDate {
    if (dueDate == null) return null;
    if (isDueToday) return 'Today';
    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'priority': priority.name,
        'category': category.name,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
        priority: TaskPriority.fromString(json['priority'] as String?),
        category: TaskCategory.fromString(json['category'] as String?),
        dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'] as String) : null,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

// ----------------------------------------------------------------------------
// APPLICATION & STATE
// ----------------------------------------------------------------------------

class TaskifyDartPadApp extends StatefulWidget {
  const TaskifyDartPadApp({super.key});

  @override
  State<TaskifyDartPadApp> createState() => _TaskifyDartPadAppState();
}

class _TaskifyDartPadAppState extends State<TaskifyDartPadApp> {
  bool _isDarkMode = false;
  List<Task> _tasks = [];
  String _searchQuery = '';
  String _statusFilter = 'All'; // All, Pending, Completed
  TaskCategory? _categoryFilter;
  TaskPriority? _priorityFilter;

  // Simulated Persistent Storage string (JSON key-value)
  String _simulatedStorage = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final now = DateTime.now();
    _tasks = [
      Task(
        id: '1',
        title: 'Complete DevCamp Week 2 To-Do App',
        description: 'Verify CRUD, persistent storage, dark mode, and priorities.',
        isCompleted: true,
        priority: TaskPriority.high,
        category: TaskCategory.study,
        dueDate: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: '2',
        title: 'Review Flutter Widget Composition',
        description: 'Explore StatefulWidgets, Material 3 theming, and dismissibles.',
        isCompleted: false,
        priority: TaskPriority.high,
        category: TaskCategory.work,
        dueDate: now,
      ),
      Task(
        id: '3',
        title: 'Buy groceries & fresh fruit',
        description: 'Apples, almond milk, and whole oats.',
        isCompleted: false,
        priority: TaskPriority.medium,
        category: TaskCategory.shopping,
        dueDate: now.add(const Duration(days: 2)),
      ),
      Task(
        id: '4',
        title: 'Evening 30-minute walk',
        description: 'Listen to tech podcast and stretch.',
        isCompleted: false,
        priority: TaskPriority.low,
        category: TaskCategory.health,
      ),
    ];
    _saveToStorage();
  }

  void _saveToStorage() {
    // Encodes to JSON to fulfill simulated persistent storage
    final list = _tasks.map((t) => t.toJson()).toList();
    _simulatedStorage = jsonEncode(list);
  }

  void _restoreFromStorage() {
    if (_simulatedStorage.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(_simulatedStorage);
      setState(() {
        _tasks = decoded.map((i) => Task.fromJson(i as Map<String, dynamic>)).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restored tasks from simulated storage!')),
      );
    }
  }

  void _addTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskCategory category,
    DateTime? dueDate,
  }) {
    setState(() {
      _tasks.insert(
        0,
        Task(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title,
          description: description,
          priority: priority,
          category: category,
          dueDate: dueDate,
        ),
      );
      _saveToStorage();
    });
  }

  void _updateTask({
    required String id,
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskCategory category,
    DateTime? dueDate,
  }) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          title: title,
          description: description,
          priority: priority,
          category: category,
          dueDate: dueDate,
        );
        _saveToStorage();
      }
    });
  }

  void _toggleTask(String id) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final current = _tasks[index];
        _tasks[index] = current.copyWith(isCompleted: !current.isCompleted);
        _saveToStorage();
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
      _saveToStorage();
    });
  }

  List<Task> get _filteredTasks {
    return _tasks.where((t) {
      if (_statusFilter == 'Pending' && t.isCompleted) return false;
      if (_statusFilter == 'Completed' && !t.isCompleted) return false;
      if (_categoryFilter != null && t.category != _categoryFilter) return false;
      if (_priorityFilter != null && t.priority != _priorityFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = t.title.toLowerCase().contains(q) || t.description.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: const Color(0xFF4F46E5),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: const Color(0xFF818CF8),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taskify - DevCamp To-Do App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Text('Taskify', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            // Dark Mode Toggle
            IconButton(
              tooltip: _isDarkMode ? 'Light Mode' : 'Dark Mode',
              icon: Icon(_isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            ),
            // Reset / Restore persistence demo
            IconButton(
              tooltip: 'Re-open / Restore from Storage',
              icon: const Icon(Icons.sync_rounded),
              onPressed: _restoreFromStorage,
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress Summary Card
            _buildProgressCard(),

            // Search and Filter Bar
            _buildSearchAndFilters(),

            // Task List
            Expanded(
              child: _filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          const Text('No tasks found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text('Try modifying your search or tap + below.'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredTasks.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        return _buildTaskTile(task);
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Task'),
          onPressed: () => _openTaskDialog(),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final total = _tasks.length;
    final completed = _tasks.where((t) => t.isCompleted).length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDarkMode
              ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
              : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: $completed of $total Tasks',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF34D399)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search_rounded),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...['All', 'Pending', 'Completed'].map((status) {
                  final isSelected = _statusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _statusFilter = status),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                PopupMenuButton<TaskPriority?>(
                  onSelected: (p) => setState(() => _priorityFilter = p),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: null, child: Text('All Priorities')),
                    ...TaskPriority.values.map((p) => PopupMenuItem(value: p, child: Text(p.label))),
                  ],
                  child: Chip(
                    label: Text(_priorityFilter?.label ?? 'Priority'),
                    avatar: const Icon(Icons.flag_rounded, size: 16),
                  ),
                ),
                const SizedBox(width: 6),
                PopupMenuButton<TaskCategory?>(
                  onSelected: (c) => setState(() => _categoryFilter = c),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: null, child: Text('All Categories')),
                    ...TaskCategory.values.map((c) => PopupMenuItem(value: c, child: Text(c.label))),
                  ],
                  child: Chip(
                    label: Text(_categoryFilter?.label ?? 'Category'),
                    avatar: const Icon(Icons.category_rounded, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => _toggleTask(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(task.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                // Priority Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(task.priority.containerColorValue),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.priority.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(task.priority.colorValue),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(task.category.containerColorValue),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(task.category.icon, size: 12, color: Color(task.category.primaryColorValue)),
                      const SizedBox(width: 4),
                      Text(
                        task.category.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(task.category.primaryColorValue),
                        ),
                      ),
                    ],
                  ),
                ),
                if (task.formattedDueDate != null) ...[
                  const SizedBox(width: 6),
                  Text('Due: ${task.formattedDueDate}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => _openTaskDialog(taskToEdit: task),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              onPressed: () => _deleteTask(task.id),
            ),
          ],
        ),
      ),
    );
  }

  void _openTaskDialog({Task? taskToEdit}) {
    final titleController = TextEditingController(text: taskToEdit?.title ?? '');
    final descController = TextEditingController(text: taskToEdit?.description ?? '');
    var priority = taskToEdit?.priority ?? TaskPriority.medium;
    var category = taskToEdit?.category ?? TaskCategory.personal;
    DateTime? dueDate = taskToEdit?.dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      taskToEdit != null ? 'Edit Task' : 'New Task',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskPriority>(
                      value: priority,
                      decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                      items: TaskPriority.values
                          .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => priority = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskCategory>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: TaskCategory.values
                          .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        final valError = Task.validateTitle(titleController.text);
                        if (valError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(valError)),
                          );
                          return;
                        }

                        if (taskToEdit != null) {
                          _updateTask(
                            id: taskToEdit.id,
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            priority: priority,
                            category: category,
                            dueDate: dueDate,
                          );
                        } else {
                          _addTask(
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            priority: priority,
                            category: category,
                            dueDate: dueDate,
                          );
                        }
                        Navigator.of(ctx).pop();
                      },
                      child: Text(taskToEdit != null ? 'Save Changes' : 'Create Task'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
