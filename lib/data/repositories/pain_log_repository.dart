import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/pain_log_model.dart';

class PainLogRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<PainLogModel>> getPainLogs({int limit = 7}) async {
    try {
      final res = await _dio.get('${ApiConstants.painLogs}?limit=$limit');
      final data = res.data['data'] as List<dynamic>;
      return data.map((e) => PainLogModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error al obtener registros de dolor: $e');
    }
  }

  Future<PainStatsModel> getPainStats() async {
    try {
      final res = await _dio.get(ApiConstants.painStats);
      return PainStatsModel.fromJson(res.data);
    } catch (e) {
      throw Exception('Error al obtener estadísticas de dolor: $e');
    }
  }

  Future<PainLogModel> addPainLog(int painLevel, {String? notes, String? injuryId}) async {
    try {
      final res = await _dio.post(ApiConstants.painLogs, data: {
        'painLevel': painLevel,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (injuryId != null && injuryId.isNotEmpty) 'injuryId': injuryId,
      });
      return PainLogModel.fromJson(res.data['data']);
    } catch (e) {
      throw Exception('Error al agregar registro de dolor: $e');
    }
  }
}
