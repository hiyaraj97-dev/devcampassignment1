/// Settlement transfer models and debt resolution algorithms for SplitSmart.
library;

import 'dart:math';

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

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'amount': amount,
      };

  factory SettlementTransfer.fromJson(Map<String, dynamic> json) {
    return SettlementTransfer(
      from: json['from'] as String,
      to: json['to'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    final formattedAmount = amount.truncateToDouble() == amount
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '$from pays $to INR $formattedAmount';
  }
}

/// Helper class to resolve debts into minimal direct transfers.
class DebtSettlementCalculator {
  /// Computes the minimal/simplified list of settlement transfers given net balances.
  ///
  /// [netBalances] is a map of member name -> net balance.
  /// Positive value = member should receive money.
  /// Negative value = member owes money.
  static List<SettlementTransfer> calculateSettlements(
    Map<String, double> netBalances,
  ) {
    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];

    netBalances.forEach((member, balance) {
      // Rounded to 2 decimal places to avoid floating point anomalies
      final rounded = double.parse(balance.toStringAsFixed(2));
      if (rounded < -0.005) {
        debtors.add(MapEntry(member, -rounded));
      } else if (rounded > 0.005) {
        creditors.add(MapEntry(member, rounded));
      }
    });

    // Sort descending by magnitude to prioritize settling largest debts first
    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    final transfers = <SettlementTransfer>[];
    int d = 0;
    int c = 0;

    final mutableDebtors = debtors.map((e) => e.value).toList();
    final mutableCreditors = creditors.map((e) => e.value).toList();

    while (d < debtors.length && c < creditors.length) {
      final debtorOwes = mutableDebtors[d];
      final creditorWants = mutableCreditors[c];

      if (debtorOwes < 0.005) {
        d++;
        continue;
      }
      if (creditorWants < 0.005) {
        c++;
        continue;
      }

      final payment = min(debtorOwes, creditorWants);
      final roundedPayment = double.parse(payment.toStringAsFixed(2));

      if (roundedPayment > 0.0) {
        transfers.add(
          SettlementTransfer(
            from: debtors[d].key,
            to: creditors[c].key,
            amount: roundedPayment,
          ),
        );
      }

      mutableDebtors[d] -= payment;
      mutableCreditors[c] -= payment;

      if (mutableDebtors[d] < 0.005) d++;
      if (mutableCreditors[c] < 0.005) c++;
    }

    return transfers;
  }
}
