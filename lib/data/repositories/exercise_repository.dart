import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/constants/api_constants.dart';
import '../models/exercise_model.dart';

class ExerciseRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<ExerciseModel>> getExercises({int limit = 10}) async {
    try {
      final res = await _dio.get(
        ApiConstants.exercises,
        queryParameters: {'limit': limit},
      );
      final data = res.data['data'] as List<dynamic>;
      return data.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ExerciseModel> getExerciseById(String id) async {
    try {
      final res = await _dio.get(ApiConstants.exerciseById(id));
      return ExerciseModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
