import 'package:flutter/foundation.dart';
import 'package:smartgrade_ai/domain/entities/student.dart';
import 'package:smartgrade_ai/domain/repositories/student_repository.dart';

class StudentProvider with ChangeNotifier {
  final StudentRepository _repository;

  List<Student> _students = [];
  bool _isLoading = false;
  String? _error;

  StudentProvider(this._repository);

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _repository.getAllStudents();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar estudiantes: $e';
      _students = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createStudent(Student student) async {
    try {
      final id = await _repository.createStudent(student);
      await loadStudents();
      return id > 0;
    } catch (e) {
      _error = 'Error al crear estudiante: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudent(Student student) async {
    try {
      final result = await _repository.updateStudent(student);
      await loadStudents();
      return result > 0;
    } catch (e) {
      _error = 'Error al actualizar estudiante: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudent(int id) async {
    try {
      final result = await _repository.deleteStudent(id);
      await loadStudents();
      return result > 0;
    } catch (e) {
      _error = 'Error al eliminar estudiante: $e';
      notifyListeners();
      return false;
    }
  }
}
