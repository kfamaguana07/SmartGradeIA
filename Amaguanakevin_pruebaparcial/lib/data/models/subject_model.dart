import 'package:smartgrade_ai/domain/entities/subject.dart';


/// Modelo SubjectModel
/// Capa de datos - Clean Architecture
/// Extiende la entidad Subject y agrega serialización para SQLite
class SubjectModel extends Subject {
  SubjectModel({
    super.id,
    required super.name,
    required super.nrc,
    super.teacherId,
    required super.createdAt,
  });

  /// Convierte desde entidad Subject a SubjectModel
  factory SubjectModel.fromEntity(Subject subject) {
    return SubjectModel(
      id: subject.id,
      name: subject.name,
      nrc: subject.nrc,
      teacherId: subject.teacherId,
      createdAt: subject.createdAt,
    );
  }

  /// Convierte desde Map (SQLite) a SubjectModel
  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      nrc: json['nrc'] as String,
      teacherId: json['teacher_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte SubjectModel a Map (para SQLite)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'nrc': nrc,
      'teacher_id': teacherId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convierte a entidad Subject
  Subject toEntity() {
    return Subject(
      id: id,
      name: name,
      nrc: nrc,
      teacherId: teacherId,
      createdAt: createdAt,
    );
  }
}
