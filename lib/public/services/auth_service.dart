import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../../config/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient.instance.dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
      final data = Map<String, dynamic>.from(res.data);
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', data['token']);
        await prefs.setString('currentUser', jsonEncode({
          'id': data['id'],
          'name': data['name'],
          'email': data['email'],
          'plan': data['plan']
        }));
        await prefs.setString('currentSession', jsonEncode({
          'userId': data['id'],
          'name': data['name'],
          'email': data['email'],
          'plan': data['plan'],
          'isLoggedIn': true,
          'isAdmin': false,
          'lastLogin': DateTime.now().toIso8601String()
        }));
      }
      return {'success': true, 'user': data};
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != 401) {}
      return {
        'success': false,
        'message': e.response?.data is Map ? e.response?.data['message'] ?? 'Authentication error' : e.response?.data ?? 'Authentication error'
      };
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final res = await _dio.post('/auth', data: userData);
      final data = Map<String, dynamic>.from(res.data);
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', data['token']);
        await prefs.setString('currentUser', jsonEncode({
          'id': data['id'],
          'name': data['name'],
          'email': data['email'],
          'plan': data['plan']
        }));
        await prefs.setString('currentSession', jsonEncode({
          'userId': data['id'],
          'name': data['name'],
          'email': data['email'],
          'plan': data['plan'],
          'isLoggedIn': true,
          'isAdmin': false
        }));
      }
      return {'success': true, 'user': data};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data is Map ? e.response?.data['message'] ?? 'Registration error' : e.response?.data ?? 'Registration error'
      };
    }
  }

  Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
    try {
      final res = await _dio.post('/admin_user/login', data: {'email': email, 'password': password});
      final data = Map<String, dynamic>.from(res.data);
      final role = data['role'];
      final isAdmin = role == 'admin' || data['isAdmin'] == true || (data['email']?.toString().contains('admin') == true);
      if (!isAdmin) {
        return {'success': false, 'message': 'You do not have administrator permissions'};
      }
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', data['token']);
        await prefs.setString('currentUser', jsonEncode({
          'id': data['id'],
          'name': data['name'],
          'email': data['email'],
          'isAdmin': true
        }));
        await prefs.setString('adminToken', 'admin_session');
        await prefs.setString('currentAdmin', jsonEncode(data));
        await prefs.setString('currentSession', jsonEncode({
          'userId': data['id'],
          'name': data['name'],
          'email': data['email'],
          'isLoggedIn': true,
          'isAdmin': true,
          'lastLogin': DateTime.now().toIso8601String()
        }));
      }
      return {'success': true, 'user': data, 'isAdmin': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data is Map ? e.response?.data['message'] ?? 'Administrator authentication error' : e.response?.data ?? 'Administrator authentication error'
      };
    }
  }

  Future<bool> refreshSession() async {
    try {
      final res = await _dio.get('/auth/me');
      final data = Map<String, dynamic>.from(res.data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', jsonEncode(data));
      await prefs.setString('currentSession', jsonEncode({
        'userId': data['id'],
        'name': data['name'],
        'email': data['email'],
        'isLoggedIn': true,
        'isAdmin': data['isAdmin'] == true,
        'lastLogin': DateTime.now().toIso8601String()
      }));
      return true;
    } on DioException catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('currentUser');
    await prefs.remove('adminToken');
    await prefs.remove('currentAdmin');
    await prefs.remove('currentSession');
  }
}