import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

const _kAccessToken = 'healup_access_token';
const _kRefreshToken = 'healup_refresh_token';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> _writeWeb(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> _readWeb(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _deleteWeb(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (kIsWeb) {
      await Future.wait([
        _writeWeb(_kAccessToken, accessToken),
        _writeWeb(_kRefreshToken, refreshToken),
      ]);
      return;
    }
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() => kIsWeb ? _readWeb(_kAccessToken) : _storage.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => kIsWeb ? _readWeb(_kRefreshToken) : _storage.read(key: _kRefreshToken);

  Future<void> saveAccessToken(String token) =>
      kIsWeb ? _writeWeb(_kAccessToken, token) : _storage.write(key: _kAccessToken, value: token);

  Future<void> deleteTokens() async {
    if (kIsWeb) {
      await Future.wait([
        _deleteWeb(_kAccessToken),
        _deleteWeb(_kRefreshToken),
      ]);
      return;
    }
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
