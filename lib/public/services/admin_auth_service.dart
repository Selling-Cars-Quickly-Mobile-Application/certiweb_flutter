import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/dio_client.dart';

class AdminAuthService {
  final Dio _dio = DioClient.instance.dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/admin_user/login', data: {
      'email': email,
      'password': password,
    });
    final data = Map<String, dynamic>.from(res.data);
    final token = data['token']?.toString();
    if (token != null && token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      await prefs.setString('adminToken', 'admin_session');
      await prefs.setString('currentAdmin', data['user']?.toString() ?? email);
    }
    return data;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminToken');
    await prefs.remove('currentAdmin');
  }

  Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('adminToken') ?? '').isNotEmpty;
  }
}