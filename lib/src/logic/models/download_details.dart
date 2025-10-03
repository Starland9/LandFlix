import 'package:french_stream_downloader/src/logic/services/uqload_download_service.dart';
import 'package:uqload_downloader_dart/uqload_downloader_dart.dart';

/// Classe pour les détails de téléchargement
class DownloadDetails {
  final VideoInfo videoInfo;
  final String downloadPath;
  final String fileName;
  final String downloadDir;
  final String htmlUrl;

  DownloadDetails({
    required this.videoInfo,
    required this.downloadPath,
    required this.fileName,
    required this.downloadDir,
    required this.htmlUrl,
  });

  String get formattedSize =>
      UQLoadDownloadService.formatFileSize(videoInfo.size);

  bool get hasValidInfo =>
      videoInfo.title.isNotEmpty && videoInfo.url.isNotEmpty;
}
