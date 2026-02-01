import 'package:smartgrade_ai/domain/entities/question.dart';

abstract class QuestionRepository {
  Future<int> createQuestion(Question question);
  Future<Question?> getQuestion(int id);
  Future<List<Question>> getAllQuestions();
  Future<List<Question>> getQuestionsBySubject(int subjectId);
  Future<int> updateQuestion(Question question);
  Future<int> deleteQuestion(int id);
  Future<List<int>> createMultipleQuestions(List<Question> questions);
}
