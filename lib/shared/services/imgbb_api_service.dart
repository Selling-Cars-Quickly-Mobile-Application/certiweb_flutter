import 'package:dio/dio.dart';
import '../../config/dio_client.dart';
import '../../environments/environment.dart';
import 'dart:typed_data';

class ImgbbApiService {
  final Dio _dio = DioClient.instance.dio;
  final Dio _dioNoAuth = Dio();

  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });
    final url = 'https://api.imgbb.com/1/upload?key=${Environment.imgbbApiKey}';
    final res = await _dioNoAuth.post(url, data: formData);
    final data = Map<String, dynamic>.from(res.data);
    return Map<String, dynamic>.from(data['data']);
  }

  Future<Map<String, dynamic>> uploadImageBytes(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final url = 'https://api.imgbb.com/1/upload?key=${Environment.imgbbApiKey}';
    final res = await _dioNoAuth.post(url, data: formData);
    final data = Map<String, dynamic>.from(res.data);
    return Map<String, dynamic>.from(data['data']);
  }
}