import 'package:smartgrade_ai/domain/entities/result.dart';
import 'package:smartgrade_ai/domain/repositories/result_repository.dart';
import 'package:smartgrade_ai/data/datasources/database_helper.dart';
import 'package:smartgrade_ai/data/models/result_model.dart';

class ResultRepositoryImpl implements ResultRepository {
  final DatabaseHelper _dbHelper;

  ResultRepositoryImpl(this._dbHelper);

  @override
  Future<int> createResult(Result result) async {
    final model = ResultModel.fromEntity(result);
    return await _dbHelper.createResult(model);
  }

  @override
  Future<Result?> getResult(int id) async {
    final model = await _dbHelper.getResult(id);
    return model?.toEntity();
  }

  @override
  Future<List<Result>> getAllResults() async {
    final models = await _dbHelper.getAllResults();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Result>> getResultsByExam(int examId) async {
    final models = await _dbHelper.getResultsByExam(examId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Result>> getResultsByStudent(int studentId) async {
    final models = await _dbHelper.getResultsByStudent(studentId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> updateResult(Result result) async {
    final model = ResultModel.fromEntity(result);
    return await _dbHelper.updateResult(model);
  }

  @override
  Future<int> deleteResult(int id) async {
    return await _dbHelper.deleteResult(id);
  }
}
