/// Interactive command-line interface for SplitSmart.
library;

import 'dart:io';

import 'category.dart';
import 'exceptions.dart';
import 'expense_group.dart';

/// Runs the interactive terminal menu loop using `dart:io`.
class SplitSmartCli {
  final ExpenseGroup group;

  SplitSmartCli([ExpenseGroup? initialGroup])
      : group = initialGroup ?? ExpenseGroup();

  void start() {
    print('\n===============================================================');
    print('          🌟 Welcome to SplitSmart - Expense Splitter 🌟       ');
    print('===============================================================');

    bool running = true;
    while (running) {
      _printMainMenu();
      final choice = _prompt('Select an option (1-9): ');

      switch (choice) {
        case '1':
          _addMemberFlow();
          break;
        case '2':
          _listMembersFlow();
          break;
        case '3':
          _addExpenseFlow();
          break;
        case '4':
          _listExpensesFlow();
          break;
        case '5':
          _viewBalancesFlow();
          break;
        case '6':
          _settlementsFlow();
          break;
        case '7':
          _editOrDeleteExpenseFlow();
          break;
        case '8':
          _saveLoadFlow();
          break;
        case '9':
          print('\nThank you for using SplitSmart! Goodbye! 👋\n');
          running = false;
          break;
        default:
          print('⚠️  Invalid choice. Please enter a number between 1 and 9.');
      }
    }
  }

  void _printMainMenu() {
    print('\n----------------------- MAIN MENU ----------------------------');
    print(' 1. Add Group Member');
    print(' 2. List Group Members');
    print(' 3. Record New Expense');
    print(' 4. List & Filter Expenses');
    print(' 5. View Balances (Summary & Report)');
    print(' 6. Suggest Settlement Transfers');
    print(' 7. Edit or Delete Expense');
    print(' 8. Save / Load Group Data (JSON)');
    print(' 9. Exit');
    print('--------------------------------------------------------------');
  }

  void _addMemberFlow() {
    print('\n--- Add Group Member ---');
    final name = _prompt('Enter member name: ');
    if (name.isEmpty) {
      print('❌ Error: Member name cannot be empty.');
      return;
    }

    try {
      group.addMember(name);
      print('✅ Successfully added member "$name".');
    } on SplitSmartException catch (e) {
      print('❌ $e');
    } catch (e) {
      print('❌ Unexpected error: $e');
    }
  }

  void _listMembersFlow() {
    print('\n--- Group Members (${group.members.length}) ---');
    if (group.members.isEmpty) {
      print('No members added yet. Choose option 1 to add members.');
      return;
    }
    for (int i = 0; i < group.members.length; i++) {
      print('  ${i + 1}. ${group.members[i].name}');
    }
  }

  void _addExpenseFlow() {
    print('\n--- Record New Expense ---');
    if (group.members.length < 2) {
      print('⚠️  Please add at least 2 members before recording an expense.');
      return;
    }

    final title = _prompt('Enter expense title (e.g. Dinner, Fuel): ');
    if (title.isEmpty) {
      print('❌ Expense title cannot be empty.');
      return;
    }

    final amountStr = _prompt('Enter amount (e.g. 900): ');
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      print('❌ Invalid amount. Must be a positive number.');
      return;
    }

    print('Available members: ${group.members.map((m) => m.name).join(', ')}');
    final payer = _prompt('Who paid for this expense?: ');
    if (!group.hasMember(payer)) {
      print('❌ Member "$payer" does not exist in the group.');
      return;
    }

    print('\nCategories:');
    for (int i = 0; i < ExpenseCategory.values.length; i++) {
      final c = ExpenseCategory.values[i];
      print('  ${i + 1}. ${c.emoji} ${c.label}');
    }
    final catChoice = _prompt('Select category number or name (default Food): ');
    final category = _resolveCategory(catChoice);

    print('\nParticipants to split between:');
    print('  - Press Enter to split among ALL members');
    print('  - Or enter comma-separated names (e.g. Asha, Ravi)');
    final participantsInput = _prompt('Split between: ');

    List<String> participants;
    if (participantsInput.isEmpty) {
      participants = group.members.map((m) => m.name).toList();
    } else {
      participants = participantsInput
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Verify all participants
    for (final p in participants) {
      if (!group.hasMember(p)) {
        print('❌ Participant "$p" is not registered in the group.');
        return;
      }
    }

    print('\nSplit type:');
    print('  1. Equal split (default)');
    print('  2. Custom exact amounts');
    print('  3. Custom percentage split');
    final splitTypeChoice = _prompt('Select split type (1-3, default 1): ');

    try {
      if (splitTypeChoice == '2') {
        final exactShares = <String, num>{};
        print('Enter exact share for each participant (must sum to $amount):');
        for (final p in participants) {
          final shareStr = _prompt('  Share for $p: ');
          final share = double.tryParse(shareStr) ?? 0.0;
          exactShares[p] = share;
        }
        group.addExpense(
          title: title,
          amount: amount,
          paidBy: payer,
          category: category,
          splitBetween: participants,
          customShares: exactShares,
        );
      } else if (splitTypeChoice == '3') {
        final percentages = <String, num>{};
        print('Enter percentage share for each participant (must sum to 100):');
        for (final p in participants) {
          final pctStr = _prompt('  Percentage for $p (%): ');
          final pct = double.tryParse(pctStr) ?? 0.0;
          percentages[p] = pct;
        }
        group.addExpense(
          title: title,
          amount: amount,
          paidBy: payer,
          category: category,
          splitBetween: participants,
          percentages: percentages,
        );
      } else {
        group.addExpense(
          title: title,
          amount: amount,
          paidBy: payer,
          category: category,
          splitBetween: participants,
        );
      }
      print('✅ Expense "$title" of INR $amount recorded successfully!');
    } on SplitSmartException catch (e) {
      print('❌ $e');
    } catch (e) {
      print('❌ Unexpected error: $e');
    }
  }

  void _listExpensesFlow() {
    print('\n--- List & Filter Expenses ---');
    if (group.expenses.isEmpty) {
      print('No expenses recorded yet.');
      return;
    }

    print('Filter options:');
    print('  1. View all expenses');
    print('  2. Filter by member');
    print('  3. Filter by category');
    final filterChoice = _prompt('Select option (1-3): ');

    List expensesToShow;
    if (filterChoice == '2') {
      final member = _prompt('Enter member name to filter: ');
      expensesToShow = group.listExpenses(member: member);
      print('\nExpenses involving "$member":');
    } else if (filterChoice == '3') {
      final catInput = _prompt('Enter category name: ');
      expensesToShow = group.listExpenses(category: catInput);
      print('\nExpenses in category "$catInput":');
    } else {
      expensesToShow = group.expenses;
      print('\nAll Expenses:');
    }

    if (expensesToShow.isEmpty) {
      print('No matching expenses found.');
      return;
    }

    for (int i = 0; i < expensesToShow.length; i++) {
      final exp = expensesToShow[i];
      print('  ${i + 1}. [${exp.id}] ${exp.title}');
      print('     Amount: INR ${exp.amount} | Payer: ${exp.paidBy} | Category: ${exp.category.emoji} ${exp.category.label}');
      print('     Split between: ${exp.splitBetween.join(', ')}');
      print('     Shares: ${exp.participantShares.entries.map((e) => '${e.key}: INR ${e.value}').join(', ')}');
    }
  }

  void _viewBalancesFlow() {
    print('\n--- Balances ---');
    if (group.members.isEmpty) {
      print('No members in group.');
      return;
    }

    print('1. Concise Summary (as required by specification)');
    print('2. Detailed Tabular Report');
    final viewChoice = _prompt('Select view (1-2, default 1): ');

    if (viewChoice == '2') {
      group.printDetailedReport();
    } else {
      print('\nResult:');
      group.printBalances();
    }
  }

  void _settlementsFlow() {
    print('\n--- Debt Settlement Transfers ---');
    final settlements = group.suggestSettlements();
    if (settlements.isEmpty) {
      print('🎉 All balances are settled! No transfers needed.');
      return;
    }

    print('Optimal transfers to settle all group debts:');
    for (int i = 0; i < settlements.length; i++) {
      print('  ${i + 1}. ${settlements[i]}');
    }
  }

  void _editOrDeleteExpenseFlow() {
    print('\n--- Edit or Delete Expense ---');
    if (group.expenses.isEmpty) {
      print('No expenses to edit or delete.');
      return;
    }

    for (int i = 0; i < group.expenses.length; i++) {
      final exp = group.expenses[i];
      print('  ${i + 1}. [${exp.id}] ${exp.title} (INR ${exp.amount}, paid by ${exp.paidBy})');
    }

    final id = _prompt('Enter Expense ID to edit or delete: ');
    final action = _prompt('Do you want to (e)dit or (d)elete? (e/d): ');

    if (action.toLowerCase() == 'd') {
      try {
        group.deleteExpense(id);
        print('✅ Expense deleted successfully.');
      } on SplitSmartException catch (e) {
        print('❌ $e');
      }
    } else if (action.toLowerCase() == 'e') {
      final newTitle = _prompt('Enter new title (or press Enter to keep): ');
      final newAmtStr = _prompt('Enter new amount (or press Enter to keep): ');
      final num? newAmt = newAmtStr.isNotEmpty ? double.tryParse(newAmtStr) : null;

      try {
        group.editExpense(
          id,
          title: newTitle.isNotEmpty ? newTitle : null,
          amount: newAmt,
        );
        print('✅ Expense updated successfully.');
      } on SplitSmartException catch (e) {
        print('❌ $e');
      }
    }
  }

  void _saveLoadFlow() {
    print('\n--- Save / Load JSON ---');
    print('  1. Save current group state to JSON file');
    print('  2. Load group state from JSON file');
    final choice = _prompt('Select option (1-2): ');

    final defaultPath = 'expenses_data.json';
    if (choice == '1') {
      final path = _prompt('Enter file path (default: $defaultPath): ');
      final target = path.isEmpty ? defaultPath : path;
      try {
        group.saveToFile(target);
        print('✅ Successfully saved group data to "$target".');
      } catch (e) {
        print('❌ Failed to save file: $e');
      }
    } else if (choice == '2') {
      final path = _prompt('Enter file path to load (default: $defaultPath): ');
      final target = path.isEmpty ? defaultPath : path;
      try {
        ExpenseGroup.loadFromFile(target).then((loaded) {
          group.importData(loaded);
          print('✅ Successfully loaded data from "$target"! (${group.members.length} members, ${group.expenses.length} expenses)');
        }).catchError((e) {
          print('❌ Failed to load file: $e');
        });
      } catch (e) {
        print('❌ Error: $e');
      }
    }
  }

  static String _prompt(String message) {
    stdout.write(message);
    return stdin.readLineSync()?.trim() ?? '';
  }

  static ExpenseCategory _resolveCategory(String input) {
    if (input.isEmpty) return ExpenseCategory.food;
    final index = int.tryParse(input);
    if (index != null && index >= 1 && index <= ExpenseCategory.values.length) {
      return ExpenseCategory.values[index - 1];
    }
    return ExpenseCategory.fromString(input);
  }
}
