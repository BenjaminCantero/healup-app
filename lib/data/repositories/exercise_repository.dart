import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/constants/api_constants.dart';
import '../models/exercise_model.dart';

class ExerciseCategory {
  final String id;
  final String name;
  final String? description;

  const ExerciseCategory({
    required this.id,
    required this.name,
    this.description,
  });

  factory ExerciseCategory.fromJson(Map<String, dynamic> json) =>
      ExerciseCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
      );
}

class ExerciseRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<ExerciseModel>> getExercises({
    int limit = 10,
    int page = 1,
    String? categoryId,
    String? difficulty,
    String? bodyPartSlug,
  }) async {
    try {
      final res = await _dio.get(
        ApiConstants.exercises,
        queryParameters: {
          'limit': limit,
          'page': page,
          if (categoryId != null) 'categoryId': categoryId,
          if (difficulty != null) 'difficulty': difficulty,
          if (bodyPartSlug != null) 'bodyPartSlug': bodyPartSlug,
        },
      );
      final data = res.data['data'] as List<dynamic>;
      return data
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ExerciseModel> getExerciseById(String id) async {
    try {
      final res = await _dio.get(ApiConstants.exerciseById(id));
      return ExerciseModel.fromJson(
          res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<ExerciseCategory>> getCategories() async {
    try {
      final res = await _dio.get(ApiConstants.exerciseCategories);
      final data = res.data['data'] as List<dynamic>;
      return data
          .map((e) =>
              ExerciseCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
