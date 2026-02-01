import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

/// OCRDataSource
/// Capa de datos - Clean Architecture
/// Maneja el reconocimiento óptico de caracteres (OCR)
class OCRDataSource {
  final TextRecognizer _textRecognizer;

  OCRDataSource()
      : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Procesa una imagen y extrae el texto
  Future<String> extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      // Concatenar todo el texto reconocido
      final StringBuffer buffer = StringBuffer();
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          buffer.writeln(line.text);
        }
      }

      return buffer.toString().trim();
    } catch (e) {
      throw Exception('Error al procesar imagen con OCR: $e');
    }
  }

  /// Extrae texto estructurado por bloques
  Future<List<String>> extractTextBlocks(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      final List<String> blocks = [];
      for (TextBlock block in recognizedText.blocks) {
        final StringBuffer buffer = StringBuffer();
        for (TextLine line in block.lines) {
          buffer.writeln(line.text);
        }
        if (buffer.toString().trim().isNotEmpty) {
          blocks.add(buffer.toString().trim());
        }
      }

      return blocks;
    } catch (e) {
      throw Exception('Error al procesar imagen con OCR: $e');
    }
  }

  /// Extrae texto línea por línea
  Future<List<String>> extractTextLines(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      final List<String> lines = [];
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          if (line.text.trim().isNotEmpty) {
            lines.add(line.text.trim());
          }
        }
      }

      return lines;
    } catch (e) {
      throw Exception('Error al procesar imagen con OCR: $e');
    }
  }

  /// Busca patrones de respuestas marcadas
  /// Busca patrones como: (X) A, [X] B, (*) C, etc.
  Future<Map<int, String>> extractMarkedAnswers(String imagePath) async {
    try {
      final lines = await extractTextLines(imagePath);
      final Map<int, String> answers = {};

      // Patrones comunes de respuestas marcadas
      final patterns = [
        RegExp(r'\(X\)\s*([A-E])', caseSensitive: false),
        RegExp(r'\[X\]\s*([A-E])', caseSensitive: false),
        RegExp(r'\(\*\)\s*([A-E])', caseSensitive: false),
        RegExp(r'X\s*([A-E])', caseSensitive: false),
      ];

      int questionNumber = 1;
      for (var line in lines) {
        for (var pattern in patterns) {
          final match = pattern.firstMatch(line);
          if (match != null) {
            answers[questionNumber] = match.group(1)!.toUpperCase();
            questionNumber++;
            break;
          }
        }
      }

      return answers;
    } catch (e) {
      throw Exception('Error al extraer respuestas marcadas: $e');
    }
  }

  /// Libera recursos
  void dispose() {
    _textRecognizer.close();
  }
}
