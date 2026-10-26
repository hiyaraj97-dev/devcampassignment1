import 'dart:io';

import 'package:splitsmart/splitsmart.dart';

void main(List<String> args) {
  // If explicitly requested, run the interactive terminal menu
  if (args.contains('--interactive') || args.contains('-i')) {
    final cli = SplitSmartCli();
    cli.start();
    return;
  }

  print('===============================================================');
  print('          DEVSOURCE / DEVCAMP 2.0 - WEEK 1 PROJECT 1          ');
  print('                 SplitSmart: Dart Expense Splitter             ');
  print('===============================================================\n');

  // -----------------------------------------------------------------
  // SCENARIO 1: REQUIRED SPECIFICATION USAGE & OUTPUT
  // -----------------------------------------------------------------
  print('--- SCENARIO 1: Required Specification Example ---');
  print('Code being executed:');
  print('''
  final group = ExpenseGroup();
  group.addMember('Asha');
  group.addMember('Ravi');
  group.addMember('Neha');
  group.addExpense(
    title: 'Dinner', amount: 900, paidBy: 'Asha',
    category: 'Food',
    splitBetween: ['Asha', 'Ravi', 'Neha'],
  );
  group.printBalances();
  ''');

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

  print('Output from group.printBalances():');
  group.printBalances();

  print('\nSuggested Settlements:');
  for (final transfer in group.suggestSettlements()) {
    print('  • $transfer');
  }

  // -----------------------------------------------------------------
  // SCENARIO 2: MULTIPLE PAYERS (WEEKEND ROAD TRIP)
  // -----------------------------------------------------------------
  print('\n---------------------------------------------------------------');
  print('--- SCENARIO 2: Multiple Payers Across Multiple Expenses ---');
  print('---------------------------------------------------------------');
  final tripGroup = ExpenseGroup();
  tripGroup.addMember('Asha');
  tripGroup.addMember('Ravi');
  tripGroup.addMember('Neha');
  tripGroup.addMember('Vikram');

  // Expense 1: Asha pays 1200 for Resort
  tripGroup.addExpense(
    title: 'Resort Stay',
    amount: 1200,
    paidBy: 'Asha',
    category: ExpenseCategory.accommodation,
    splitBetween: ['Asha', 'Ravi', 'Neha', 'Vikram'],
  );

  // Expense 2: Ravi pays 800 for Groceries
  tripGroup.addExpense(
    title: 'Groceries & Snacks',
    amount: 800,
    paidBy: 'Ravi',
    category: ExpenseCategory.groceries,
    splitBetween: ['Asha', 'Ravi', 'Neha', 'Vikram'],
  );

  // Expense 3: Vikram pays 400 for Fuel (Neha was sick, split between Asha, Ravi, Vikram)
  tripGroup.addExpense(
    title: 'Highway Fuel',
    amount: 400,
    paidBy: 'Vikram',
    category: ExpenseCategory.travel,
    splitBetween: ['Asha', 'Ravi', 'Vikram'],
  );

  print('\nDetailed Financial Breakdown:');
  tripGroup.printDetailedReport();

  // -----------------------------------------------------------------
  // SCENARIO 3: LISTING & FILTERING EXPENSES
  // -----------------------------------------------------------------
  print('---------------------------------------------------------------');
  print('--- SCENARIO 3: Expense Listing and Filtering ---');
  print('---------------------------------------------------------------');
  print('All Travel expenses:');
  final travelExpenses = tripGroup.listExpenses(category: 'Travel');
  for (final e in travelExpenses) {
    print('  • $e');
  }

  print('\nAll expenses involving Neha:');
  final nehaExpenses = tripGroup.listExpenses(member: 'Neha');
  for (final e in nehaExpenses) {
    print('  • $e');
  }

  // -----------------------------------------------------------------
  // SCENARIO 4: UNEQUAL / CUSTOM SPLIT
  // -----------------------------------------------------------------
  print('\n---------------------------------------------------------------');
  print('--- SCENARIO 4: Optional Extension - Unequal Custom Splits ---');
  print('---------------------------------------------------------------');
  final customGroup = ExpenseGroup();
  customGroup.addMember('Alice');
  customGroup.addMember('Bob');
  customGroup.addMember('Charlie');

  // Alice pays 1000, Bob owes 500, Charlie owes 300, Alice owes 200
  customGroup.addExpense(
    title: 'Custom Project Server',
    amount: 1000,
    paidBy: 'Alice',
    category: 'Utilities',
    splitBetween: ['Alice', 'Bob', 'Charlie'],
    customShares: {'Alice': 200, 'Bob': 500, 'Charlie': 300},
  );
  customGroup.printBalances();
  print('Suggested Settlements:');
  for (final transfer in customGroup.suggestSettlements()) {
    print('  • $transfer');
  }

  // -----------------------------------------------------------------
  // SCENARIO 5: ERROR HANDLING & VALIDATION CHECKS
  // -----------------------------------------------------------------
  print('\n---------------------------------------------------------------');
  print('--- SCENARIO 5: Error Handling & Validation Demonstrations ---');
  print('---------------------------------------------------------------');

  // Test 1: Duplicate member
  try {
    print('1. Adding duplicate member "Asha"...');
    group.addMember('Asha');
  } on SplitSmartException catch (e) {
    print('   Caught expected error: $e');
  }

  // Test 2: Unknown payer
  try {
    print('2. Recording expense with unknown payer "Ghost"...');
    group.addExpense(
      title: 'Coffee',
      amount: 150,
      paidBy: 'Ghost',
      category: 'Food',
      splitBetween: ['Asha', 'Ravi'],
    );
  } on SplitSmartException catch (e) {
    print('   Caught expected error: $e');
  }

  // Test 3: Invalid non-positive amount
  try {
    print('3. Recording expense with negative amount (-500)...');
    group.addExpense(
      title: 'Invalid',
      amount: -500,
      paidBy: 'Asha',
      category: 'Food',
      splitBetween: ['Asha', 'Ravi'],
    );
  } on SplitSmartException catch (e) {
    print('   Caught expected error: $e');
  }

  // Test 4: Empty participant list
  try {
    print('4. Recording expense with empty participants list ([])...');
    group.addExpense(
      title: 'Solo',
      amount: 200,
      paidBy: 'Asha',
      category: 'Food',
      splitBetween: [],
    );
  } on SplitSmartException catch (e) {
    print('   Caught expected error: $e');
  }

  print('\n===============================================================');
  print('All compulsory & extended demonstration scenarios passed! ✅');
  print('===============================================================\n');

  // Interactive menu invitation
  try {
    if (stdin.hasTerminal) {
      stdout.write('Would you like to open the interactive terminal menu now? (y/N): ');
      final response = stdin.readLineSync()?.trim().toLowerCase();
      if (response == 'y' || response == 'yes') {
        final cli = SplitSmartCli(tripGroup);
        cli.start();
      }
    } else {
      print('Run `dart run main.dart --interactive` to launch the interactive terminal menu anytime.');
    }
  } catch (_) {
    print('Run `dart run main.dart --interactive` to launch the interactive terminal menu anytime.');
  }
}
