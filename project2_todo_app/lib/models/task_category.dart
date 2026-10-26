/// Task Category enumeration representing the organizational domain.
enum TaskCategory {
  work('Work', 0xFF1976D2, 0xFFE3F2FD, 'briefcase'),
  personal('Personal', 0xFF7B1FA2, 0xFFF3E5F5, 'person'),
  study('Study', 0xFF00796B, 0xFFE0F2F1, 'school'),
  shopping('Shopping', 0xFFE64A19, 0xFFFBE9E7, 'shopping_cart'),
  health('Health', 0xFF0288D1, 0xFFE1F5FE, 'fitness_center'),
  other('Other', 0xFF616161, 0xFFEEEEEE, 'folder');

  final String label;
  final int primaryColorValue;
  final int containerColorValue;
  final String iconKey;

  const TaskCategory(
    this.label,
    this.primaryColorValue,
    this.containerColorValue,
    this.iconKey,
  );

  /// Safe deserialization from string with fallback to [TaskCategory.personal].
  static TaskCategory fromString(String? value) {
    if (value == null) return TaskCategory.personal;
    return TaskCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == value.toLowerCase() || c.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskCategory.personal,
    );
  }
}
