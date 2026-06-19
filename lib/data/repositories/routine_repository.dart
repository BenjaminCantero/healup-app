import 'package:dio/dio.dart';
import '../models/exercise_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

class RoutineRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<RoutineModel>> getRoutines() async {
    try {
      final res = await _dio.get(ApiConstants.routines);
      final list = res.data['data'] as List<dynamic>;
      return list.map((e) => RoutineModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<RoutineModel?> getRoutineByInjury(String injuryId) async {
    try {
      final res = await _dio.get(ApiConstants.routineByInjury(injuryId));
      if (res.data['data'] == null) return null;
      return RoutineModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Genera (o devuelve, si ya existe) una rutina de rehabilitación para la
  /// lesión, eligiendo ejercicios según la zona del cuerpo afectada.
  Future<RoutineModel> generateForInjury(String injuryId) async {
    try {
      final res = await _dio.post(ApiConstants.routineGenerate(injuryId));
      return RoutineModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
