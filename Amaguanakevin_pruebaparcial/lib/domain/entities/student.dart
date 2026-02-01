class Student {
  final int? id;
  final String identification;
  final String firstName;
  final String lastName;
  final DateTime createdAt;

  Student({
    this.id,
    required this.identification,
    required this.firstName,
    required this.lastName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  Student copyWith({
    int? id,
    String? identification,
    String? firstName,
    String? lastName,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      identification: identification ?? this.identification,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
