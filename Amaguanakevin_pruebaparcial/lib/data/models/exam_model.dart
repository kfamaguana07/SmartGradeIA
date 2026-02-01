import 'package:smartgrade_ai/domain/entities/exam.dart';


/// Modelo ExamModel
/// Capa de datos - Clean Architecture
/// Extiende la entidad Exam y agrega serialización para SQLite
class ExamModel extends Exam {
  ExamModel({
    super.id,
    required super.title,
    super.description,
    required super.subjectId,
    required super.teacherId,
    required super.examDate,
    super.institution,
    required super.qrCode,
    required super.createdAt,
  });

  /// Convierte desde entidad Exam a ExamModel
  factory ExamModel.fromEntity(Exam exam) {
    return ExamModel(
      id: exam.id,
      title: exam.title,
      description: exam.description,
      subjectId: exam.subjectId,
      teacherId: exam.teacherId,
      examDate: exam.examDate,
      institution: exam.institution,
      qrCode: exam.qrCode,
      createdAt: exam.createdAt,
    );
  }

  /// Convierte desde Map (SQLite) a ExamModel
  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      subjectId: json['subject_id'] as int,
      teacherId: json['teacher_id'] as int,
      examDate: DateTime.parse(json['exam_date'] as String),
      institution: json['institution'] as String?,
      qrCode: json['qr_code'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte ExamModel a Map (para SQLite)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'exam_date': examDate.toIso8601String(),
      'institution': institution,
      'qr_code': qrCode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convierte a entidad Exam
  Exam toEntity() {
    return Exam(
      id: id,
      title: title,
      description: description,
      subjectId: subjectId,
      teacherId: teacherId,
      examDate: examDate,
      institution: institution,
      qrCode: qrCode,
      createdAt: createdAt,
    );
  }
}
