import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  Dio get dio => _dio;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(_AuthInterceptor(_dio));
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio);

  // ── Inject Bearer token into every request ─────────────────────────────
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.instance.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ── Handle 401 — try token refresh once ────────────────────────────────
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await TokenStorage.instance.getRefreshToken();
        if (refreshToken == null) {
          await _clearAndReject(err, handler);
          return;
        }

        // Ask for a new access token
        final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
        final response = await refreshDio.post(
          ApiConstants.refresh,
          data: {'refreshToken': refreshToken},
        );

        final newAccessToken = response.data['data']['accessToken'] as String;
        final newRefreshToken = response.data['data']['refreshToken'] as String;

        await TokenStorage.instance.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // Retry original request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(err.requestOptions);
        handler.resolve(retryResponse);
      } catch (_) {
        // Refresh also failed → force logout
        await TokenStorage.instance.deleteTokens();
        handler.reject(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  Future<void> _clearAndReject(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    await TokenStorage.instance.deleteTokens();
    handler.reject(err);
  }
}
