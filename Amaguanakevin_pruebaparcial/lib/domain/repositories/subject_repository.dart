import 'package:smartgrade_ai/domain/entities/subject.dart';

abstract class SubjectRepository {
  Future<int> createSubject(Subject subject);
  Future<Subject?> getSubject(int id);
  Future<List<Subject>> getAllSubjects();
  Future<List<Subject>> getSubjectsByTeacher(int teacherId);
  Future<int> updateSubject(Subject subject);
  Future<int> deleteSubject(int id);
}
