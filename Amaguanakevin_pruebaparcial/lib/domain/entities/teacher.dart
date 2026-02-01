class Teacher {
  final int? id;
  final String firstName;
  final String lastName;
  final DateTime createdAt;

  Teacher({
    this.id,
    required this.firstName,
    required this.lastName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  Teacher copyWith({
    int? id,
    String? firstName,
    String? lastName,
    DateTime? createdAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
