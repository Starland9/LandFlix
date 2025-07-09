import 'package:dio/dio.dart';
import 'package:french_stream_downloader/src/core/env/env.dart';

class DioService {
  Future<Dio> init() async {
    final dio = Dio();
    dio.options.baseUrl = Env.apiUrl;
    return dio;
  }
}
