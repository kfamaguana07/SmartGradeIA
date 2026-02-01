import 'package:smartgrade_ai/domain/entities/exam.dart';
import 'package:smartgrade_ai/domain/entities/question.dart';

abstract class ExamRepository {
  Future<int> createExam(Exam exam);
  Future<Exam?> getExam(int id);
  Future<List<Exam>> getAllExams();
  Future<List<Exam>> getExamsBySubject(int subjectId);
  Future<int> updateExam(Exam exam);
  Future<int> deleteExam(int id);
  Future<void> addQuestionsToExam(int examId, List<int> questionIds);
  Future<List<Question>> getExamQuestions(int examId);
  Future<void> removeQuestionFromExam(int examId, int questionId);
  Future<void> removeAllQuestionsFromExam(int examId);
}
