import 'package:dio/dio.dart';
import '../../config/dio_client.dart';

class CarService {
  final Dio _dio = DioClient.instance.dio;

  Future<Map<String, dynamic>> createCar(Map<String, dynamic> payload) async {
    final res = await _dio.post('/cars', data: payload);
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<Map<String, dynamic>>> getAllCars() async {
    final res = await _dio.get('/cars');
    return List<Map<String, dynamic>>.from(res.data);
  }

  Future<Map<String, dynamic>> getCarById(dynamic id) async {
    final res = await _dio.get('/cars/$id');
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> updateCar(dynamic id, Map<String, dynamic> data) async {
    final res = await _dio.patch('/cars/$id', data: data);
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> getCarPdf(dynamic id) async {
    final res = await _dio.get('/cars/$id/pdf');
    return Map<String, dynamic>.from(res.data);
  }
}