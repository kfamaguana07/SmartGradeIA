import 'package:flutter/foundation.dart';
import 'package:smartgrade_ai/domain/entities/teacher.dart';
import 'package:smartgrade_ai/domain/repositories/teacher_repository.dart';

class TeacherProvider with ChangeNotifier {
  final TeacherRepository _repository;

  List<Teacher> _teachers = [];
  bool _isLoading = false;
  String? _error;

  TeacherProvider(this._repository);

  List<Teacher> get teachers => _teachers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTeachers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teachers = await _repository.getAllTeachers();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar profesores: $e';
      _teachers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTeacher(Teacher teacher) async {
    try {
      final id = await _repository.createTeacher(teacher);
      await loadTeachers();
      return id > 0;
    } catch (e) {
      _error = 'Error al crear profesor: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTeacher(Teacher teacher) async {
    try {
      final result = await _repository.updateTeacher(teacher);
      await loadTeachers();
      return result > 0;
    } catch (e) {
      _error = 'Error al actualizar profesor: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTeacher(int id) async {
    try {
      final result = await _repository.deleteTeacher(id);
      await loadTeachers();
      return result > 0;
    } catch (e) {
      _error = 'Error al eliminar profesor: $e';
      notifyListeners();
      return false;
    }
  }
}
