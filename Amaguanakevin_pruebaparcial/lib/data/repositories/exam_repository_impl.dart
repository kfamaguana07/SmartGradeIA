import 'package:smartgrade_ai/domain/entities/exam.dart';
import 'package:smartgrade_ai/domain/entities/question.dart';
import 'package:smartgrade_ai/domain/repositories/exam_repository.dart';
import 'package:smartgrade_ai/data/datasources/database_helper.dart';
import 'package:smartgrade_ai/data/models/exam_model.dart';

class ExamRepositoryImpl implements ExamRepository {
  final DatabaseHelper _dbHelper;

  ExamRepositoryImpl(this._dbHelper);

  @override
  Future<int> createExam(Exam exam) async {
    final model = ExamModel.fromEntity(exam);
    return await _dbHelper.createExam(model);
  }

  @override
  Future<Exam?> getExam(int id) async {
    final model = await _dbHelper.getExam(id);
    return model?.toEntity();
  }

  @override
  Future<List<Exam>> getAllExams() async {
    final models = await _dbHelper.getAllExams();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Exam>> getExamsBySubject(int subjectId) async {
    final models = await _dbHelper.getExamsBySubject(subjectId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> updateExam(Exam exam) async {
    final model = ExamModel.fromEntity(exam);
    return await _dbHelper.updateExam(model);
  }

  @override
  Future<int> deleteExam(int id) async {
    return await _dbHelper.deleteExam(id);
  }

  @override
  Future<void> addQuestionsToExam(int examId, List<int> questionIds) async {
    return await _dbHelper.addQuestionsToExam(examId, questionIds);
  }

  @override
  Future<List<Question>> getExamQuestions(int examId) async {
    final models = await _dbHelper.getExamQuestions(examId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> removeQuestionFromExam(int examId, int questionId) async {
    return await _dbHelper.removeQuestionFromExam(examId, questionId);
  }

  @override
  Future<void> removeAllQuestionsFromExam(int examId) async {
    return await _dbHelper.removeAllQuestionsFromExam(examId);
  }
}
