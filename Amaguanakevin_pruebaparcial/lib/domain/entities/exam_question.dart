class ExamQuestion {
  final int? id;
  final int examId;
  final int questionId;
  final int orderNumber; // Orden de la pregunta en el examen
  final double value; // Valor específico para este examen

  ExamQuestion({
    this.id,
    required this.examId,
    required this.questionId,
    required this.orderNumber,
    this.value = 1.0,
  });

  ExamQuestion copyWith({
    int? id,
    int? examId,
    int? questionId,
    int? orderNumber,
    double? value,
  }) {
    return ExamQuestion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      questionId: questionId ?? this.questionId,
      orderNumber: orderNumber ?? this.orderNumber,
      value: value ?? this.value,
    );
  }
}
