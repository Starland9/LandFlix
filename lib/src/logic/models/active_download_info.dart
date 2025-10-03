import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:uqload_downloader_dart/uqload_downloader_dart.dart';

/// Modèle décrivant un téléchargement en cours géré par background_downloader.
class ActiveDownloadInfo {
  final String url;
  final String title;
  final double progress;
  final bd.TaskStatus status;
  final String? taskId;
  final VideoInfo? videoInfo;
  final bd.DownloadTask task;

  const ActiveDownloadInfo({
    required this.url,
    required this.title,
    required this.progress,
    required this.status,
    required this.taskId,
    required this.videoInfo,
    required this.task,
  });

  /// Crée une copie modifiée de l’instance.
  ActiveDownloadInfo copyWith({
    String? url,
    String? title,
    double? progress,
    bd.TaskStatus? status,
    String? taskId,
    VideoInfo? videoInfo,
    bd.DownloadTask? task,
  }) {
    return ActiveDownloadInfo(
      url: url ?? this.url,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      taskId: taskId ?? this.taskId,
      videoInfo: videoInfo ?? this.videoInfo,
      task: task ?? this.task,
    );
  }
}
