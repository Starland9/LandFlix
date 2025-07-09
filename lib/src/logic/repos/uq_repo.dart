import 'package:dio/dio.dart';
import 'package:french_stream_downloader/src/logic/models/search_result.dart';
import 'package:french_stream_downloader/src/logic/models/uqvideo.dart';

class UqRepo {
  final Dio _dio;

  UqRepo(this._dio);

  Future<List<SearchResult>> search(String query) async {
    final response = await _dio.get(
      '/search',
      queryParameters: {'query': query},
    );
    return (response.data['results'] as List)
        .map((e) => SearchResult.fromJson(e))
        .toList();
  }

  Future<List<Uqvideo>> getUqVideos({required String htmlUrl}) async {
    final response = await _dio.post(
      '/get-videos',
      data: {'media_url': htmlUrl},
    );
    return (response.data['results'] as List)
        .map((e) => Uqvideo.fromJson(e))
        .toList();
  }
}
