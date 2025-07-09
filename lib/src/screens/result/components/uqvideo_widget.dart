import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/logic/models/uqvideo.dart';
import 'package:path_provider/path_provider.dart';

class UqvideoWidget extends StatefulWidget {
  const UqvideoWidget({super.key, required this.uqvideo});

  final Uqvideo uqvideo;

  @override
  State<UqvideoWidget> createState() => _UqvideoWidgetState();
}

class _UqvideoWidgetState extends State<UqvideoWidget> {
  final Dio _dio = Dio();
  bool _isDownloading = false;
  double _progress = 0.0;
  CancelToken _cancelToken = CancelToken();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      title: Text(
        widget.uqvideo.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        widget.uqvideo.sizeInBytes / 1024 / 1024 > 1
            ? "${widget.uqvideo.sizeInBytes / 1024 / 1024} MB"
            : "${widget.uqvideo.sizeInBytes / 1024} KB".toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _isDownloading
          ? Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(value: _progress),
                IconButton(
                  onPressed: _cancelDownload,
                  icon: const Icon(Icons.close),
                ),
              ],
            )
          : IconButton.outlined(
              onPressed: () => _download(context),
              icon: const Icon(Icons.download),
            ),
    );
  }

  void _cancelDownload() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel();
    }
    setState(() {
      _isDownloading = false;
      _progress = 0.0;
    });
  }

  Future<void> _download(BuildContext context) async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _cancelToken = CancelToken();
    });

    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception("Could not get downloads directory");
      }
      final filePath = '${directory.path}/${widget.uqvideo.title}.mp4';

      final uri = Uri.parse(widget.uqvideo.url);
      final scheme = uri.scheme;
      final netloc = uri.host;

      final headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
        'Accept':
            "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        "Referer": "$scheme://$netloc",
      };

      final response = await _dio.get(
        widget.uqvideo.url,
        options: Options(headers: headers),
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      if (response.data == null || response.data != List<int>) {
        throw Exception("Could not download video");
      }

      final file = File(filePath);
      await file.writeAsBytes(response.data);

      if (!_cancelToken.isCancelled && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download complete: $filePath')));
      }
    } on DioException catch (error) {
      if (!CancelToken.isCancel(error) && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $error')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _progress = 0.0;
        });
      }
    }
  }
}
