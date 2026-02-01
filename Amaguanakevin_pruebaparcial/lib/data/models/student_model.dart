import 'package:smartgrade_ai/domain/entities/student.dart';


/// Modelo StudentModel
/// Capa de datos - Clean Architecture
/// Extiende la entidad Student y agrega serialización para SQLite
class StudentModel extends Student {
  StudentModel({
    super.id,
    required super.identification,
    required super.firstName,
    required super.lastName,
    required super.createdAt,
  });

  /// Convierte desde entidad Student a StudentModel
  factory StudentModel.fromEntity(Student student) {
    return StudentModel(
      id: student.id,
      identification: student.identification,
      firstName: student.firstName,
      lastName: student.lastName,
      createdAt: student.createdAt,
    );
  }

  /// Convierte desde Map (SQLite) a StudentModel
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as int?,
      identification: json['identification'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte StudentModel a Map (para SQLite)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'identification': identification,
      'first_name': firstName,
      'last_name': lastName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convierte a entidad Student
  Student toEntity() {
    return Student(
      id: id,
      identification: identification,
      firstName: firstName,
      lastName: lastName,
      createdAt: createdAt,
    );
  }
}
