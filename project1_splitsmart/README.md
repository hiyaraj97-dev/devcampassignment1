# SplitSmart - Dart Expense Splitter 💸

> **DevSource / DevCamp 2.0 • Week 1 • Project 1 • Compulsory**  
> Built with modern Dart (Dart 3.x with Records, Pattern Matching, Sealed Classes, Collections, and Enums).

SplitSmart is a command-line expense sharing and debt settlement engine that tracks group expenses, calculates net balances for all members, handles equal and custom splits, suggests minimal settlement transfers, and validates transactions with custom exceptions.

---

## 🚀 Two Ways to Run the Project

### Option 1: Local Dart Terminal (Recommended)

From the project directory:

```bash
# 1. Run all demonstrations (including the compulsory DevCamp example):
dart run main.dart

# 2. Open the Interactive Terminal Menu (with dart:io keyboard prompts):
dart run main.dart --interactive
# or
dart run bin/main.dart -i

# 3. Run the automated unit tests:
dart test
# or using the zero-dependency test runner:
dart run test/runner.dart
```

### Option 2: DartPad Fallback (Browser-based)

If you are using [DartPad](https://dartpad.dev/):
1. Open [`dartpad_main.dart`](file:///C:/Users/Admin/.gemini/antigravity/scratch/splitsmart/dartpad_main.dart).
2. Copy the entire file contents.
3. Paste into DartPad and click **Run**.
4. Both the compulsory specification example and multiple payer scenarios will execute immediately!

---

## 📋 Required Features Checklist

| Feature | Status | Description |
|---|---|---|
| **Add Group Members** | ✅ Complete | Unique IDs/names, case-insensitive checks, duplicate validation (`DuplicateMemberException`). |
| **Record Expenses** | ✅ Complete | Title, positive amount, payer validation, category enum, participant list, equal or custom split. |
| **List & Filter Expenses** | ✅ Complete | Filter expenses by member (payer/participant) or by category. |
| **Calculate Balances** | ✅ Complete | Computes Total Paid, Share Owed, and Net Balance across all expenses; returns typed Dart 3 records `({double totalPaid, double shareOwed, double netBalance})`. |
| **Error Handling** | ✅ Complete | Descriptive custom exceptions for duplicate members, unknown members, negative/zero amounts, empty participants, and mismatched splits. |
| **Compulsory Example** | ✅ Verified | Asha pays 900 for Dinner (split with Ravi & Neha) -> `Asha should receive INR 600; Ravi and Neha each owe INR 300.` |
| **Multiple Payers** | ✅ Complete | Tested and demonstrated across multi-expense group trips. |

---

## 🌟 Optional Extensions Implemented

1. **Suggest Settlement Transfers**: Greedy debt simplification algorithm that computes the minimal transactions required to settle all debts (e.g. `Ravi pays Asha INR 300`).
2. **Unequal & Custom Splits**: Support for exact amounts (`customShares`) and percentage splits (`percentages`) with validation.
3. **Consistent Rounding**: Exact paise/cents allocation algorithm preventing fractional currency leaks when dividing amounts that don't divide evenly (e.g., INR 100 among 3 participants splits into 33.34, 33.33, 33.33 summing to 100.00).
4. **Edit & Delete Expenses**: Full CRUD operations with automatic balance recalculation.
5. **Local JSON Persistence**: `group.saveToFile('expenses.json')` and `ExpenseGroup.loadFromFile('expenses.json')`.
6. **Dart 3 Records**: Member summaries returned as `({double totalPaid, double shareOwed, double netBalance})`.

---

## 📂 Project Structure

```
splitsmart/
├── bin/
│   └── main.dart                     # Entry point forwarding to main.dart
├── lib/
│   ├── splitsmart.dart               # Library barrel export
│   └── src/
│       ├── category.dart             # ExpenseCategory enum with emojis and parser
│       ├── cli.dart                  # Interactive terminal menu loop (dart:io)
│       ├── exceptions.dart           # Custom exception hierarchy
│       ├── expense.dart              # Expense model & split distribution algorithms
│       ├── expense_group.dart        # ExpenseGroup service (core business logic)
│       ├── member.dart               # Member entity
│       └── settlement.dart           # DebtSettlementCalculator algorithm
├── test/
│   ├── runner.dart                   # Zero-dependency test runner
│   └── splitsmart_test.dart          # Comprehensive unit tests (dart test)
├── dartpad_main.dart                 # Self-contained single file for DartPad
├── main.dart                         # Compulsory specification & demo runner
└── pubspec.yaml                      # Project configuration and dependencies
```

---

## 💡 Quick Code Example

```dart
import 'package:splitsmart/splitsmart.dart';

void main() {
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

  // Prints: Asha should receive INR 600; Ravi and Neha each owe INR 300.
  group.printBalances();

  // Prints optimal transfers:
  // 1. Ravi pays Asha INR 300
  // 2. Neha pays Asha INR 300
  for (final transfer in group.suggestSettlements()) {
    print(transfer);
  }
}
```

---

## 🧪 Testing

To execute all unit tests:
```bash
dart test
```
Result: **15 tests passed with 0 failures**.
Code analysis: `dart analyze` reports **No issues found!**
