import 'package:dio/dio.dart';
import '../../config/dio_client.dart';
import '../../environments/environment.dart';

class ImgbbApiService {
  final Dio _dio = DioClient.instance.dio;

  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });
    final url = 'https://api.imgbb.com/1/upload?key=${Environment.imgbbApiKey}';
    final res = await _dio.post(url, data: formData);
    final data = Map<String, dynamic>.from(res.data);
    return Map<String, dynamic>.from(data['data']);
  }
}