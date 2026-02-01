import 'dart:convert';
import 'package:smartgrade_ai/domain/entities/result.dart';


/// Modelo ResultModel
/// Capa de datos - Clean Architecture
/// Extiende la entidad Result y agrega serialización para SQLite
class ResultModel extends Result {
  ResultModel({
    super.id,
    required super.examId,
    required super.studentId,
    required super.score,
    required super.totalScore,
    required super.correctAnswers,
    required super.wrongAnswers,
    required super.answers,
    super.imagePath,
    super.imagePages,
    super.scanMethod,
    super.aiAnalysisNotes,
    required super.completedAt,
  });

  /// Convierte desde entidad Result a ResultModel
  factory ResultModel.fromEntity(Result result) {
    return ResultModel(
      id: result.id,
      examId: result.examId,
      studentId: result.studentId,
      score: result.score,
      totalScore: result.totalScore,
      correctAnswers: result.correctAnswers,
      wrongAnswers: result.wrongAnswers,
      answers: result.answers,
      imagePath: result.imagePath,
      imagePages: result.imagePages,
      scanMethod: result.scanMethod,
      aiAnalysisNotes: result.aiAnalysisNotes,
      completedAt: result.completedAt,
    );
  }

  /// Convierte desde Map (SQLite) a ResultModel
  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      id: json['id'] as int?,
      examId: json['exam_id'] as int,
      studentId: json['student_id'] as int,
      score: (json['score'] as num).toDouble(),
      totalScore: (json['total_score'] as num).toDouble(),
      correctAnswers: json['correct_answers'] as int,
      wrongAnswers: json['wrong_answers'] as int,
      answers: _decodeAnswers(json['answers'] as String),
      imagePath: json['image_path'] as String?,
      imagePages: json['image_pages'] != null
          ? _decodeImagePages(json['image_pages'] as String)
          : null,
      scanMethod: json['scan_method'] as String? ?? 'full_exam',
      aiAnalysisNotes: json['ai_analysis_notes'] as String?,
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  /// Convierte ResultModel a Map (para SQLite)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'exam_id': examId,
      'student_id': studentId,
      'score': score,
      'total_score': totalScore,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'answers': _encodeAnswers(answers),
      'image_path': imagePath,
      'image_pages': _encodeImagePages(imagePages),
      'scan_method': scanMethod,
      'ai_analysis_notes': aiAnalysisNotes,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  /// Convierte a entidad Result
  Result toEntity() {
    return Result(
      id: id,
      examId: examId,
      studentId: studentId,
      score: score,
      totalScore: totalScore,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      answers: answers,
      imagePath: imagePath,
      imagePages: imagePages,
      scanMethod: scanMethod,
      aiAnalysisNotes: aiAnalysisNotes,
      completedAt: completedAt,
    );
  }

  /// Codifica mapa de respuestas a JSON string
  static String _encodeAnswers(Map<int, List<String>> answers) {
    final Map<String, dynamic> encoded = {};
    answers.forEach((key, value) {
      encoded[key.toString()] = value;
    });
    return jsonEncode(encoded);
  }

  /// Decodifica JSON string a mapa de respuestas
  static Map<int, List<String>> _decodeAnswers(String jsonStr) {
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    final Map<int, List<String>> answers = {};
    decoded.forEach((key, value) {
      final list = (value as List).map((e) => e.toString()).toList();
      answers[int.parse(key)] = list;
    });
    return answers;
  }

  /// Codifica lista de imágenes a JSON string
  static String _encodeImagePages(List<String> pages) {
    return jsonEncode(pages);
  }

  /// Decodifica JSON string a lista de imágenes
  static List<String> _decodeImagePages(String jsonStr) {
    final decoded = jsonDecode(jsonStr) as List;
    return decoded.map((e) => e.toString()).toList();
  }
}
