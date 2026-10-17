import 'dart:io';

import 'package:splitsmart/splitsmart.dart';
import 'package:test/test.dart';

void main() {
  group('Member Management', () {
    test('adds members successfully', () {
      final group = ExpenseGroup();
      final m1 = group.addMember('Asha');
      final m2 = group.addMember('Ravi');

      expect(group.members.length, equals(2));
      expect(group.hasMember('Asha'), isTrue);
      expect(group.hasMember('ravi'), isTrue); // Case-insensitive
      expect(m1.name, equals('Asha'));
      expect(m2.name, equals('Ravi'));
    });

    test('throws DuplicateMemberException for duplicate member names', () {
      final group = ExpenseGroup();
      group.addMember('Asha');

      expect(
        () => group.addMember('Asha'),
        throwsA(isA<DuplicateMemberException>()),
      );
      expect(
        () => group.addMember('asha'), // Case-insensitive duplicate check
        throwsA(isA<DuplicateMemberException>()),
      );
    });

    test('throws ArgumentError for empty or whitespace-only names', () {
      final group = ExpenseGroup();
      expect(() => group.addMember(''), throwsA(isA<ArgumentError>()));
      expect(() => group.addMember('   '), throwsA(isA<ArgumentError>()));
    });
  });

  group('Expense Recording & Balances (Compulsory Example)', () {
    test('computes correct balances for DevCamp compulsory example', () {
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

      final ashaBal = group.getMemberBalance('Asha');
      final raviBal = group.getMemberBalance('Ravi');
      final nehaBal = group.getMemberBalance('Neha');

      // Asha paid 900, share is 300, net balance = +600 (receives 600)
      expect(ashaBal.totalPaid, equals(900.0));
      expect(ashaBal.shareOwed, equals(300.0));
      expect(ashaBal.netBalance, equals(600.0));

      // Ravi paid 0, share is 300, net balance = -300 (owes 300)
      expect(raviBal.totalPaid, equals(0.0));
      expect(raviBal.shareOwed, equals(300.0));
      expect(raviBal.netBalance, equals(-300.0));

      // Neha paid 0, share is 300, net balance = -300 (owes 300)
      expect(nehaBal.totalPaid, equals(0.0));
      expect(nehaBal.shareOwed, equals(300.0));
      expect(nehaBal.netBalance, equals(-300.0));

      // Check expected summary string
      expect(
        group.getBalancesSummary(),
        equals('Asha should receive INR 600; Ravi and Neha each owe INR 300.'),
      );
    });

    test('suggests optimal settlements for compulsory example', () {
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
      expect(settlements.length, equals(2));

      final descriptions = settlements.map((s) => s.toString()).toSet();
      expect(descriptions, contains('Ravi pays Asha INR 300'));
      expect(descriptions, contains('Neha pays Asha INR 300'));
    });
  });

  group('Multiple Payers & Multiple Expenses', () {
    test('accurately calculates balances across multiple expenses with multiple payers', () {
      final group = ExpenseGroup();
      group.addMember('Asha');
      group.addMember('Ravi');
      group.addMember('Neha');
      group.addMember('Vikram');

      // Asha pays 1200 split equally among all 4 (300 each)
      group.addExpense(
        title: 'Resort Stay',
        amount: 1200,
        paidBy: 'Asha',
        category: ExpenseCategory.accommodation,
        splitBetween: ['Asha', 'Ravi', 'Neha', 'Vikram'],
      );

      // Ravi pays 800 split equally among all 4 (200 each)
      group.addExpense(
        title: 'Groceries',
        amount: 800,
        paidBy: 'Ravi',
        category: ExpenseCategory.groceries,
        splitBetween: ['Asha', 'Ravi', 'Neha', 'Vikram'],
      );

      // Vikram pays 300 split equally among Asha, Ravi, Vikram (100 each)
      group.addExpense(
        title: 'Fuel',
        amount: 300,
        paidBy: 'Vikram',
        category: ExpenseCategory.travel,
        splitBetween: ['Asha', 'Ravi', 'Vikram'],
      );

      // Asha: Paid 1200, owes (300 + 200 + 100) = 600 -> Net = +600
      final asha = group.getMemberBalance('Asha');
      expect(asha.totalPaid, equals(1200.0));
      expect(asha.shareOwed, equals(600.0));
      expect(asha.netBalance, equals(600.0));

      // Ravi: Paid 800, owes (300 + 200 + 100) = 600 -> Net = +200
      final ravi = group.getMemberBalance('Ravi');
      expect(ravi.totalPaid, equals(800.0));
      expect(ravi.shareOwed, equals(600.0));
      expect(ravi.netBalance, equals(200.0));

      // Neha: Paid 0, owes (300 + 200) = 500 -> Net = -500
      final neha = group.getMemberBalance('Neha');
      expect(neha.totalPaid, equals(0.0));
      expect(neha.shareOwed, equals(500.0));
      expect(neha.netBalance, equals(-500.0));

      // Vikram: Paid 300, owes (300 + 200 + 100) = 600 -> Net = -300
      final vikram = group.getMemberBalance('Vikram');
      expect(vikram.totalPaid, equals(300.0));
      expect(vikram.shareOwed, equals(600.0));
      expect(vikram.netBalance, equals(-300.0));

      // Verify net balances sum to 0
      final totalNet = asha.netBalance + ravi.netBalance + neha.netBalance + vikram.netBalance;
      expect(totalNet.abs(), lessThan(0.01));

      // Settlement verification
      final settlements = group.suggestSettlements();
      expect(settlements.isNotEmpty, isTrue);
      double totalSettlementPaid = 0.0;
      for (final s in settlements) {
        totalSettlementPaid += s.amount;
      }
      expect(totalSettlementPaid, equals(800.0)); // Total debt owed by Neha (500) + Vikram (300) = 800
    });
  });

  group('Expense Listing & Filtering', () {
    test('filters expenses by member and category accurately', () {
      final group = ExpenseGroup();
      group.addMember('Asha');
      group.addMember('Ravi');
      group.addMember('Neha');

      group.addExpense(
        title: 'Lunch',
        amount: 300,
        paidBy: 'Asha',
        category: 'Food',
        splitBetween: ['Asha', 'Ravi'],
      );

      group.addExpense(
        title: 'Metro',
        amount: 150,
        paidBy: 'Ravi',
        category: 'Travel',
        splitBetween: ['Asha', 'Ravi', 'Neha'],
      );

      group.addExpense(
        title: 'Movie',
        amount: 450,
        paidBy: 'Neha',
        category: 'Entertainment',
        splitBetween: ['Asha', 'Neha'],
      );

      // Filter by category
      final foodExp = group.listExpenses(category: 'Food');
      expect(foodExp.length, equals(1));
      expect(foodExp.first.title, equals('Lunch'));

      final travelExp = group.listExpenses(category: ExpenseCategory.travel);
      expect(travelExp.length, equals(1));
      expect(travelExp.first.title, equals('Metro'));

      // Filter by member
      final raviExp = group.listExpenses(member: 'Ravi');
      expect(raviExp.length, equals(2)); // Involved in Lunch and Metro

      final nehaExp = group.listExpenses(member: 'Neha');
      expect(nehaExp.length, equals(2)); // Involved in Metro and Movie
    });
  });

  group('Error Handling & Edge Cases', () {
    test('throws MemberNotFoundException for unknown payer', () {
      final group = ExpenseGroup();
      group.addMember('Asha');
      expect(
        () => group.addExpense(
          title: 'Taxi',
          amount: 200,
          paidBy: 'Ghost',
          category: 'Travel',
          splitBetween: ['Asha'],
        ),
        throwsA(isA<MemberNotFoundException>()),
      );
    });

    test('throws MemberNotFoundException for unknown participant', () {
      final group = ExpenseGroup();
      group.addMember('Asha');
      expect(
        () => group.addExpense(
          title: 'Taxi',
          amount: 200,
          paidBy: 'Asha',
          category: 'Travel',
          splitBetween: ['Asha', 'Ghost'],
        ),
        throwsA(isA<MemberNotFoundException>()),
      );
    });

    test('throws InvalidAmountException for zero or negative amounts', () {
      final group = ExpenseGroup();
      group.addMember('Asha');
      expect(
        () => group.addExpense(
          title: 'Free Food',
          amount: 0,
          paidBy: 'Asha',
          category: 'Food',
          splitBetween: ['Asha'],
        ),
        throwsA(isA<InvalidAmountException>()),
      );

      expect(
        () => group.addExpense(
          title: 'Refund',
          amount: -100,
          paidBy: 'Asha',
          category: 'Food',
          splitBetween: ['Asha'],
        ),
        throwsA(isA<InvalidAmountException>()),
      );
    });

    test('throws InvalidParticipantException for empty participants list', () {
      final group = ExpenseGroup();
      group.addMember('Asha');
      expect(
        () => group.addExpense(
          title: 'Solo',
          amount: 100,
          paidBy: 'Asha',
          category: 'Food',
          splitBetween: [],
        ),
        throwsA(isA<InvalidParticipantException>()),
      );
    });
  });

  group('Optional Extensions', () {
    test('supports unequal custom split', () {
      final group = ExpenseGroup();
      group.addMember('Alice');
      group.addMember('Bob');
      group.addMember('Charlie');

      group.addExpense(
        title: 'Groceries',
        amount: 1000,
        paidBy: 'Alice',
        category: 'Groceries',
        splitBetween: ['Alice', 'Bob', 'Charlie'],
        customShares: {'Alice': 200, 'Bob': 500, 'Charlie': 300},
      );

      final aliceBal = group.getMemberBalance('Alice');
      final bobBal = group.getMemberBalance('Bob');
      final charlieBal = group.getMemberBalance('Charlie');

      expect(aliceBal.netBalance, equals(800.0));
      expect(bobBal.netBalance, equals(-500.0));
      expect(charlieBal.netBalance, equals(-300.0));
    });

    test('handles rounding consistently with odd amount division', () {
      final group = ExpenseGroup();
      group.addMember('A');
      group.addMember('B');
      group.addMember('C');

      // 100 divided among 3: 33.34 + 33.33 + 33.33 = 100.00
      final exp = group.addExpense(
        title: 'Odd split',
        amount: 100,
        paidBy: 'A',
        category: 'Other',
        splitBetween: ['A', 'B', 'C'],
      );

      double sumShares = 0.0;
      exp.participantShares.forEach((_, share) => sumShares += share);
      expect(sumShares, equals(100.0));
    });

    test('supports edit and delete of expenses', () {
      final group = ExpenseGroup();
      group.addMember('Asha');
      group.addMember('Ravi');

      final exp = group.addExpense(
        title: 'Original Title',
        amount: 200,
        paidBy: 'Asha',
        category: 'Food',
        splitBetween: ['Asha', 'Ravi'],
      );

      expect(group.getMemberBalance('Asha').netBalance, equals(100.0));

      // Edit
      group.editExpense(exp.id, title: 'Updated Title', amount: 400);
      expect(group.getMemberBalance('Asha').netBalance, equals(200.0));

      // Delete
      group.deleteExpense(exp.id);
      expect(group.expenses.isEmpty, isTrue);
      expect(group.getMemberBalance('Asha').netBalance, equals(0.0));
    });

    test('supports JSON persistence (save and load)', () async {
      final group = ExpenseGroup();
      group.addMember('Asha');
      group.addMember('Ravi');
      group.addExpense(
        title: 'Dinner',
        amount: 900,
        paidBy: 'Asha',
        category: 'Food',
        splitBetween: ['Asha', 'Ravi'],
      );

      final tempPath = '${Directory.systemTemp.path}/splitsmart_test_${DateTime.now().millisecondsSinceEpoch}.json';
      await group.saveToFile(tempPath);

      final loaded = await ExpenseGroup.loadFromFile(tempPath);
      expect(loaded.members.length, equals(2));
      expect(loaded.expenses.length, equals(1));
      expect(loaded.getMemberBalance('Asha').netBalance, equals(450.0));
      expect(loaded.getMemberBalance('Ravi').netBalance, equals(-450.0));

      // Clean up temp file
      final f = File(tempPath);
      if (await f.exists()) await f.delete();
    });
  });
}
