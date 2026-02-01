class Exam {
  final int? id;
  final String title;
  final String? description;
  final int subjectId;
  final int teacherId;
  final DateTime examDate;
  final String? institution;
  final String qrCode; // Código único para identificar el examen
  final DateTime createdAt;

  Exam({
    this.id,
    required this.title,
    this.description,
    required this.subjectId,
    required this.teacherId,
    required this.examDate,
    this.institution,
    String? qrCode,
    DateTime? createdAt,
  })  : qrCode = qrCode ?? _generateQrCode(),
        createdAt = createdAt ?? DateTime.now();

  static String _generateQrCode() {
    return 'EXAM-${DateTime.now().millisecondsSinceEpoch}';
  }

  Exam copyWith({
    int? id,
    String? title,
    String? description,
    int? subjectId,
    int? teacherId,
    DateTime? examDate,
    String? institution,
    String? qrCode,
    DateTime? createdAt,
  }) {
    return Exam(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      examDate: examDate ?? this.examDate,
      institution: institution ?? this.institution,
      qrCode: qrCode ?? this.qrCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
