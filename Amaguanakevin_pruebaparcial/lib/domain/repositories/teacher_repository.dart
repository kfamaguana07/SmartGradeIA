import 'package:smartgrade_ai/domain/entities/teacher.dart';

abstract class TeacherRepository {
  Future<int> createTeacher(Teacher teacher);
  Future<Teacher?> getTeacher(int id);
  Future<List<Teacher>> getAllTeachers();
  Future<int> updateTeacher(Teacher teacher);
  Future<int> deleteTeacher(int id);
}
