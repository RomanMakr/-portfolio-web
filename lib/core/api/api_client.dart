import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Override with --dart-define=API_BASE_URL=https://api.example.com
/// Android emulator: http://10.0.2.2:8080
/// Chrome / desktop: http://localhost:8080
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

class ApiClient {
  ApiClient() : dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  final Dio dio;

  Future<List<dynamic>> templates() async =>
      (await dio.get<List<dynamic>>('/api/v1/templates')).data ?? [];

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/api/v1/auth/register',
      data: {'email': email, 'password': password, 'display_name': displayName},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data!;
  }

  Future<List<dynamic>> myPortfolios() async =>
      (await dio.get<List<dynamic>>('/api/v1/me/portfolios')).data ?? [];

  Future<Map<String, dynamic>> createPortfolio(Map<String, dynamic> data) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/api/v1/portfolios', data: data,
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> publicPortfolio(String slug) async {
    final response = await dio.get<Map<String, dynamic>>('/api/v1/public/$slug');
    return response.data!;
  }
}
