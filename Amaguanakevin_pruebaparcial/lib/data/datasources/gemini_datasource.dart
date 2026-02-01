import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_keys.dart';

/// GeminiDataSource
/// Capa de datos - Clean Architecture
/// Maneja la comunicación con Gemini AI para interpretación de respuestas
class GeminiDataSource {
  late final GenerativeModel _model;

  GeminiDataSource() {
    if (!ApiKeys.isConfigured) {
      throw Exception('Gemini API Key no configurada. '
          'Por favor configure su API Key en lib/core/constants/api_keys.dart');
    }

    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: ApiKeys.geminiApiKey,
    );
  }

  /// Interpreta texto OCR y extrae respuestas marcadas por el estudiante
  ///
  /// Envía el texto reconocido por OCR a Gemini AI para que identifique
  /// qué respuestas fueron marcadas por el estudiante
  Future<Map<int, List<String>>> interpretAnswers({
    required String ocrText,
    required int numberOfQuestions,
  }) async {
    try {
      final prompt = '''
Eres un asistente que analiza exámenes escaneados.

Se te proporciona el texto extraído por OCR de un examen con $numberOfQuestions preguntas.

Tu tarea es identificar qué respuestas marcó el estudiante.

Formato esperado de salida (JSON):
{
  "1": ["A"],
  "2": ["B"],
  "3": ["C", "D"],
  ...
}

Donde la clave es el número de pregunta y el valor es un array con las letras de las opciones marcadas (A, B, C, D, E).
Si hay múltiples respuestas marcadas en una pregunta, incluye todas.
Si no se detecta ninguna respuesta marcada, devuelve un array vacío.

TEXTO DEL EXAMEN:
$ocrText

Responde SOLO con el JSON, sin explicaciones adicionales.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini no devolvió respuesta');
      }

      // Limpiar el texto de la respuesta (remover markdown si existe)
      String jsonText = response.text!.trim();
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();

      // Parsear el JSON
      final Map<String, dynamic> parsed = _parseJson(jsonText);

      // Convertir a Map<int, List<String>>
      final Map<int, List<String>> answers = {};
      parsed.forEach((key, value) {
        final questionNumber = int.parse(key);
        if (value is List) {
          answers[questionNumber] =
              value.map((e) => e.toString().toUpperCase()).toList();
        } else if (value is String) {
          answers[questionNumber] = [value.toUpperCase()];
        }
      });

      return answers;
    } catch (e) {
      throw Exception('Error al interpretar respuestas con Gemini: $e');
    }
  }

  /// Valida si una respuesta está completa y bien formateada
  Future<bool> validateAnswerSheet({
    required String ocrText,
    required int expectedQuestions,
  }) async {
    try {
      final prompt = '''
Analiza el siguiente texto extraído de un examen y determina si:
1. Se detectan $expectedQuestions preguntas
2. Cada pregunta tiene al menos una respuesta marcada
3. El formato es legible

Responde SOLO con "true" o "false".

TEXTO:
$ocrText
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) return false;

      final result = response.text!.trim().toLowerCase();
      return result.contains('true');
    } catch (e) {
      return false;
    }
  }

  /// Genera sugerencias de mejora para una pregunta
  Future<String> generateQuestionSuggestions(String question) async {
    try {
      final prompt = '''
Eres un experto en pedagogía y diseño de evaluaciones educativas.

Analiza la siguiente pregunta de examen y proporciona sugerencias para mejorarla:

PREGUNTA:
$question

Proporciona:
1. Claridad del enunciado
2. Sugerencias de redacción
3. Posibles ambigüedades

Sé conciso (máximo 150 palabras).
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'No se pudieron generar sugerencias';
    } catch (e) {
      throw Exception('Error al generar sugerencias: $e');
    }
  }

  /// Parse simple de JSON string a Map
  Map<String, dynamic> _parseJson(String jsonText) {
    try {
      // Intenta parsear con dart:convert
      return Map<String, dynamic>.from(jsonText
          .split('{')
          .last
          .split('}')
          .first
          .split(',')
          .fold<Map<String, dynamic>>({}, (map, pair) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final key = parts[0].trim().replaceAll('"', '');
          final valueStr = parts[1]
              .trim()
              .replaceAll('"', '')
              .replaceAll('[', '')
              .replaceAll(']', '');
          final values = valueStr
              .split(',')
              .map((v) => v.trim())
              .where((v) => v.isNotEmpty)
              .toList();
          map[key] = values.length == 1 ? values[0] : values;
        }
        return map;
      }));
    } catch (e) {
      throw Exception('Error al parsear respuesta de Gemini: $e');
    }
  }
}
