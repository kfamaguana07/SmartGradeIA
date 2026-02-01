import 'package:smartgrade_ai/domain/entities/student.dart';

abstract class StudentRepository {
  Future<int> createStudent(Student student);
  Future<Student?> getStudent(int id);
  Future<List<Student>> getAllStudents();
  Future<int> updateStudent(Student student);
  Future<int> deleteStudent(int id);
  Future<Student?> getStudentByIdentification(String identification);
}
