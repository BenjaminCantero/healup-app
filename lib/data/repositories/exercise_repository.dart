import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/storage/token_storage.dart';
import '../models/exercise_model.dart';

class ExerciseRepository {
  final TokenStorage _tokenStorage = TokenStorage.instance;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ExerciseModel>> getExercises({int limit = 10}) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.exercises}?limit=$limit');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'] as List<dynamic>;
      return data.map((e) => ExerciseModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load exercises: ${response.statusCode}');
    }
  }

  Future<ExerciseModel> getExerciseById(String id) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.exerciseById(id)}');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return ExerciseModel.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load exercise');
    }
  }
}
