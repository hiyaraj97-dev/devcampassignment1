/// Group member representation for SplitSmart.
library;

/// Represents an individual member participating in shared group expenses.
class Member {
  final String id;
  final String name;

  Member({
    required this.name,
    String? id,
  })  : id = (id != null && id.trim().isNotEmpty)
            ? id.trim()
            : name.trim().toLowerCase() {
    if (name.trim().isEmpty) {
      throw ArgumentError('Member name cannot be empty.');
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      name: json['name'] as String,
      id: json['id'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Member &&
          runtimeType == other.runtimeType &&
          (id == other.id || name.toLowerCase() == other.name.toLowerCase());

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}
