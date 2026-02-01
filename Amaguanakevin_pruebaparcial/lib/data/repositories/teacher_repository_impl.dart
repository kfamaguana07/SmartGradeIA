import 'package:smartgrade_ai/domain/entities/teacher.dart';
import 'package:smartgrade_ai/domain/repositories/teacher_repository.dart';
import 'package:smartgrade_ai/data/datasources/database_helper.dart';
import 'package:smartgrade_ai/data/models/teacher_model.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final DatabaseHelper _dbHelper;

  TeacherRepositoryImpl(this._dbHelper);

  @override
  Future<int> createTeacher(Teacher teacher) async {
    final model = TeacherModel.fromEntity(teacher);
    return await _dbHelper.createTeacher(model);
  }

  @override
  Future<Teacher?> getTeacher(int id) async {
    final model = await _dbHelper.getTeacher(id);
    return model?.toEntity();
  }

  @override
  Future<List<Teacher>> getAllTeachers() async {
    final models = await _dbHelper.getAllTeachers();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> updateTeacher(Teacher teacher) async {
    final model = TeacherModel.fromEntity(teacher);
    return await _dbHelper.updateTeacher(model);
  }

  @override
  Future<int> deleteTeacher(int id) async {
    return await _dbHelper.deleteTeacher(id);
  }
}
