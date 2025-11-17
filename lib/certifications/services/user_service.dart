import 'package:dio/dio.dart';
import '../../config/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserService {
  final Dio _dio = DioClient.instance.dio;

  Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionStr = prefs.getString('currentSession');
    if (sessionStr == null) {
      throw Exception('No active session');
    }
    Map<String, dynamic> session = {};
    try {
      session = Map<String, dynamic>.from(jsonDecode(sessionStr));
    } catch (_) {}
    final userId = session['userId']?.toString();
    final email = session['email']?.toString();
    try {
      if (userId != null) {
        final res = await _dio.get('/users/$userId');
        final data = Map<String, dynamic>.from(res.data);
        data['id'] = data['id'] ?? userId;
        return data;
      }
    } catch (_) {}
    if (email != null) {
      final res = await _dio.get('/users', queryParameters: {'email': email});
      final list = List<Map<String, dynamic>>.from(res.data);
      if (list.isNotEmpty) {
        final user = list.first;
        return user;
      }
    }
    final name = session['name']?.toString();
    if (name != null && userId != null) {
      return {'id': userId, 'name': name, 'email': email};
    }
    throw Exception('User not found');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentSession');
    await prefs.remove('authToken');
    await prefs.remove('currentUser');
    await prefs.remove('adminToken');
    await prefs.remove('currentAdmin');
  }
}