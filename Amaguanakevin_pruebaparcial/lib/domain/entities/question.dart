class Question {
  final int? id;
  final String statement; // Enunciado
  final String type; // simple, multiple, true_false, complete
  final List<String> options; // Opciones de respuesta
  final List<String>
      correctAnswers; // Respuestas correctas (puede ser múltiple)
  final double value; // Valor de la pregunta
  final int? subjectId;
  final DateTime createdAt;

  Question({
    this.id,
    required this.statement,
    required this.type,
    required this.options,
    required this.correctAnswers,
    this.value = 1.0,
    this.subjectId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool isCorrectAnswer(List<String> answers) {
    if (answers.length != correctAnswers.length) return false;

    final sortedAnswers = List<String>.from(answers)
        .map((e) => e.trim().toUpperCase())
        .toList()
      ..sort();
    final sortedCorrect = List<String>.from(correctAnswers)
        .map((e) => e.trim().toUpperCase())
        .toList()
      ..sort();

    for (int i = 0; i < sortedAnswers.length; i++) {
      if (sortedAnswers[i] != sortedCorrect[i]) return false;
    }

    return true;
  }

  Question copyWith({
    int? id,
    String? statement,
    String? type,
    List<String>? options,
    List<String>? correctAnswers,
    double? value,
    int? subjectId,
    DateTime? createdAt,
  }) {
    return Question(
      id: id ?? this.id,
      statement: statement ?? this.statement,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      value: value ?? this.value,
      subjectId: subjectId ?? this.subjectId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
