import 'package:smartgrade_ai/domain/entities/teacher.dart';


/// Modelo TeacherModel
/// Capa de datos - Clean Architecture
/// Extiende la entidad Teacher y agrega serialización para SQLite
class TeacherModel extends Teacher {
  TeacherModel({
    super.id,
    required super.firstName,
    required super.lastName,
    required super.createdAt,
  });

  /// Convierte desde entidad Teacher a TeacherModel
  factory TeacherModel.fromEntity(Teacher teacher) {
    return TeacherModel(
      id: teacher.id,
      firstName: teacher.firstName,
      lastName: teacher.lastName,
      createdAt: teacher.createdAt,
    );
  }

  /// Convierte desde Map (SQLite) a TeacherModel
  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as int?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte TeacherModel a Map (para SQLite)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convierte a entidad Teacher
  Teacher toEntity() {
    return Teacher(
      id: id,
      firstName: firstName,
      lastName: lastName,
      createdAt: createdAt,
    );
  }
}
