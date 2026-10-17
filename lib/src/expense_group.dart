/// Central ExpenseGroup manager for SplitSmart.
library;

import 'dart:convert';
import 'dart:io';

import 'category.dart';
import 'exceptions.dart';
import 'expense.dart';
import 'member.dart';
import 'settlement.dart';

/// Dart 3 Record representing an individual member's financial balance.
typedef MemberBalance = ({double totalPaid, double shareOwed, double netBalance});

/// Primary service managing members, expenses, balances, and settlements for a group.
class ExpenseGroup {
  final Map<String, Member> _members = {};
  final List<Expense> _expenses = [];

  ExpenseGroup();

  /// Returns unmodifiable list of registered members.
  List<Member> get members => List.unmodifiable(_members.values);

  /// Returns unmodifiable list of all recorded expenses.
  List<Expense> get expenses => List.unmodifiable(_expenses);

  /// Total sum of all group expenses recorded.
  double get totalExpenses =>
      _expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  /// Checks if a member with [nameOrId] exists.
  bool hasMember(String nameOrId) {
    final key = nameOrId.trim().toLowerCase();
    return _members.containsKey(key);
  }

  /// Adds a new member to the group with validation.
  /// Throws [DuplicateMemberException] if a member with the same name already exists.
  Member addMember(String name, {String? id}) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Member name cannot be empty.');
    }

    final key = trimmedName.toLowerCase();
    if (_members.containsKey(key)) {
      throw DuplicateMemberException(trimmedName);
    }

    final member = Member(name: trimmedName, id: id);
    _members[key] = member;
    return member;
  }

  /// Helper to get the canonical Member object by name or ID.
  Member _getMember(String nameOrId) {
    final key = nameOrId.trim().toLowerCase();
    final member = _members[key];
    if (member == null) {
      throw MemberNotFoundException(nameOrId);
    }
    return member;
  }

  /// Records a new expense shared among group members.
  ///
  /// Required parameters:
  /// - [title]: Descriptive name of the expense.
  /// - [amount]: Positive expense amount (can be `int` or `double`).
  /// - [paidBy]: Name of the member who paid. Must exist in the group.
  /// - [category]: Expense category (String or [ExpenseCategory]).
  /// - [splitBetween]: List of participant member names. Must all exist in the group.
  ///
  /// Optional parameters:
  /// - [customShares]: Map of member name -> exact amount owed.
  /// - [percentages]: Map of member name -> percentage owed (sums to 100).
  /// - [notes]: Additional notes for the expense.
  /// - [date]: Timestamp of when expense occurred.
  Expense addExpense({
    required String title,
    required num amount,
    required String paidBy,
    dynamic category = ExpenseCategory.other,
    required List<String> splitBetween,
    Map<String, num>? customShares,
    Map<String, num>? percentages,
    String? notes,
    DateTime? date,
    String? id,
  }) {
    // 1. Validate payer
    final payer = _getMember(paidBy);

    // 2. Validate participants
    if (splitBetween.isEmpty) {
      throw InvalidParticipantException('Participant list cannot be empty.');
    }

    final validatedParticipants = <String>[];
    for (final p in splitBetween) {
      final member = _getMember(p);
      if (!validatedParticipants.contains(member.name)) {
        validatedParticipants.add(member.name);
      }
    }

    final parsedCategory = ExpenseCategory.fromString(category);
    final expenseId = id ?? 'exp_${DateTime.now().millisecondsSinceEpoch}_${_expenses.length + 1}';
    final doubleAmount = amount.toDouble();

    Expense expense;
    if (customShares != null) {
      final doubleShares = <String, double>{};
      for (final entry in customShares.entries) {
        final m = _getMember(entry.key);
        doubleShares[m.name] = entry.value.toDouble();
      }
      expense = Expense.withCustomSplit(
        id: expenseId,
        title: title,
        amount: doubleAmount,
        paidBy: payer.name,
        category: parsedCategory,
        exactShares: doubleShares,
        date: date,
        notes: notes,
      );
    } else if (percentages != null) {
      final doublePercentages = <String, double>{};
      for (final entry in percentages.entries) {
        final m = _getMember(entry.key);
        doublePercentages[m.name] = entry.value.toDouble();
      }
      expense = Expense.withPercentageSplit(
        id: expenseId,
        title: title,
        amount: doubleAmount,
        paidBy: payer.name,
        category: parsedCategory,
        percentages: doublePercentages,
        date: date,
        notes: notes,
      );
    } else {
      expense = Expense(
        id: expenseId,
        title: title,
        amount: doubleAmount,
        paidBy: payer.name,
        category: parsedCategory,
        splitBetween: validatedParticipants,
        date: date,
        notes: notes,
      );
    }

    _expenses.add(expense);
    return expense;
  }

  /// Lists all recorded expenses, optionally filtered by member and/or category.
  List<Expense> listExpenses({
    String? member,
    dynamic category,
  }) {
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

  /// Deletes an expense by ID.
  bool deleteExpense(String expenseId) {
    final index = _expenses.indexWhere((e) => e.id == expenseId);
    if (index == -1) {
      throw ExpenseNotFoundException(expenseId);
    }
    _expenses.removeAt(index);
    return true;
  }

  /// Edits an existing expense.
  Expense editExpense(
    String expenseId, {
    String? title,
    num? amount,
    String? paidBy,
    dynamic category,
    List<String>? splitBetween,
    Map<String, num>? customShares,
  }) {
    final index = _expenses.indexWhere((e) => e.id == expenseId);
    if (index == -1) {
      throw ExpenseNotFoundException(expenseId);
    }

    final old = _expenses[index];
    final updatedTitle = title ?? old.title;
    final updatedAmount = amount?.toDouble() ?? old.amount;
    final updatedPaidBy = paidBy ?? old.paidBy;
    final updatedCategory = category != null
        ? ExpenseCategory.fromString(category)
        : old.category;
    final updatedSplitBetween = splitBetween ?? old.splitBetween;

    // Validate payer and participants exist
    _getMember(updatedPaidBy);
    for (final p in updatedSplitBetween) {
      _getMember(p);
    }

    final Expense updatedExpense;
    if (customShares != null) {
      final doubleShares = customShares.map((k, v) => MapEntry(k, v.toDouble()));
      updatedExpense = Expense.withCustomSplit(
        id: old.id,
        title: updatedTitle,
        amount: updatedAmount,
        paidBy: updatedPaidBy,
        category: updatedCategory,
        exactShares: doubleShares,
        date: old.date,
        notes: old.notes,
      );
    } else {
      updatedExpense = Expense(
        id: old.id,
        title: updatedTitle,
        amount: updatedAmount,
        paidBy: updatedPaidBy,
        category: updatedCategory,
        splitBetween: updatedSplitBetween,
        date: old.date,
        notes: old.notes,
      );
    }

    _expenses[index] = updatedExpense;
    return updatedExpense;
  }

  /// Calculates financial balance record for a single member:
  /// `totalPaid`, `shareOwed`, and `netBalance = totalPaid - shareOwed`.
  MemberBalance getMemberBalance(String memberNameOrId) {
    final member = _getMember(memberNameOrId);
    double totalPaid = 0.0;
    double shareOwed = 0.0;

    for (final exp in _expenses) {
      if (exp.paidBy.toLowerCase() == member.name.toLowerCase()) {
        totalPaid += exp.amount;
      }
      final memberShare = exp.participantShares[member.name];
      if (memberShare != null) {
        shareOwed += memberShare;
      }
    }

    final netBalance = totalPaid - shareOwed;
    return (
      totalPaid: _round2(totalPaid),
      shareOwed: _round2(shareOwed),
      netBalance: _round2(netBalance),
    );
  }

  /// Computes balances for all registered members.
  Map<String, MemberBalance> getAllBalances() {
    final balances = <String, MemberBalance>{};
    for (final member in _members.values) {
      balances[member.name] = getMemberBalance(member.name);
    }
    return balances;
  }

  /// Generates the concise summary string matching the required expected format:
  /// e.g. "Asha should receive INR 600; Ravi and Neha each owe INR 300."
  String getBalancesSummary() {
    final balances = getAllBalances();
    if (balances.isEmpty) return 'No members in group.';

    final creditors = <String, double>{};
    final debtors = <String, double>{};
    final settled = <String>[];

    balances.forEach((member, bal) {
      if (bal.netBalance > 0.005) {
        creditors[member] = bal.netBalance;
      } else if (bal.netBalance < -0.005) {
        debtors[member] = -bal.netBalance;
      } else {
        settled.add(member);
      }
    });

    if (creditors.isEmpty && debtors.isEmpty) {
      return 'All balances are settled.';
    }

    final parts = <String>[];

    // Format creditors
    if (creditors.isNotEmpty) {
      // Group creditors by amount if identical
      final creditorsByAmount = <double, List<String>>{};
      creditors.forEach((m, amt) {
        creditorsByAmount.putIfAbsent(amt, () => []).add(m);
      });

      final creditorPhrases = <String>[];
      creditorsByAmount.forEach((amt, names) {
        final namesStr = _joinNames(names);
        final amtStr = _formatCurrency(amt);
        if (names.length == 1) {
          creditorPhrases.add('$namesStr should receive INR $amtStr');
        } else {
          creditorPhrases.add('$namesStr each should receive INR $amtStr');
        }
      });
      parts.add(creditorPhrases.join(', '));
    }

    // Format debtors
    if (debtors.isNotEmpty) {
      // Group debtors by amount if identical
      final debtorsByAmount = <double, List<String>>{};
      debtors.forEach((m, amt) {
        debtorsByAmount.putIfAbsent(amt, () => []).add(m);
      });

      final debtorPhrases = <String>[];
      debtorsByAmount.forEach((amt, names) {
        final namesStr = _joinNames(names);
        final amtStr = _formatCurrency(amt);
        if (names.length == 1) {
          debtorPhrases.add('$namesStr owes INR $amtStr');
        } else {
          debtorPhrases.add('$namesStr each owe INR $amtStr');
        }
      });
      parts.add(debtorPhrases.join(', '));
    }

    return '${parts.join('; ')}.';
  }

  /// Prints balances according to the project requirement.
  void printBalances({bool detailed = false}) {
    if (!detailed) {
      print(getBalancesSummary());
    } else {
      printDetailedReport();
    }
  }

  /// Prints a structured breakdown report of all members, expenses, and settlements.
  void printDetailedReport() {
    print('===============================================================');
    print('                      SPLITSMART SUMMARY                       ');
    print('===============================================================');
    print('Registered Members: ${_members.values.map((m) => m.name).join(', ')}');
    print('Total Expenses Recorded: INR ${_formatCurrency(totalExpenses)} (${_expenses.length} expenses)');
    print('---------------------------------------------------------------');
    print('${'Member'.padRight(15)} | ${'Total Paid'.padLeft(12)} | ${'Share Owed'.padLeft(12)} | ${'Net Balance'.padLeft(14)}');
    print('---------------------------------------------------------------');

    final balances = getAllBalances();
    balances.forEach((name, bal) {
      final paid = 'INR ${_formatCurrency(bal.totalPaid)}'.padLeft(12);
      final owed = 'INR ${_formatCurrency(bal.shareOwed)}'.padLeft(12);
      final sign = bal.netBalance > 0 ? '+' : '';
      final net = '$sign${_formatCurrency(bal.netBalance)}'.padLeft(10);
      final status = bal.netBalance > 0.005
          ? '(Receives)'
          : bal.netBalance < -0.005
              ? '(Owes)'
              : '(Settled)';
      print('${name.padRight(15)} | $paid | $owed | INR $net $status');
    });

    print('---------------------------------------------------------------');
    print('Summary: ${getBalancesSummary()}');
    print('---------------------------------------------------------------');
    final settlements = suggestSettlements();
    if (settlements.isEmpty) {
      print('Settlement Status: All debts are currently settled! 🎉');
    } else {
      print('Suggested Settlement Transfers:');
      for (int i = 0; i < settlements.length; i++) {
        print('  ${i + 1}. ${settlements[i]}');
      }
    }
    print('===============================================================\n');
  }

  /// Calculates minimal transactions required to settle all debts in the group.
  List<SettlementTransfer> suggestSettlements() {
    final netBalances = <String, double>{};
    getAllBalances().forEach((name, bal) {
      netBalances[name] = bal.netBalance;
    });
    return DebtSettlementCalculator.calculateSettlements(netBalances);
  }

  /// Formats currency to whole rupees when possible, or 2 decimal places.
  static String _formatCurrency(double amount) {
    if (amount.truncateToDouble() == amount) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  static double _round2(double val) {
    return double.parse(val.toStringAsFixed(2));
  }

  static String _joinNames(List<String> names) {
    if (names.length == 1) return names[0];
    if (names.length == 2) return '${names[0]} and ${names[1]}';
    return '${names.sublist(0, names.length - 1).join(', ')}, and ${names.last}';
  }

  /// Clears all members and expenses.
  void clear() {
    _members.clear();
    _expenses.clear();
  }

  /// Imports members and expenses from another ExpenseGroup instance.
  void importData(ExpenseGroup other) {
    clear();
    for (final member in other.members) {
      _members[member.name.toLowerCase()] = member;
    }
    _expenses.addAll(other.expenses);
  }

  // JSON Serialization for persistent storage

  Map<String, dynamic> toJson() => {
        'members': _members.values.map((m) => m.toJson()).toList(),
        'expenses': _expenses.map((e) => e.toJson()).toList(),
      };

  factory ExpenseGroup.fromJson(Map<String, dynamic> json) {
    final group = ExpenseGroup();
    if (json['members'] != null) {
      for (final item in json['members'] as List) {
        final member = Member.fromJson(item as Map<String, dynamic>);
        group._members[member.name.toLowerCase()] = member;
      }
    }
    if (json['expenses'] != null) {
      for (final item in json['expenses'] as List) {
        final expense = Expense.fromJson(item as Map<String, dynamic>);
        group._expenses.add(expense);
      }
    }
    return group;
  }

  /// Saves group state to a JSON file.
  Future<void> saveToFile(String filePath) async {
    final file = File(filePath);
    final encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(toJson()));
  }

  /// Loads group state from a JSON file.
  static Future<ExpenseGroup> loadFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File does not exist', filePath);
    }
    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return ExpenseGroup.fromJson(json);
  }
}
