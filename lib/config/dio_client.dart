import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../environments/environment.dart';

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();
  late final Dio dio = Dio(BaseOptions(baseUrl: Environment.baseUrl))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('authToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('authToken');
          await prefs.remove('currentUser');
          await prefs.remove('adminToken');
          await prefs.remove('currentAdmin');
          await prefs.remove('currentSession');
        }
        handler.next(error);
      },
    ));
}