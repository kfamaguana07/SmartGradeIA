import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/question.dart';
import '../constants/api_keys.dart';

/// Servicio de Google Gemini AI
/// Responsable de analizar imágenes de exámenes y extraer respuestas
class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    if (!ApiKeys.isConfigured) {
      throw Exception('Gemini API Key no configurada. '
          'Por favor configure su API Key en lib/core/constants/api_keys.dart');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: ApiKeys.geminiApiKey,
    );
  }

  /// Analiza una imagen de examen y extrae las respuestas marcadas
  /// Retorna un mapa con el número de pregunta y las opciones seleccionadas
  Future<Map<int, List<String>>> analyzeExamImage({
    required File imageFile,
    required List<Question> questions,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      final prompt = _buildAnalysisPrompt(questions);

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text ?? '';

      return _parseAIResponse(responseText, questions.length);
    } catch (e) {
      throw Exception('Error al analizar imagen con Gemini: $e');
    }
  }

  /// Analiza múltiples páginas de un examen
  Future<Map<int, List<String>>> analyzeMultiplePages({
    required List<File> imageFiles,
    required List<Question> questions,
  }) async {
    final Map<int, List<String>> allAnswers = {};

    for (final imageFile in imageFiles) {
      final pageAnswers = await analyzeExamImage(
        imageFile: imageFile,
        questions: questions,
      );
      allAnswers.addAll(pageAnswers);
    }

    return allAnswers;
  }

  /// Analiza solo la hoja de respuestas (última página)
  Future<Map<int, List<String>>> analyzeAnswerSheet({
    required File answerSheetImage,
    required int totalQuestions,
    required String questionType, // 'simple', 'multiple', 'true_false'
  }) async {
    try {
      final imageBytes = await answerSheetImage.readAsBytes();

      final prompt = _buildAnswerSheetPrompt(totalQuestions, questionType);

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text ?? '';

      return _parseAnswerSheetResponse(responseText, totalQuestions);
    } catch (e) {
      throw Exception('Error al analizar hoja de respuestas: $e');
    }
  }

  /// Construye el prompt para análisis de examen completo
  String _buildAnalysisPrompt(List<Question> questions) {
    final buffer = StringBuffer();
    buffer.writeln('Analiza esta imagen de un examen completado.');
    buffer.writeln('Identifica las respuestas marcadas por el estudiante.');
    buffer.writeln('');
    buffer.writeln('El examen contiene ${questions.length} preguntas:');
    buffer.writeln('');

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      buffer.writeln('Pregunta ${i + 1} (${_getQuestionTypeText(q.type)}):');
      buffer.writeln('Opciones: ${q.options.join(", ")}');
      buffer.writeln('');
    }

    buffer.writeln('Instrucciones:');
    buffer.writeln(
        '1. Para cada pregunta, identifica la(s) opción(es) marcada(s)');
    buffer.writeln('2. Responde en formato: PREGUNTA_NUM:OPCION1,OPCION2');
    buffer.writeln(
        '3. IMPORTANTE: Usa solo LETRAS MAYÚSCULAS (A, B, C, D) o V/F para verdadero/falso');
    buffer.writeln('4. Ejemplo: 1:A  2:B,C  3:V  4:F');
    buffer.writeln('5. Si no hay respuesta marcada, indica: NUM:SIN_RESPUESTA');
    buffer.writeln('');
    buffer.writeln(
        'Responde SOLO con el formato solicitado, una pregunta por línea.');

    return buffer.toString();
  }

  /// Construye el prompt para hoja de respuestas
  String _buildAnswerSheetPrompt(int totalQuestions, String questionType) {
    final buffer = StringBuffer();
    buffer.writeln('Analiza esta hoja de respuestas de un examen.');
    buffer.writeln(
        'Contiene $totalQuestions preguntas de tipo: ${_getQuestionTypeText(questionType)}');
    buffer.writeln('');
    buffer.writeln('Instrucciones:');
    buffer.writeln('1. Identifica los círculos, cuadros o marcas rellenadas');
    buffer.writeln(
        '2. Para selección simple: una sola opción por pregunta (A, B, C, D, etc.)');
    buffer.writeln('3. Para selección múltiple: pueden ser varias opciones');
    buffer.writeln('4. Para verdadero/falso: V o F');
    buffer.writeln(
        '5. IMPORTANTE: Usa solo LETRAS MAYÚSCULAS (A, B, C, D) o V/F');
    buffer.writeln('6. Responde en formato: PREGUNTA_NUM:OPCIONES');
    buffer.writeln('7. Ejemplo: 1:A  2:B,C  3:V  4:D');
    buffer.writeln('');
    buffer.writeln(
        'Responde SOLO con el formato solicitado, una línea por pregunta.');
    buffer.writeln(
        'Si una pregunta no tiene respuesta marcada, indica: NUM:SIN_RESPUESTA');

    return buffer.toString();
  }

  /// Parsea la respuesta de la IA para examen completo
  Map<int, List<String>> _parseAIResponse(String response, int totalQuestions) {
    final Map<int, List<String>> answers = {};
    final lines = response.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Formato esperado: "1:A" o "2:B,C" o "3:SIN_RESPUESTA"
      final parts = trimmed.split(':');
      if (parts.length != 2) continue;

      try {
        final questionNum = int.parse(parts[0].trim());
        final answerPart = parts[1].trim();

        if (answerPart.toUpperCase() == 'SIN_RESPUESTA') {
          answers[questionNum] = [];
        } else {
          // Normalizar: convertir a mayúsculas y quitar espacios
          final options = answerPart
              .split(',')
              .map((e) => e.trim().toUpperCase())
              .where((e) => e.isNotEmpty)
              .toList();
          answers[questionNum] = options;
        }
      } catch (e) {
        continue; // Ignorar líneas mal formateadas
      }
    }

    return answers;
  }

  /// Parsea la respuesta de la hoja de respuestas
  Map<int, List<String>> _parseAnswerSheetResponse(
      String response, int totalQuestions) {
    return _parseAIResponse(response, totalQuestions);
  }

  /// Obtiene el texto descriptivo del tipo de pregunta
  String _getQuestionTypeText(String type) {
    switch (type) {
      case 'simple':
        return 'Selección Simple';
      case 'multiple':
        return 'Selección Múltiple';
      case 'true_false':
        return 'Verdadero/Falso';
      case 'complete':
        return 'Completar';
      default:
        return type;
    }
  }

  /// Verifica la configuración de la API Key
  bool isConfigured() {
    return ApiKeys.isConfigured;
  }
}
