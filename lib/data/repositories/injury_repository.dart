import 'package:dio/dio.dart';
import '../models/injury_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

class InjuryRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<InjuryModel>> getInjuries({int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get(
        ApiConstants.injuries,
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => InjuryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<InjuryModel> createInjury(Map<String, dynamic> dto) async {
    try {
      final res = await _dio.post(ApiConstants.injuries, data: dto);
      return InjuryModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<InjuryModel> updateInjury(String id, Map<String, dynamic> dto) async {
    try {
      final res = await _dio.patch(ApiConstants.injuryById(id), data: dto);
      return InjuryModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteInjury(String id) async {
    try {
      await _dio.delete(ApiConstants.injuryById(id));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<BodyPartModel>> getBodyParts() async {
    try {
      final res = await _dio.get(ApiConstants.bodyParts);
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => BodyPartModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
