/// Custom exceptions for the SplitSmart application.
library;

/// Base exception class for all SplitSmart errors.
sealed class SplitSmartException implements Exception {
  final String message;
  const SplitSmartException(this.message);

  @override
  String toString() => message;
}

/// Thrown when attempting to add a member that already exists.
class DuplicateMemberException extends SplitSmartException {
  final String memberName;
  DuplicateMemberException(this.memberName)
      : super('Duplicate member error: Member "$memberName" already exists in the group.');
}

/// Thrown when a specified member cannot be found in the group.
class MemberNotFoundException extends SplitSmartException {
  final String memberName;
  MemberNotFoundException(this.memberName)
      : super('Member not found: "$memberName" is not registered in the group.');
}

/// Thrown when an expense amount is invalid (e.g. non-positive, NaN, infinite).
class InvalidAmountException extends SplitSmartException {
  final num amount;
  InvalidAmountException(this.amount)
      : super('Invalid amount: Expense amount must be greater than zero. Received: $amount');
}

/// Thrown when participant list is empty or contains invalid entries.
class InvalidParticipantException extends SplitSmartException {
  InvalidParticipantException(String detail)
      : super('Invalid participants: $detail');
}

/// Thrown when an expense title is empty or invalid.
class InvalidExpenseException extends SplitSmartException {
  InvalidExpenseException(String detail)
      : super('Invalid expense: $detail');
}

/// Thrown when an expense ID is not found for editing or deletion.
class ExpenseNotFoundException extends SplitSmartException {
  final String expenseId;
  ExpenseNotFoundException(this.expenseId)
      : super('Expense not found: No expense exists with ID "$expenseId".');
}

/// Thrown when custom split shares do not sum to total expense amount.
class InvalidSplitException extends SplitSmartException {
  InvalidSplitException(String detail)
      : super('Invalid split configuration: $detail');
}
