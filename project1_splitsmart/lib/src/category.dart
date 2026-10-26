/// Expense category representations for SplitSmart.
library;

/// Standard categories for classifying group expenses.
enum ExpenseCategory {
  food('Food', '🍽️'),
  travel('Travel', '🚗'),
  utilities('Utilities', '💡'),
  entertainment('Entertainment', '🎬'),
  shopping('Shopping', '🛍️'),
  accommodation('Accommodation', '🏨'),
  groceries('Groceries', '🛒'),
  health('Health', '💊'),
  other('Other', '📦');

  final String label;
  final String emoji;

  const ExpenseCategory(this.label, this.emoji);

  @override
  String toString() => label;

  /// Parses an expense category from a string or returns `ExpenseCategory.other` if unknown.
  static ExpenseCategory fromString(dynamic value) {
    if (value is ExpenseCategory) return value;
    if (value == null) return ExpenseCategory.other;

    final normalized = value.toString().trim().toLowerCase();
    for (final cat in ExpenseCategory.values) {
      if (cat.name.toLowerCase() == normalized ||
          cat.label.toLowerCase() == normalized) {
        return cat;
      }
    }
    return ExpenseCategory.other;
  }
}
