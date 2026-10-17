/// Expense models and split calculation algorithms for SplitSmart.
library;

import 'category.dart';
import 'exceptions.dart';

/// Represents a single recorded expense within a group.
class Expense {
  final String id;
  final String title;
  final double amount;
  final String paidBy;
  final ExpenseCategory category;
  final List<String> splitBetween;
  final Map<String, double> participantShares;
  final DateTime date;
  final String? notes;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.category,
    required List<String> splitBetween,
    Map<String, double>? participantShares,
    DateTime? date,
    this.notes,
  })  : splitBetween = List.unmodifiable(splitBetween),
        participantShares = Map.unmodifiable(
          participantShares ??
              _calculateEqualShares(amount, splitBetween),
        ),
        date = date ?? DateTime.now() {
    _validate();
  }

  void _validate() {
    if (title.trim().isEmpty) {
      throw InvalidExpenseException('Expense title cannot be empty.');
    }
    if (amount <= 0 || amount.isNaN || amount.isInfinite) {
      throw InvalidAmountException(amount);
    }
    if (paidBy.trim().isEmpty) {
      throw InvalidExpenseException('Payer name cannot be empty.');
    }
    if (splitBetween.isEmpty) {
      throw InvalidParticipantException(
          'Expense must have at least one participant.');
    }

    // Verify all split participants have non-negative shares and sum matches amount
    double totalShares = 0.0;
    for (final participant in splitBetween) {
      final share = participantShares[participant];
      if (share == null || share < 0) {
        throw InvalidSplitException(
            'Missing or negative share for participant "$participant".');
      }
      totalShares += share;
    }

    // Allow slight floating point tolerance (0.01)
    if ((totalShares - amount).abs() > 0.01) {
      throw InvalidSplitException(
        'Sum of participant shares ($totalShares) does not match total amount ($amount).',
      );
    }
  }

  /// Calculates equal shares with penny/paise distribution so the sum always matches exactly.
  static Map<String, double> _calculateEqualShares(
    double totalAmount,
    List<String> participants,
  ) {
    if (participants.isEmpty) return {};

    final count = participants.length;
    final totalCents = (totalAmount * 100).round();
    final baseCents = totalCents ~/ count;
    final remainderCents = totalCents % count;

    final result = <String, double>{};
    for (int i = 0; i < count; i++) {
      final cents = baseCents + (i < remainderCents ? 1 : 0);
      result[participants[i]] = cents / 100.0;
    }
    return result;
  }

  /// Factory for creating an expense with custom exact splits.
  factory Expense.withCustomSplit({
    required String id,
    required String title,
    required double amount,
    required String paidBy,
    required ExpenseCategory category,
    required Map<String, double> exactShares,
    DateTime? date,
    String? notes,
  }) {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      paidBy: paidBy,
      category: category,
      splitBetween: exactShares.keys.toList(),
      participantShares: exactShares,
      date: date,
      notes: notes,
    );
  }

  /// Factory for creating an expense with percentage splits.
  factory Expense.withPercentageSplit({
    required String id,
    required String title,
    required double amount,
    required String paidBy,
    required ExpenseCategory category,
    required Map<String, double> percentages,
    DateTime? date,
    String? notes,
  }) {
    double totalPercent = 0.0;
    percentages.forEach((_, p) => totalPercent += p);
    if ((totalPercent - 100.0).abs() > 0.01) {
      throw InvalidSplitException(
          'Percentages must sum to 100%. Current sum: $totalPercent%');
    }

    final totalCents = (amount * 100).round();
    final exactShares = <String, double>{};
    int distributedCents = 0;
    final entries = percentages.entries.toList();

    for (int i = 0; i < entries.length; i++) {
      if (i == entries.length - 1) {
        final remainingCents = totalCents - distributedCents;
        exactShares[entries[i].key] = remainingCents / 100.0;
      } else {
        final shareCents = ((entries[i].value / 100.0) * totalCents).round();
        exactShares[entries[i].key] = shareCents / 100.0;
        distributedCents += shareCents;
      }
    }

    return Expense(
      id: id,
      title: title,
      amount: amount,
      paidBy: paidBy,
      category: category,
      splitBetween: percentages.keys.toList(),
      participantShares: exactShares,
      date: date,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'paidBy': paidBy,
        'category': category.name,
        'splitBetween': splitBetween,
        'participantShares': participantShares,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paidBy'] as String,
      category: ExpenseCategory.fromString(json['category']),
      splitBetween: (json['splitBetween'] as List).cast<String>(),
      participantShares: (json['participantShares'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, (v as num).toDouble())),
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  @override
  String toString() {
    return '$title: INR ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)} '
        'paid by $paidBy [${category.label}] '
        '(split between ${splitBetween.join(', ')})';
  }
}
