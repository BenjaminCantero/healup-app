import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

/// Callback type invoked when the refresh token flow fails and
/// the user must be forcefully logged out at the Riverpod level.
typedef ForceLogoutCallback = Future<void> Function();

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio _dio;
  ForceLogoutCallback? _onForceLogout;

  Dio get dio => _dio;

  /// Initialise Dio. Call once from main() or from the ProviderScope.
  /// [onForceLogout] is invoked when a token refresh fails, so the
  /// auth state can be cleared reactively (fixing the zombie-session bug).
  void init({ForceLogoutCallback? onForceLogout}) {
    _onForceLogout = onForceLogout;
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(_AuthInterceptor(_dio, _onForceLogout));
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final ForceLogoutCallback? _onForceLogout;
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio, this._onForceLogout);

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
          await _forceLogoutAndReject(err, handler);
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
        // Refresh also failed → force logout at both storage AND state level
        await _forceLogoutAndReject(err, handler);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  /// Clear tokens from secure storage AND notify the Riverpod auth state
  /// so the UI immediately redirects to login (fixes zombie-session bug).
  Future<void> _forceLogoutAndReject(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    await TokenStorage.instance.deleteTokens();
    if (_onForceLogout != null) {
      await _onForceLogout!();
    }
    handler.reject(err);
  }
}
