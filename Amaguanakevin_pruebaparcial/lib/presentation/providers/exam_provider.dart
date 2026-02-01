import 'package:flutter/foundation.dart';
import 'package:smartgrade_ai/domain/entities/exam.dart';
import 'package:smartgrade_ai/domain/entities/question.dart';
import 'package:smartgrade_ai/domain/repositories/exam_repository.dart';

class ExamProvider with ChangeNotifier {
  final ExamRepository _repository;

  List<Exam> _exams = [];
  List<Question> _currentExamQuestions = [];
  bool _isLoading = false;
  String? _error;

  ExamProvider(this._repository);

  List<Exam> get exams => _exams;
  List<Question> get currentExamQuestions => _currentExamQuestions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadExams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _exams = await _repository.getAllExams();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar exámenes: $e';
      _exams = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExamsBySubject(int subjectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _exams = await _repository.getExamsBySubject(subjectId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar exámenes de la materia: $e';
      _exams = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExamQuestions(int examId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentExamQuestions = await _repository.getExamQuestions(examId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar preguntas del examen: $e';
      _currentExamQuestions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> createExam(Exam exam, List<int> questionIds) async {
    try {
      final id = await _repository.createExam(exam);
      if (id > 0 && questionIds.isNotEmpty) {
        await _repository.addQuestionsToExam(id, questionIds);
      }
      await loadExams();
      return id;
    } catch (e) {
      _error = 'Error al crear examen: $e';
      notifyListeners();
      return 0;
    }
  }

  Future<bool> updateExam(Exam exam) async {
    try {
      final result = await _repository.updateExam(exam);
      await loadExams();
      return result > 0;
    } catch (e) {
      _error = 'Error al actualizar examen: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExam(int id) async {
    try {
      final result = await _repository.deleteExam(id);
      await loadExams();
      return result > 0;
    } catch (e) {
      _error = 'Error al eliminar examen: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addQuestionsToExam(int examId, List<int> questionIds) async {
    try {
      await _repository.addQuestionsToExam(examId, questionIds);
      await loadExamQuestions(examId);
      return true;
    } catch (e) {
      _error = 'Error al agregar preguntas al examen: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExamQuestions(int examId, List<int> questionIds) async {
    try {
      await _repository.removeAllQuestionsFromExam(examId);
      await _repository.addQuestionsToExam(examId, questionIds);
      await loadExamQuestions(examId);
      return true;
    } catch (e) {
      _error = 'Error al actualizar preguntas del examen: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeQuestionFromExam(int examId, int questionId) async {
    try {
      await _repository.removeQuestionFromExam(examId, questionId);
      await loadExamQuestions(examId);
      return true;
    } catch (e) {
      _error = 'Error al remover pregunta del examen: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<Question>> getExamQuestionsById(int examId) async {
    try {
      return await _repository.getExamQuestions(examId);
    } catch (e) {
      return [];
    }
  }
}
