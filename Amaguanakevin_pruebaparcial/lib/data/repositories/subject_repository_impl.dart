import 'package:smartgrade_ai/domain/entities/subject.dart';
import 'package:smartgrade_ai/domain/repositories/subject_repository.dart';
import 'package:smartgrade_ai/data/datasources/database_helper.dart';
import 'package:smartgrade_ai/data/models/subject_model.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final DatabaseHelper _dbHelper;

  SubjectRepositoryImpl(this._dbHelper);

  @override
  Future<int> createSubject(Subject subject) async {
    final model = SubjectModel.fromEntity(subject);
    return await _dbHelper.createSubject(model);
  }

  @override
  Future<Subject?> getSubject(int id) async {
    final model = await _dbHelper.getSubject(id);
    return model?.toEntity();
  }

  @override
  Future<List<Subject>> getAllSubjects() async {
    final models = await _dbHelper.getAllSubjects();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Subject>> getSubjectsByTeacher(int teacherId) async {
    final models = await _dbHelper.getSubjectsByTeacher(teacherId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> updateSubject(Subject subject) async {
    final model = SubjectModel.fromEntity(subject);
    return await _dbHelper.updateSubject(model);
  }

  @override
  Future<int> deleteSubject(int id) async {
    return await _dbHelper.deleteSubject(id);
  }
}
