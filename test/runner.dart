import 'dart:io';

import 'package:splitsmart/splitsmart.dart';

int _passed = 0;
int _failed = 0;

void expect(dynamic actual, dynamic expected, {String? reason}) {
  if (actual != expected) {
    throw Exception('Expected <$expected> but got <$actual>${reason != null ? " ($reason)" : ""}');
  }
}

void expectTrue(bool condition, {String? reason}) {
  if (!condition) {
    throw Exception('Expected true but was false${reason != null ? " ($reason)" : ""}');
  }
}

void expectThrows<T>(void Function() callback, {String? reason}) {
  try {
    callback();
    throw Exception('Expected exception of type $T, but nothing was thrown.');
  } catch (e) {
    if (e is! T) {
      throw Exception('Expected exception of type $T, but caught: ${e.runtimeType} ($e)');
    }
  }
}

void testCase(String description, void Function() body) {
  try {
    body();
    _passed++;
    print('  ✓ $description');
  } catch (e) {
    _failed++;
    print('  ✗ $description');
    print('     Error: $e');
  }
}

Future<void> asyncTestCase(String description, Future<void> Function() body) async {
  try {
    await body();
    _passed++;
    print('  ✓ $description');
  } catch (e) {
    _failed++;
    print('  ✗ $description');
    print('     Error: $e');
  }
}

Future<void> main() async {
  print('===============================================================');
  print('           SPLITSMART COMPREHENSIVE TEST RUNNER                ');
  print('===============================================================\n');

  print('[1] Member Management Tests:');
  testCase('Successfully add unique members', () {
    final group = ExpenseGroup();
    group.addMember('Asha');
    group.addMember('Ravi');
    expect(group.members.length, 2);
    expectTrue(group.hasMember('Asha'));
    expectTrue(group.hasMember('ravi'));
  });

  testCase('Reject duplicate members with DuplicateMemberException', () {
    final group = ExpenseGroup();
    group.addMember('Asha');
    expectThrows<DuplicateMemberException>(() => group.addMember('Asha'));
    expectThrows<DuplicateMemberException>(() => group.addMember('asha'));
  });

  testCase('Reject empty member names', () {
    final group = ExpenseGroup();
    expectThrows<ArgumentError>(() => group.addMember(''));
    expectThrows<ArgumentError>(() => group.addMember('   '));
  });

  print('\n[2] Required Compulsory Example:');
  testCase('Asha pays 900 for Dinner -> Asha receives 600; Ravi & Neha owe 300', () {
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

    final asha = group.getMemberBalance('Asha');
    final ravi = group.getMemberBalance('Ravi');
    final neha = group.getMemberBalance('Neha');

    expect(asha.totalPaid, 900.0);
    expect(asha.shareOwed, 300.0);
    expect(asha.netBalance, 600.0);

    expect(ravi.totalPaid, 0.0);
    expect(ravi.shareOwed, 300.0);
    expect(ravi.netBalance, -300.0);

    expect(neha.totalPaid, 0.0);
    expect(neha.shareOwed, 300.0);
    expect(neha.netBalance, -300.0);

    expect(
      group.getBalancesSummary(),
      'Asha should receive INR 600; Ravi and Neha each owe INR 300.',
    );
  });

  testCase('Suggests settlement transfers for compulsory example', () {
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

    final settlements = group.suggestSettlements();
    expect(settlements.length, 2);
    final strings = settlements.map((s) => s.toString()).toSet();
    expectTrue(strings.contains('Ravi pays Asha INR 300'));
    expectTrue(strings.contains('Neha pays Asha INR 300'));
  });

  print('\n[3] Multiple Payers Across Multiple Expenses:');
  testCase('Calculates accurate net balances and simplifies debts', () {
    final group = ExpenseGroup();
    group.addMember('Asha');
    group.addMember('Ravi');
    group.addMember('Neha');
    group.addMember('Vikram');

    group.addExpense(
      title: 'Hotel',
      amount: 1200,
      paidBy: 'Asha',
      category: ExpenseCategory.accommodation,
      splitBetween: ['Asha', 'Ravi', 'Neha', 'Vikram'],
    );

    group.addExpense(
      title: 'Food',
      amount: 800,
      paidBy: 'Ravi',
      category: ExpenseCategory.groceries,
      splitBetween: ['Asha', 'Ravi', 'Neha', 'Vikram'],
    );

    group.addExpense(
      title: 'Fuel',
      amount: 300,
      paidBy: 'Vikram',
      category: ExpenseCategory.travel,
      splitBetween: ['Asha', 'Ravi', 'Vikram'],
    );

    final asha = group.getMemberBalance('Asha');
    final ravi = group.getMemberBalance('Ravi');
    final neha = group.getMemberBalance('Neha');
    final vikram = group.getMemberBalance('Vikram');

    expect(asha.netBalance, 600.0);
    expect(ravi.netBalance, 200.0);
    expect(neha.netBalance, -500.0);
    expect(vikram.netBalance, -300.0);

    // Sum of net balances must be 0
    final netSum = asha.netBalance + ravi.netBalance + neha.netBalance + vikram.netBalance;
    expectTrue(netSum.abs() < 0.01, reason: 'Net balance sum should be zero');
  });

  print('\n[4] Expense Filtering:');
  testCase('Filter expenses by category and member', () {
    final group = ExpenseGroup();
    group.addMember('A');
    group.addMember('B');
    group.addMember('C');

    group.addExpense(
      title: 'Pizza',
      amount: 300,
      paidBy: 'A',
      category: 'Food',
      splitBetween: ['A', 'B'],
    );
    group.addExpense(
      title: 'Taxi',
      amount: 150,
      paidBy: 'B',
      category: 'Travel',
      splitBetween: ['B', 'C'],
    );

    final food = group.listExpenses(category: 'Food');
    expect(food.length, 1);
    expect(food.first.title, 'Pizza');

    final travel = group.listExpenses(category: 'Travel');
    expect(travel.length, 1);
    expect(travel.first.title, 'Taxi');

    final bExpenses = group.listExpenses(member: 'B');
    expect(bExpenses.length, 2);

    final cExpenses = group.listExpenses(member: 'C');
    expect(cExpenses.length, 1);
  });

  print('\n[5] Error Handling & Validation:');
  testCase('Reject unknown payer', () {
    final group = ExpenseGroup();
    group.addMember('A');
    expectThrows<MemberNotFoundException>(() => group.addExpense(
      title: 'Lunch',
      amount: 100,
      paidBy: 'Unknown',
      splitBetween: ['A'],
    ));
  });

  testCase('Reject unknown participant', () {
    final group = ExpenseGroup();
    group.addMember('A');
    expectThrows<MemberNotFoundException>(() => group.addExpense(
      title: 'Lunch',
      amount: 100,
      paidBy: 'A',
      splitBetween: ['A', 'Unknown'],
    ));
  });

  testCase('Reject non-positive or invalid amounts', () {
    final group = ExpenseGroup();
    group.addMember('A');
    expectThrows<InvalidAmountException>(() => group.addExpense(
      title: 'Free',
      amount: 0,
      paidBy: 'A',
      splitBetween: ['A'],
    ));
    expectThrows<InvalidAmountException>(() => group.addExpense(
      title: 'Negative',
      amount: -100,
      paidBy: 'A',
      splitBetween: ['A'],
    ));
  });

  testCase('Reject empty participants list', () {
    final group = ExpenseGroup();
    group.addMember('A');
    expectThrows<InvalidParticipantException>(() => group.addExpense(
      title: 'Solo',
      amount: 100,
      paidBy: 'A',
      splitBetween: [],
    ));
  });

  print('\n[6] Optional Extensions:');
  testCase('Unequal custom split', () {
    final group = ExpenseGroup();
    group.addMember('Alice');
    group.addMember('Bob');
    group.addExpense(
      title: 'Unequal Lunch',
      amount: 100,
      paidBy: 'Alice',
      splitBetween: ['Alice', 'Bob'],
      customShares: {'Alice': 30, 'Bob': 70},
    );
    expect(group.getMemberBalance('Alice').netBalance, 70.0);
    expect(group.getMemberBalance('Bob').netBalance, -70.0);
  });

  testCase('Even penny distribution for odd amounts', () {
    final group = ExpenseGroup();
    group.addMember('A');
    group.addMember('B');
    group.addMember('C');
    final exp = group.addExpense(
      title: '100 among 3',
      amount: 100,
      paidBy: 'A',
      splitBetween: ['A', 'B', 'C'],
    );
    double total = 0.0;
    exp.participantShares.forEach((_, s) => total += s);
    expect(total, 100.0);
  });

  testCase('Edit and delete expense', () {
    final group = ExpenseGroup();
    group.addMember('A');
    group.addMember('B');
    final exp = group.addExpense(
      title: 'Temp',
      amount: 100,
      paidBy: 'A',
      splitBetween: ['A', 'B'],
    );
    expect(group.getMemberBalance('A').netBalance, 50.0);

    group.editExpense(exp.id, amount: 200);
    expect(group.getMemberBalance('A').netBalance, 100.0);

    group.deleteExpense(exp.id);
    expect(group.expenses.isEmpty, true);
    expect(group.getMemberBalance('A').netBalance, 0.0);
  });

  await asyncTestCase('Save and load from JSON file', () async {
    final group = ExpenseGroup();
    group.addMember('A');
    group.addMember('B');
    group.addExpense(
      title: 'Dinner',
      amount: 200,
      paidBy: 'A',
      category: 'Food',
      splitBetween: ['A', 'B'],
    );

    final tempFile = '${Directory.systemTemp.path}/test_runner_${DateTime.now().millisecondsSinceEpoch}.json';
    await group.saveToFile(tempFile);

    final loaded = await ExpenseGroup.loadFromFile(tempFile);
    expect(loaded.members.length, 2);
    expect(loaded.expenses.length, 1);
    expect(loaded.getMemberBalance('A').netBalance, 100.0);

    final f = File(tempFile);
    if (await f.exists()) await f.delete();
  });

  print('\n===============================================================');
  print('TEST RESULTS: $_passed Passed, $_failed Failed');
  print('===============================================================');

  if (_failed > 0) {
    exit(1);
  }
}
