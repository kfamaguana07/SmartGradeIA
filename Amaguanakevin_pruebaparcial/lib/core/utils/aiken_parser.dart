import '../../domain/entities/question.dart';

class AikenParser {
  /// Parsea un archivo AIKEN y retorna una lista de preguntas
  static List<Question> parseAikenFile(String content, {int? subjectId}) {
    final List<Question> questions = [];
    final lines = content.split('\n').map((line) => line.trim()).toList();

    int i = 0;
    while (i < lines.length) {
      try {
        final question = _parseQuestion(lines, i, subjectId);
        if (question != null) {
          questions.add(question);
          // Avanzar al siguiente bloque de pregunta
          i = _findNextQuestion(lines, i);
        } else {
          i++;
        }
      } catch (e) {
        i++;
      }
    }

    return questions;
  }

  /// Parsea una sola pregunta desde la posición actual
  static Question? _parseQuestion(
      List<String> lines, int startIndex, int? subjectId) {
    if (startIndex >= lines.length) return null;

    String statement = '';
    List<String> options = [];
    List<String> correctAnswers = [];
    double value = 1.0;

    int currentIndex = startIndex;

    // Saltar líneas vacías
    while (currentIndex < lines.length && lines[currentIndex].isEmpty) {
      currentIndex++;
    }

    if (currentIndex >= lines.length) return null;

    // Leer enunciado (puede ser multilínea hasta encontrar opciones)
    while (currentIndex < lines.length) {
      final line = lines[currentIndex];

      // Si encuentra una opción, detener lectura del enunciado
      if (_isOption(line)) {
        break;
      }

      // Si es ANSWER: o VALUE:, algo salió mal
      if (line.toUpperCase().startsWith('ANSWER:') ||
          line.toUpperCase().startsWith('VALUE:')) {
        break;
      }

      if (line.isNotEmpty) {
        statement += (statement.isEmpty ? '' : ' ') + line;
      }

      currentIndex++;
    }

    if (statement.isEmpty) return null;

    // Leer opciones
    while (currentIndex < lines.length) {
      final line = lines[currentIndex];

      // Si encuentra ANSWER: o VALUE:, detener lectura de opciones
      if (line.toUpperCase().startsWith('ANSWER:') ||
          line.toUpperCase().startsWith('VALUE:')) {
        break;
      }

      if (_isOption(line)) {
        final optionText = _extractOptionText(line);
        if (optionText.isNotEmpty) {
          options.add(optionText);
        }
      }

      currentIndex++;
    }

    if (options.isEmpty) return null;

    // Leer ANSWER y VALUE
    while (currentIndex < lines.length) {
      final line = lines[currentIndex].trim();

      if (line.toUpperCase().startsWith('ANSWER:')) {
        final answerText = line.substring(7).trim().toUpperCase();
        // Soportar respuestas múltiples separadas por coma
        correctAnswers = answerText
            .split(',')
            .map((a) => a.trim())
            .where((a) => a.isNotEmpty)
            .toList();
        currentIndex++;
      } else if (line.toUpperCase().startsWith('VALUE:')) {
        final valueText = line.substring(6).trim();
        value = double.tryParse(valueText) ?? 1.0;
        currentIndex++;
      } else if (line.isEmpty) {
        currentIndex++;
      } else {
        break;
      }
    }

    if (correctAnswers.isEmpty) return null;

    // Detectar tipo de pregunta
    String questionType = 'simple';

    // Verdadero/Falso
    if (options.length == 2 &&
        (options[0].toLowerCase().contains('verdadero') ||
            options[0].toLowerCase().contains('true')) &&
        (options[1].toLowerCase().contains('falso') ||
            options[1].toLowerCase().contains('false'))) {
      questionType = 'true_false';
      // Normalizar opciones
      options = ['Verdadero', 'Falso'];
    }
    // Selección múltiple
    else if (correctAnswers.length > 1) {
      questionType = 'multiple';
    }

    return Question(
      statement: statement,
      type: questionType,
      options: options,
      correctAnswers: correctAnswers,
      value: value,
      subjectId: subjectId,
    );
  }

  /// Verifica si una línea es una opción (A), B), C), etc.)
  static bool _isOption(String line) {
    if (line.isEmpty) return false;

    // Formato: A) texto o A. texto
    final regex = RegExp(r'^[A-Za-z][\)\.]\s*.+');
    return regex.hasMatch(line);
  }

  /// Extrae el texto de una opción
  static String _extractOptionText(String line) {
    // Remover la letra y el separador (A) o A.)
    final regex = RegExp(r'^[A-Za-z][\)\.]\s*(.+)');
    final match = regex.firstMatch(line);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim();
    }

    return '';
  }

  /// Encuentra el índice de la siguiente pregunta
  static int _findNextQuestion(List<String> lines, int currentIndex) {
    int index = currentIndex + 1;

    // Buscar línea que contenga ANSWER: y luego VALUE: (opcional)
    bool foundAnswer = false;
    while (index < lines.length) {
      if (lines[index].toUpperCase().startsWith('ANSWER:')) {
        foundAnswer = true;
      } else if (foundAnswer &&
          lines[index].toUpperCase().startsWith('VALUE:')) {
        return index + 1;
      } else if (foundAnswer && lines[index].trim().isEmpty) {
        // Línea vacía después de ANSWER (sin VALUE)
        return index + 1;
      } else if (foundAnswer &&
          !lines[index].toUpperCase().startsWith('VALUE:') &&
          lines[index].trim().isNotEmpty) {
        // Nueva pregunta encontrada
        return index;
      }
      index++;
    }

    return index;
  }

  /// Valida si un contenido es formato AIKEN válido
  static bool isValidAikenFormat(String content) {
    final lines = content.split('\n');

    // Debe contener al menos una línea con ANSWER:
    bool hasAnswer =
        lines.any((line) => line.trim().toUpperCase().startsWith('ANSWER:'));

    // Debe contener al menos una opción
    bool hasOptions = lines.any((line) => _isOption(line.trim()));

    return hasAnswer && hasOptions;
  }

  /// Convierte preguntas a formato AIKEN
  static String questionsToAiken(List<Question> questions) {
    final buffer = StringBuffer();

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];

      // Enunciado
      buffer.writeln(question.statement);
      buffer.writeln();

      // Opciones
      for (int j = 0; j < question.options.length; j++) {
        final letter = String.fromCharCode(65 + j); // A, B, C...
        buffer.writeln('$letter) ${question.options[j]}');
      }

      // Respuesta correcta
      if (question.correctAnswers.isNotEmpty) {
        buffer.write('ANSWER: ');
        buffer.writeln(question.correctAnswers.join(','));
      }

      // Valoración si es diferente de 1.0
      if (question.value != 1.0) {
        buffer.writeln('VALUE: ${question.value}');
      }

      // Separador entre preguntas
      if (i < questions.length - 1) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }
}
