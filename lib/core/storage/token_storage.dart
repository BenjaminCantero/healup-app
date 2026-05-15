import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAccessToken = 'healup_access_token';
const _kRefreshToken = 'healup_refresh_token';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  Future<void> deleteTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
    ]);
  }

  Future<bool> get isAuthenticated async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
