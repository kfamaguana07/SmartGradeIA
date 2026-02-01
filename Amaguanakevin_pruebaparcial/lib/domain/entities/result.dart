class Result {
  final int? id;
  final int examId;
  final int studentId;
  final double score; // Nota obtenida
  final double totalScore; // Puntaje total posible
  final int correctAnswers; // Número de aciertos
  final int wrongAnswers; // Número de errores
  final Map<int, List<String>> answers; // Map<questionId, selectedAnswers>
  final String?
      imagePath; // Ruta de la imagen escaneada (imagen principal o única)
  final List<String>
      imagePages; // Lista de rutas de todas las páginas escaneadas
  final String scanMethod; // 'full_exam' o 'answer_sheet'
  final String?
      aiAnalysisNotes; // Notas o comentarios de la IA durante el análisis
  final DateTime completedAt;

  Result({
    this.id,
    required this.examId,
    required this.studentId,
    required this.score,
    required this.totalScore,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.answers,
    this.imagePath,
    List<String>? imagePages,
    this.scanMethod = 'full_exam',
    this.aiAnalysisNotes,
    DateTime? completedAt,
  })  : imagePages = imagePages ?? (imagePath != null ? [imagePath] : []),
        completedAt = completedAt ?? DateTime.now();

  double get percentage => totalScore > 0 ? (score / totalScore) * 100 : 0;

  bool get isPassed => percentage >= 60;

  Result copyWith({
    int? id,
    int? examId,
    int? studentId,
    double? score,
    double? totalScore,
    int? correctAnswers,
    int? wrongAnswers,
    Map<int, List<String>>? answers,
    String? imagePath,
    List<String>? imagePages,
    String? scanMethod,
    String? aiAnalysisNotes,
    DateTime? completedAt,
  }) {
    return Result(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      studentId: studentId ?? this.studentId,
      score: score ?? this.score,
      totalScore: totalScore ?? this.totalScore,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      answers: answers ?? this.answers,
      imagePath: imagePath ?? this.imagePath,
      imagePages: imagePages ?? this.imagePages,
      scanMethod: scanMethod ?? this.scanMethod,
      aiAnalysisNotes: aiAnalysisNotes ?? this.aiAnalysisNotes,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
