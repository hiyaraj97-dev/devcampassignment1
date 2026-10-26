/// Task Priority enumeration representing task urgency.
enum TaskPriority {
  low('Low', 1),
  medium('Medium', 2),
  high('High', 3);

  final String label;
  final int weight;

  const TaskPriority(this.label, this.weight);

  /// Safe deserialization from string with fallback to [TaskPriority.medium].
  static TaskPriority fromString(String? value) {
    if (value == null) return TaskPriority.medium;
    return TaskPriority.values.firstWhere(
      (p) => p.name.toLowerCase() == value.toLowerCase() || p.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }

  /// Color hex code for pure Dart representation.
  int get colorValue {
    switch (this) {
      case TaskPriority.low:
        return 0xFF2E7D32; // Green 800
      case TaskPriority.medium:
        return 0xFFF57C00; // Orange 700
      case TaskPriority.high:
        return 0xFFD32F2F; // Red 700
    }
  }

  /// Background tint hex code for badges.
  int get containerColorValue {
    switch (this) {
      case TaskPriority.low:
        return 0xFFE8F5E9; // Green 50
      case TaskPriority.medium:
        return 0xFFFFF3E0; // Orange 50
      case TaskPriority.high:
        return 0xFFFFEBEE; // Red 50
    }
  }
}
