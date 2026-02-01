import 'package:smartgrade_ai/domain/entities/exam_question.dart';

/// Modelo ExamQuestionModel
/// Capa de datos - Clean Architecture
/// Extiende la entidad ExamQuestion y agrega serialización para SQLite
class ExamQuestionModel extends ExamQuestion {
  ExamQuestionModel({
    super.id,
    required super.examId,
    required super.questionId,
    required super.orderNumber,
    required super.value,
  });

  /// Convierte desde entidad ExamQuestion a ExamQuestionModel
  factory ExamQuestionModel.fromEntity(ExamQuestion examQuestion) {
    return ExamQuestionModel(
      id: examQuestion.id,
      examId: examQuestion.examId,
      questionId: examQuestion.questionId,
      orderNumber: examQuestion.orderNumber,
      value: examQuestion.value,
    );
  }

  /// Convierte desde Map (SQLite) a ExamQuestionModel
  factory ExamQuestionModel.fromJson(Map<String, dynamic> json) {
    return ExamQuestionModel(
      id: json['id'] as int?,
      examId: json['exam_id'] as int,
      questionId: json['question_id'] as int,
      orderNumber: json['order_number'] as int,
      value: (json['value'] as num).toDouble(),
    );
  }

  /// Convierte ExamQuestionModel a Map (para SQLite)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'exam_id': examId,
      'question_id': questionId,
      'order_number': orderNumber,
      'value': value,
    };
  }

  /// Convierte a entidad ExamQuestion
  ExamQuestion toEntity() {
    return ExamQuestion(
      id: id,
      examId: examId,
      questionId: questionId,
      orderNumber: orderNumber,
      value: value,
    );
  }
}
