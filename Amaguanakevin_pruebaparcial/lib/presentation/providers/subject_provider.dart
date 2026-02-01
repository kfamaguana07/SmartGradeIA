import 'package:flutter/foundation.dart';
import 'package:smartgrade_ai/domain/entities/subject.dart';
import 'package:smartgrade_ai/domain/repositories/subject_repository.dart';

class SubjectProvider with ChangeNotifier {
  final SubjectRepository _repository;

  List<Subject> _subjects = [];
  bool _isLoading = false;
  String? _error;

  SubjectProvider(this._repository);

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSubjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subjects = await _repository.getAllSubjects();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar materias: $e';
      _subjects = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubjectsByTeacher(int teacherId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subjects = await _repository.getSubjectsByTeacher(teacherId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar materias del profesor: $e';
      _subjects = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSubject(Subject subject) async {
    try {
      final id = await _repository.createSubject(subject);
      await loadSubjects();
      return id > 0;
    } catch (e) {
      _error = 'Error al crear materia: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSubject(Subject subject) async {
    try {
      final result = await _repository.updateSubject(subject);
      await loadSubjects();
      return result > 0;
    } catch (e) {
      _error = 'Error al actualizar materia: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubject(int id) async {
    try {
      final result = await _repository.deleteSubject(id);
      await loadSubjects();
      return result > 0;
    } catch (e) {
      _error = 'Error al eliminar materia: $e';
      notifyListeners();
      return false;
    }
  }
}
