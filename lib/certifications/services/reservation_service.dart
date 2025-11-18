import 'package:dio/dio.dart';
import '../../config/dio_client.dart';

class ReservationService {
  final Dio _dio = DioClient.instance.dio;

  Future<Map<String, dynamic>> createReservation(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(
        '/reservations',
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      assert(() { print('Request headers: '+(res.requestOptions.headers.toString())); return true; }());
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: Response(requestOptions: e.requestOptions, statusCode: 401, data: {'message': 'Authorization token is required'}),
        );
      } else if (e.response?.statusCode == 400) {
        print('Error 400 en POST /reservations:');
        print('Payload enviado: ${data}');
        print('Respuesta del servidor: ${e.response?.data}');
        print('Request headers: ${e.requestOptions.headers}');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllReservations() async {
    final res = await _dio.get('/reservations');
    return List<Map<String, dynamic>>.from(res.data);
  }

  Future<Map<String, dynamic>> getReservationById(dynamic id) async {
    final res = await _dio.get('/reservations/$id');
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> updateReservationStatus(dynamic id, String status) async {
    try {
      assert(() { print('PUT /reservations/$id body={"status":"$status"}'); return true; }());
      final res = await _dio.put(
        '/reservations/$id',
        data: {'status': status},
        options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}),
      );
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        print('Error al actualizar estado de reserva $id -> $status');
        print('Headers: ${e.requestOptions.headers}');
        print('Respuesta: ${e.response?.data}');
      }
      rethrow;
    }
  }
}