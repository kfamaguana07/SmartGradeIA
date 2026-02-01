import 'package:smartgrade_ai/domain/entities/question.dart';
import 'package:smartgrade_ai/domain/repositories/question_repository.dart';
import 'package:smartgrade_ai/data/datasources/database_helper.dart';
import 'package:smartgrade_ai/data/models/question_model.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final DatabaseHelper _dbHelper;

  QuestionRepositoryImpl(this._dbHelper);

  @override
  Future<int> createQuestion(Question question) async {
    final model = QuestionModel.fromEntity(question);
    return await _dbHelper.createQuestion(model);
  }

  @override
  Future<Question?> getQuestion(int id) async {
    final model = await _dbHelper.getQuestion(id);
    return model?.toEntity();
  }

  @override
  Future<List<Question>> getAllQuestions() async {
    final models = await _dbHelper.getAllQuestions();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Question>> getQuestionsBySubject(int subjectId) async {
    final models = await _dbHelper.getQuestionsBySubject(subjectId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> updateQuestion(Question question) async {
    final model = QuestionModel.fromEntity(question);
    return await _dbHelper.updateQuestion(model);
  }

  @override
  Future<int> deleteQuestion(int id) async {
    return await _dbHelper.deleteQuestion(id);
  }

  @override
  Future<List<int>> createMultipleQuestions(List<Question> questions) async {
    final List<int> ids = [];
    for (final question in questions) {
      final id = await createQuestion(question);
      ids.add(id);
    }
    return ids;
  }
}
