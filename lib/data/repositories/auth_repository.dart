import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/token_storage.dart';

class AuthRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<AuthResponse> login(String email, String password) async {
    try {
      final res = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return AuthResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AuthResponse> register(String fullName, String email, String password) async {
    try {
      final res = await _dio.post(
        ApiConstants.register,
        data: {'fullName': fullName, 'email': email, 'password': password},
      );
      return AuthResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await TokenStorage.instance.getRefreshToken();
      await _dio.post(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final res = await _dio.get(ApiConstants.me);
      return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      final res = await _dio.post(
        ApiConstants.profileAvatar,
        data: formData,
      );
      return res.data['data']['avatarUrl'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
