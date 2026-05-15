import 'package:dio/dio.dart';

/// Convierte cualquier error de Dio en un mensaje legible para la UI
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Intentar leer el mensaje de error estructurado de la API HealUp
    String? apiMessage;
    if (data is Map<String, dynamic>) {
      apiMessage = data['message'] as String? ??
          data['error'] as String?;
    }

    final message = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'Tiempo de conexión agotado. Verifica tu red.',
      DioExceptionType.connectionError =>
        'No se pudo conectar al servidor. ¿Está el servidor iniciado?',
      DioExceptionType.badResponse => switch (statusCode) {
          400 => apiMessage ?? 'Solicitud inválida.',
          401 => apiMessage ?? 'Sesión expirada. Inicia sesión nuevamente.',
          403 => apiMessage ?? 'No tienes permiso para esta acción.',
          404 => apiMessage ?? 'Recurso no encontrado.',
          409 => apiMessage ?? 'El recurso ya existe.',
          422 => apiMessage ?? 'Los datos enviados son inválidos.',
          429 => 'Demasiados intentos. Espera un momento.',
          500 => 'Error del servidor. Intenta más tarde.',
          _ => apiMessage ?? 'Error desconocido ($statusCode).',
        },
      _ => apiMessage ?? e.message ?? 'Error de red desconocido.',
    };

    return ApiException(message: message, statusCode: statusCode);
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
