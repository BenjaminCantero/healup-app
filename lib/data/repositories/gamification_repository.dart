import 'package:dio/dio.dart';
import '../models/gamification_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

class GamificationRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final res = await _dio.get(ApiConstants.dashboard);
      return DashboardStatsModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<AchievementModel>> getAchievements() async {
    try {
      final res = await _dio.get(ApiConstants.achievements);
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<DailyTaskModel>> getDailyTasks() async {
    try {
      final res = await _dio.get(ApiConstants.dailyTasks);
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => DailyTaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<DailyTaskModel> createDailyTask(String title, String category) async {
    try {
      final res = await _dio.post(
        ApiConstants.dailyTasks,
        data: {'title': title, 'category': category},
      );
      return DailyTaskModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> completeTask(String taskId) async {
    try {
      await _dio.post(ApiConstants.completeTask(taskId));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
