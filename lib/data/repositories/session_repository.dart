import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/session_model.dart';

class SessionRepository {
  final Dio _dio = ApiClient.instance.dio;

  /// Lists all sessions for the authenticated user (newest first).
  Future<List<SessionModel>> getSessions({String? routineId}) async {
    try {
      final res = await _dio.get(
        ApiConstants.sessions,
        queryParameters: {
          'limit': 50,
          if (routineId != null) 'routineId': routineId,
        },
      );
      final data = res.data['data'] as List<dynamic>;
      return data
          .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Registra una sesión de rehabilitación completada.
  ///
  /// [exercises] es una lista de mapas, cada uno con al menos `exerciseId`
  /// y, opcionalmente, `setsCompleted` / `repsCompleted` / `painLevel`.
  /// El backend exige al menos un ejercicio.
  Future<void> createSession({
    String? routineId,
    int? durationMinutes,
    int? painAfter,
    String? notes,
    required List<Map<String, dynamic>> exercises,
  }) async {
    try {
      await _dio.post(
        ApiConstants.sessions,
        data: {
          if (routineId != null) 'routineId': routineId,
          if (durationMinutes != null) 'durationMinutes': durationMinutes,
          if (painAfter != null) 'painAfter': painAfter,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          'exercises': exercises,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
