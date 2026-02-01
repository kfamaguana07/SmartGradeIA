import 'package:flutter/foundation.dart';
import 'package:smartgrade_ai/domain/entities/result.dart';
import 'package:smartgrade_ai/domain/repositories/result_repository.dart';

class ResultProvider with ChangeNotifier {
  final ResultRepository _repository;

  List<Result> _results = [];
  bool _isLoading = false;
  String? _error;

  ResultProvider(this._repository);

  List<Result> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadResults() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _repository.getAllResults();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar resultados: $e';
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadResultsByExam(int examId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _repository.getResultsByExam(examId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar resultados del examen: $e';
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadResultsByStudent(int studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _repository.getResultsByStudent(studentId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar resultados del estudiante: $e';
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createResult(Result result) async {
    try {
      final id = await _repository.createResult(result);
      await loadResults();
      return id > 0;
    } catch (e) {
      _error = 'Error al crear resultado: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateResult(Result result) async {
    try {
      final res = await _repository.updateResult(result);
      await loadResults();
      return res > 0;
    } catch (e) {
      _error = 'Error al actualizar resultado: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteResult(int id) async {
    try {
      final result = await _repository.deleteResult(id);
      await loadResults();
      return result > 0;
    } catch (e) {
      _error = 'Error al eliminar resultado: $e';
      notifyListeners();
      return false;
    }
  }
}
