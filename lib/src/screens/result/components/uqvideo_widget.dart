import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/logic/models/uqvideo.dart';
import 'package:url_launcher/url_launcher.dart';

class UqvideoWidget extends StatelessWidget {
  const UqvideoWidget({super.key, required this.uqvideo});

  final Uqvideo uqvideo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      title: Text(uqvideo.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        uqvideo.sizeInBytes / 1024 / 1024 > 1
            ? "${uqvideo.sizeInBytes / 1024 / 1024} MB"
            : "${uqvideo.sizeInBytes / 1024} KB".toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton.outlined(
        onPressed: () => _download(context),
        icon: const Icon(Icons.download),
      ),
    );
  }

  void _download(BuildContext context) async {
    try {
      await _launchBrowser();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _launchBrowser() async {
    final uri = Uri.parse(uqvideo.url);
    final scheme = uri.scheme;
    final netloc = uri.host;

    final headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
      'Accept':
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
      "Referer": "$scheme://$netloc",
    };

    await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
      webViewConfiguration: WebViewConfiguration(headers: headers),
      webOnlyWindowName: "Download",
    );
  }
}
