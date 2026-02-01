import 'package:smartgrade_ai/domain/entities/student.dart';
import 'package:smartgrade_ai/domain/repositories/student_repository.dart';
import 'package:smartgrade_ai/data/datasources/database_helper.dart';
import 'package:smartgrade_ai/data/models/student_model.dart';

/// Implementación del repositorio de estudiantes
class StudentRepositoryImpl implements StudentRepository {
  final DatabaseHelper _dbHelper;

  StudentRepositoryImpl(this._dbHelper);

  @override
  Future<int> createStudent(Student student) async {
    final model = StudentModel.fromEntity(student);
    return await _dbHelper.createStudent(model);
  }

  @override
  Future<Student?> getStudent(int id) async {
    final model = await _dbHelper.getStudent(id);
    return model?.toEntity();
  }

  @override
  Future<List<Student>> getAllStudents() async {
    final models = await _dbHelper.getAllStudents();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> updateStudent(Student student) async {
    final model = StudentModel.fromEntity(student);
    return await _dbHelper.updateStudent(model);
  }

  @override
  Future<int> deleteStudent(int id) async {
    return await _dbHelper.deleteStudent(id);
  }

  @override
  Future<Student?> getStudentByIdentification(String identification) async {
    final students = await getAllStudents();
    try {
      return students.firstWhere((s) => s.identification == identification);
    } catch (e) {
      return null;
    }
  }
}
