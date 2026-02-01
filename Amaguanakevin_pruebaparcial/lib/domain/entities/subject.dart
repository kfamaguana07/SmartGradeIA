class Subject {
  final int? id;
  final String name;
  final String nrc;
  final int? teacherId;
  final DateTime createdAt;

  Subject({
    this.id,
    required this.name,
    required this.nrc,
    this.teacherId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Subject copyWith({
    int? id,
    String? name,
    String? nrc,
    int? teacherId,
    DateTime? createdAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      nrc: nrc ?? this.nrc,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
