import 'package:smartgrade_ai/domain/entities/result.dart';

abstract class ResultRepository {
  Future<int> createResult(Result result);
  Future<Result?> getResult(int id);
  Future<List<Result>> getAllResults();
  Future<List<Result>> getResultsByExam(int examId);
  Future<List<Result>> getResultsByStudent(int studentId);
  Future<int> updateResult(Result result);
  Future<int> deleteResult(int id);
}
