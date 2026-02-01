import 'dart:convert';
import 'package:smartgrade_ai/domain/entities/question.dart';


/// Modelo QuestionModel
/// Capa de datos - Clean Architecture
/// Extiende la entidad Question y agrega serialización para SQLite
class QuestionModel extends Question {
  QuestionModel({
    super.id,
    required super.statement,
    required super.type,
    required super.options,
    required super.correctAnswers,
    required super.value,
    super.subjectId,
    required super.createdAt,
  });

  /// Convierte desde entidad Question a QuestionModel
  factory QuestionModel.fromEntity(Question question) {
    return QuestionModel(
      id: question.id,
      statement: question.statement,
      type: question.type,
      options: question.options,
      correctAnswers: question.correctAnswers,
      value: question.value,
      subjectId: question.subjectId,
      createdAt: question.createdAt,
    );
  }

  /// Convierte desde Map (SQLite) a QuestionModel
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int?,
      statement: json['statement'] as String,
      type: json['type'] as String,
      options: _decodeList(json['options'] as String),
      correctAnswers: _decodeList(json['correct_answers'] as String),
      value: (json['value'] as num).toDouble(),
      subjectId: json['subject_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte QuestionModel a Map (para SQLite)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'statement': statement,
      'type': type,
      'options': _encodeList(options),
      'correct_answers': _encodeList(correctAnswers),
      'value': value,
      'subject_id': subjectId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convierte a entidad Question
  Question toEntity() {
    return Question(
      id: id,
      statement: statement,
      type: type,
      options: options,
      correctAnswers: correctAnswers,
      value: value,
      subjectId: subjectId,
      createdAt: createdAt,
    );
  }

  /// Codifica lista a JSON string
  static String _encodeList(List<String> list) {
    return jsonEncode(list);
  }

  /// Decodifica JSON string a lista
  static List<String> _decodeList(String jsonStr) {
    final decoded = jsonDecode(jsonStr) as List;
    return decoded.map((e) => e.toString()).toList();
  }
}
