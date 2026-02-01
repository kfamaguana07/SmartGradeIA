import 'package:flutter/foundation.dart';
import 'package:smartgrade_ai/domain/entities/question.dart';
import 'package:smartgrade_ai/domain/repositories/question_repository.dart';

class QuestionProvider with ChangeNotifier {
  final QuestionRepository _repository;

  List<Question> _questions = [];
  bool _isLoading = false;
  String? _error;

  QuestionProvider(this._repository);

  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadQuestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _repository.getAllQuestions();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar preguntas: $e';
      _questions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadQuestionsBySubject(int subjectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _repository.getQuestionsBySubject(subjectId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar preguntas de la materia: $e';
      _questions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createQuestion(Question question) async {
    try {
      final id = await _repository.createQuestion(question);
      await loadQuestions();
      return id > 0;
    } catch (e) {
      _error = 'Error al crear pregunta: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createMultipleQuestions(List<Question> questions) async {
    try {
      await _repository.createMultipleQuestions(questions);
      await loadQuestions();
      return true;
    } catch (e) {
      _error = 'Error al crear preguntas: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuestion(Question question) async {
    try {
      final result = await _repository.updateQuestion(question);
      await loadQuestions();
      return result > 0;
    } catch (e) {
      _error = 'Error al actualizar pregunta: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteQuestion(int id) async {
    try {
      final result = await _repository.deleteQuestion(id);
      await loadQuestions();
      return result > 0;
    } catch (e) {
      _error = 'Error al eliminar pregunta: $e';
      notifyListeners();
      return false;
    }
  }
}
