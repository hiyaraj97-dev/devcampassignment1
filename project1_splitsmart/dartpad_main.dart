// ============================================================================
// SPLITSMART - DART EXPENSE SPLITTER (DARTPAD COMPATIBLE SINGLE-FILE VERSION)
// Week 1 • Project 1 • Compulsory (DevSource / DevCamp 2.0)
//
// You can copy this entire file and paste it directly into https://dartpad.dev/
// and click "Run" to test.
// ============================================================================

import 'dart:math';

void main() {
  print('=== SplitSmart: DartPad Compulsory & Extended Demonstrations ===\n');

  // --------------------------------------------------------------------------
  // 1. EXACT COMPULSORY USAGE FROM SPECIFICATION
  // --------------------------------------------------------------------------
  print('--- 1. Compulsory Specification Example ---');
  final group = ExpenseGroup();
  group.addMember('Asha');
  group.addMember('Ravi');
  group.addMember('Neha');
  group.addExpense(
    title: 'Dinner',
    amount: 900,
    paidBy: 'Asha',
    category: 'Food',
    splitBetween: ['Asha', 'Ravi', 'Neha'],
  );
  group.printBalances();

  print('\nSuggested Settlements:');
  for (final t in group.suggestSettlements()) {
    print('  • $t');
  }

  // --------------------------------------------------------------------------
  // 2. ADDITIONAL SCENARIOS: MULTIPLE PAYERS ACROSS EXPENSES
  // --------------------------------------------------------------------------
  print('\n--- 2. Additional Scenario: Multiple Payers ---');
  final trip = ExpenseGroup();
  trip.addMember('Asha');
  trip.addMember('Ravi');
  trip.addMember('Neha');
  trip.addMember('Vikram');

  trip.addExpense(
    title: 'Resort Stay',
    amount: 1200,
    paidBy: 'Asha',
    category: 'Accommodation',
    splitBetween: ['Asha', 'Ravi', 'Neha', 'Vikram'],
  );

  trip.addExpense(
    title: 'Food & Groceries',
    amount: 800,
    paidBy: 'Ravi',
    category: 'Food',
    splitBetween: ['Asha', 'Ravi', 'Neha', 'Vikram'],
  );

  trip.addExpense(
    title: 'Fuel',
    amount: 400,
    paidBy: 'Vikram',
    category: 'Travel',
    splitBetween: ['Asha', 'Ravi', 'Vikram'],
  );

  trip.printBalances();
  print('\nSuggested Settlements:');
  for (final t in trip.suggestSettlements()) {
    print('  • $t');
  }

  // --------------------------------------------------------------------------
  // 3. FILTERING EXPENSES BY MEMBER AND CATEGORY
  // --------------------------------------------------------------------------
  print('\n--- 3. Expense Filtering ---');
  print('Travel expenses:');
  for (final exp in trip.listExpenses(category: 'Travel')) {
    print('  • $exp');
  }

  print('Expenses involving Neha:');
  for (final exp in trip.listExpenses(member: 'Neha')) {
    print('  • $exp');
  }

  // --------------------------------------------------------------------------
  // 4. ERROR HANDLING & VALIDATION CHECKS
  // --------------------------------------------------------------------------
  print('\n--- 4. Error Handling Checks ---');
  try {
    group.addMember('Asha'); // Duplicate
  } catch (e) {
    print('Caught expected error: $e');
  }

  try {
    group.addExpense(
      title: 'Snacks',
      amount: -100, // Invalid amount
      paidBy: 'Asha',
      category: 'Food',
      splitBetween: ['Asha', 'Ravi'],
    );
  } catch (e) {
    print('Caught expected error: $e');
  }

  try {
    group.addExpense(
      title: 'Snacks',
      amount: 100,
      paidBy: 'UnknownPerson', // Unknown payer
      category: 'Food',
      splitBetween: ['Asha'],
    );
  } catch (e) {
    print('Caught expected error: $e');
  }

  try {
    group.addExpense(
      title: 'Solo',
      amount: 100,
      paidBy: 'Asha',
      category: 'Food',
      splitBetween: [], // Empty participants
    );
  } catch (e) {
    print('Caught expected error: $e');
  }

  print('\n=== All DartPad demonstrations completed successfully! ===');
}

// ============================================================================
// CORE CLASSES & IMPLEMENTATION
// ============================================================================

/// Custom exception base class.
abstract class SplitSmartException implements Exception {
  final String message;
  const SplitSmartException(this.message);
  @override
  String toString() => message;
}

class DuplicateMemberException extends SplitSmartException {
  DuplicateMemberException(String name)
      : super('Duplicate member error: Member "$name" already exists in the group.');
}

class MemberNotFoundException extends SplitSmartException {
  MemberNotFoundException(String name)
      : super('Member not found: "$name" is not registered in the group.');
}

class InvalidAmountException extends SplitSmartException {
  InvalidAmountException(num amount)
      : super('Invalid amount: Expense amount must be greater than zero. Received: $amount');
}

class InvalidParticipantException extends SplitSmartException {
  InvalidParticipantException(String detail)
      : super('Invalid participants: $detail');
}

/// Standard categories for classifying group expenses.
enum ExpenseCategory {
  food('Food'),
  travel('Travel'),
  utilities('Utilities'),
  entertainment('Entertainment'),
  shopping('Shopping'),
  accommodation('Accommodation'),
  groceries('Groceries'),
  other('Other');

  final String label;
  const ExpenseCategory(this.label);

  static ExpenseCategory fromString(dynamic value) {
    if (value is ExpenseCategory) return value;
    if (value == null) return ExpenseCategory.other;
    final str = value.toString().trim().toLowerCase();
    for (final c in ExpenseCategory.values) {
      if (c.name.toLowerCase() == str || c.label.toLowerCase() == str) {
        return c;
      }
    }
    return ExpenseCategory.other;
  }
}

/// Represents an individual member.
class Member {
  final String id;
  final String name;

  Member({required this.name, String? id})
      : id = (id != null && id.trim().isNotEmpty)
            ? id.trim()
            : name.trim().toLowerCase() {
    if (name.trim().isEmpty) {
      throw ArgumentError('Member name cannot be empty.');
    }
  }

  @override
  String toString() => name;
}

/// Represents a single recorded expense.
class Expense {
  final String id;
  final String title;
  final double amount;
  final String paidBy;
  final ExpenseCategory category;
  final List<String> splitBetween;
  final Map<String, double> participantShares;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.category,
    required List<String> splitBetween,
    Map<String, double>? participantShares,
    DateTime? date,
  })  : splitBetween = List.unmodifiable(splitBetween),
        participantShares = Map.unmodifiable(
          participantShares ?? _calculateEqualShares(amount, splitBetween),
        ),
        date = date ?? DateTime.now();

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

  @override
  String toString() {
    final amt = amount.truncateToDouble() == amount
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '$title: INR $amt paid by $paidBy [${category.label}] (split between ${splitBetween.join(', ')})';
  }
}

/// Represents a recommended settlement transfer between two members.
class SettlementTransfer {
  final String from;
  final String to;
  final double amount;

  const SettlementTransfer({
    required this.from,
    required this.to,
    required this.amount,
  });

  @override
  String toString() {
    final amtStr = amount.truncateToDouble() == amount
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '$from pays $to INR $amtStr';
  }
}

/// ExpenseGroup class implementing required API and calculations.
class ExpenseGroup {
  final Map<String, Member> _members = {};
  final List<Expense> _expenses = [];

  List<Member> get members => List.unmodifiable(_members.values);
  List<Expense> get expenses => List.unmodifiable(_expenses);

  bool hasMember(String nameOrId) {
    return _members.containsKey(nameOrId.trim().toLowerCase());
  }

  Member addMember(String name, {String? id}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Member name cannot be empty.');
    }
    final key = trimmed.toLowerCase();
    if (_members.containsKey(key)) {
      throw DuplicateMemberException(trimmed);
    }
    final member = Member(name: trimmed, id: id);
    _members[key] = member;
    return member;
  }

  Member _getMember(String nameOrId) {
    final member = _members[nameOrId.trim().toLowerCase()];
    if (member == null) {
      throw MemberNotFoundException(nameOrId);
    }
    return member;
  }

  Expense addExpense({
    required String title,
    required num amount,
    required String paidBy,
    dynamic category = ExpenseCategory.other,
    required List<String> splitBetween,
    Map<String, num>? customShares,
    DateTime? date,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError('Expense title cannot be empty.');
    }
    if (amount <= 0 || amount.isNaN || amount.isInfinite) {
      throw InvalidAmountException(amount);
    }
    final payer = _getMember(paidBy);
    if (splitBetween.isEmpty) {
      throw InvalidParticipantException('Participant list cannot be empty.');
    }

    final validatedParticipants = <String>[];
    for (final p in splitBetween) {
      final m = _getMember(p);
      if (!validatedParticipants.contains(m.name)) {
        validatedParticipants.add(m.name);
      }
    }

    final parsedCategory = ExpenseCategory.fromString(category);
    final expenseId = 'exp_${_expenses.length + 1}';

    final Map<String, double>? shares;
    if (customShares != null) {
      shares = {};
      for (final entry in customShares.entries) {
        final m = _getMember(entry.key);
        shares[m.name] = entry.value.toDouble();
      }
    } else {
      shares = null;
    }

    final expense = Expense(
      id: expenseId,
      title: title.trim(),
      amount: amount.toDouble(),
      paidBy: payer.name,
      category: parsedCategory,
      splitBetween: validatedParticipants,
      participantShares: shares,
      date: date,
    );

    _expenses.add(expense);
    return expense;
  }

  List<Expense> listExpenses({String? member, dynamic category}) {
    Iterable<Expense> filtered = _expenses;
    if (member != null && member.trim().isNotEmpty) {
      final target = member.trim().toLowerCase();
      filtered = filtered.where((e) =>
          e.paidBy.toLowerCase() == target ||
          e.splitBetween.any((p) => p.toLowerCase() == target));
    }
    if (category != null) {
      final targetCat = ExpenseCategory.fromString(category);
      filtered = filtered.where((e) => e.category == targetCat);
    }
    return filtered.toList();
  }

  ({double totalPaid, double shareOwed, double netBalance}) getMemberBalance(
    String memberNameOrId,
  ) {
    final member = _getMember(memberNameOrId);
    double totalPaid = 0.0;
    double shareOwed = 0.0;

    for (final exp in _expenses) {
      if (exp.paidBy.toLowerCase() == member.name.toLowerCase()) {
        totalPaid += exp.amount;
      }
      final share = exp.participantShares[member.name];
      if (share != null) {
        shareOwed += share;
      }
    }

    final net = totalPaid - shareOwed;
    return (
      totalPaid: double.parse(totalPaid.toStringAsFixed(2)),
      shareOwed: double.parse(shareOwed.toStringAsFixed(2)),
      netBalance: double.parse(net.toStringAsFixed(2)),
    );
  }

  Map<String, ({double totalPaid, double shareOwed, double netBalance})> getAllBalances() {
    final balances = <String, ({double totalPaid, double shareOwed, double netBalance})>{};
    for (final member in _members.values) {
      balances[member.name] = getMemberBalance(member.name);
    }
    return balances;
  }

  String getBalancesSummary() {
    final balances = getAllBalances();
    if (balances.isEmpty) return 'No members in group.';

    final creditors = <String, double>{};
    final debtors = <String, double>{};

    balances.forEach((member, bal) {
      if (bal.netBalance > 0.005) {
        creditors[member] = bal.netBalance;
      } else if (bal.netBalance < -0.005) {
        debtors[member] = -bal.netBalance;
      }
    });

    if (creditors.isEmpty && debtors.isEmpty) {
      return 'All balances are settled.';
    }

    final parts = <String>[];

    if (creditors.isNotEmpty) {
      final byAmt = <double, List<String>>{};
      creditors.forEach((m, amt) => byAmt.putIfAbsent(amt, () => []).add(m));
      final phrases = <String>[];
      byAmt.forEach((amt, names) {
        final amtStr = amt.truncateToDouble() == amt ? amt.toInt().toString() : amt.toStringAsFixed(2);
        final namesStr = _joinNames(names);
        if (names.length == 1) {
          phrases.add('$namesStr should receive INR $amtStr');
        } else {
          phrases.add('$namesStr each should receive INR $amtStr');
        }
      });
      parts.add(phrases.join(', '));
    }

    if (debtors.isNotEmpty) {
      final byAmt = <double, List<String>>{};
      debtors.forEach((m, amt) => byAmt.putIfAbsent(amt, () => []).add(m));
      final phrases = <String>[];
      byAmt.forEach((amt, names) {
        final amtStr = amt.truncateToDouble() == amt ? amt.toInt().toString() : amt.toStringAsFixed(2);
        final namesStr = _joinNames(names);
        if (names.length == 1) {
          phrases.add('$namesStr owes INR $amtStr');
        } else {
          phrases.add('$namesStr each owe INR $amtStr');
        }
      });
      parts.add(phrases.join(', '));
    }

    return '${parts.join('; ')}.';
  }

  void printBalances() {
    print(getBalancesSummary());
  }

  List<SettlementTransfer> suggestSettlements() {
    final balances = getAllBalances();
    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];

    balances.forEach((name, bal) {
      final net = bal.netBalance;
      if (net < -0.005) {
        debtors.add(MapEntry(name, -net));
      } else if (net > 0.005) {
        creditors.add(MapEntry(name, net));
      }
    });

    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    final transfers = <SettlementTransfer>[];
    int d = 0;
    int c = 0;

    final mutableDebtors = debtors.map((e) => e.value).toList();
    final mutableCreditors = creditors.map((e) => e.value).toList();

    while (d < debtors.length && c < creditors.length) {
      final payment = min(mutableDebtors[d], mutableCreditors[c]);
      final roundedPayment = double.parse(payment.toStringAsFixed(2));

      if (roundedPayment > 0.0) {
        transfers.add(SettlementTransfer(
          from: debtors[d].key,
          to: creditors[c].key,
          amount: roundedPayment,
        ));
      }

      mutableDebtors[d] -= payment;
      mutableCreditors[c] -= payment;

      if (mutableDebtors[d] < 0.005) d++;
      if (mutableCreditors[c] < 0.005) c++;
    }

    return transfers;
  }

  static String _joinNames(List<String> names) {
    if (names.length == 1) return names[0];
    if (names.length == 2) return '${names[0]} and ${names[1]}';
    return '${names.sublist(0, names.length - 1).join(', ')}, and ${names.last}';
  }
}
