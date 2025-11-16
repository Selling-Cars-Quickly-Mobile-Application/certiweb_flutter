import '../../config/dio_client.dart';

class RegisterService {
  final _dio = DioClient.instance.dio;

  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    final res = await _dio.post('/users', data: userData);
    return Map<String, dynamic>.from(res.data);
  }
}