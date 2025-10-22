import 'dart:async';
import 'dart:convert';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:french_stream_downloader/src/logic/services/uqload_download_service.dart';
import 'package:uqload_downloader_dart/uqload_downloader_dart.dart' as uqload;

import '../../logic/services/download_manager.dart';
import '../models/download_models.dart';
import 'notification_service.dart';

class BackgroundDownloadSnapshot {
  final List<BackgroundDownloadItem> queuedDownloads;
  final Map<String, BackgroundDownloadItem> activeDownloads;

  const BackgroundDownloadSnapshot({
    required this.queuedDownloads,
    required this.activeDownloads,
  });
}

class BackgroundDownloadService {
  BackgroundDownloadService._internal();
  static final BackgroundDownloadService _instance =
      BackgroundDownloadService._internal();
  factory BackgroundDownloadService() => _instance;

  static const String _metadataTitleKey = 'title';
  static const String _metadataOriginalUrlKey = 'originalUrl';
  static const String _metadataFileNameKey = 'fileName';
  static const String _metadataOutputDirKey = 'outputDir';
  static const String _metadataFilePathKey = 'filePath';
  static const String _metadataNotificationIdKey = 'notificationId';
  static const String _metadataVideoInfoKey = 'videoInfo';
  static const String _metadataIsUqloadKey = 'isUqload';
  static const String _metadataThumbnailKey = 'thumbnailUrl';
  static const String _metadataResolutionKey = 'resolution';
  static const String _metadataDurationKey = 'duration';
  static const String _metadataSizeKey = 'size';
  static const String _metadataCreatedAtKey = 'createdAt';

  final FileDownloader _downloader = FileDownloader();
  StreamSubscription<TaskUpdate>? _updatesSubscription;

  bool _isInitialized = false;
  final List<BackgroundDownloadItem> _downloadQueue = [];
  final Map<String, BackgroundDownloadItem> _activeDownloads = {};
  final StreamController<BackgroundDownloadSnapshot> _stateController =
      StreamController.broadcast();

  Stream<BackgroundDownloadSnapshot> get stateStream => _stateController.stream;

  Future<void> initialize({bool requestPermissions = true}) async {
    if (_isInitialized) return;

    await NotificationService().initialize(
      requestPermissions: requestPermissions,
    );
    await DownloadManager.instance.initialize();

    _updatesSubscription ??= _downloader.updates.listen(
      _handleTaskUpdate,
      onError: (error, stack) {
        debugPrint('⚠️ Erreur while listening to downloader updates: $error');
      },
    );

    await _downloader.start();
    await _restoreFromDatabase();

    _isInitialized = true;
    _emitSnapshot();
    debugPrint(
      '✅ BackgroundDownloadService initialisé avec background_downloader',
    );
  }

  Future<String> startBackgroundDownload({
    required String url,
    required String title,
    String? outputDir,
    String? fileName,
  }) async {
    if (!_isInitialized) {
      await initialize(requestPermissions: false);
    }

    final bool isUqloadUrl = UQLoadDownloadService.isValidUQLoadUrl(url);
    uqload.VideoInfo? videoInfo;
    String resolvedTitle = title;
    String downloadUrl = url;
    String resolvedFileName = fileName ?? _sanitizeFileName(title);

    if (isUqloadUrl) {
      videoInfo = await UQLoadDownloadService.getVideoInfo(url);
      resolvedTitle = videoInfo.title;
      downloadUrl = videoInfo.url;
      resolvedFileName =
          fileName ?? UQLoadDownloadService.sanitizeFileName(videoInfo.title);
    }

    final String finalFileName = _ensureExtension(
      resolvedFileName,
      Uri.tryParse(downloadUrl),
    );
    final String outputDirectory =
        outputDir ?? await UQLoadDownloadService.getDefaultDownloadDirectory();
    final String filePath = _joinPath(outputDirectory, finalFileName);

    final (baseDirectory, directory, filenameForTask) = await Task.split(
      filePath: filePath,
    );

    final String downloadId =
        'dl_${DateTime.now().microsecondsSinceEpoch}_${downloadUrl.hashCode.abs()}';
    final int notificationId = NotificationService.generateNotificationId(
      '$downloadUrl$finalFileName',
    );

    final metadata = _buildMetadata(
      title: resolvedTitle,
      originalUrl: url,
      fileName: finalFileName,
      outputDir: outputDirectory,
      filePath: filePath,
      notificationId: notificationId,
      videoInfo: videoInfo,
      isUqload: isUqloadUrl,
    );

    final DownloadTask task = DownloadTask(
      taskId: downloadId,
      url: downloadUrl,
      filename: filenameForTask,
      directory: directory,
      baseDirectory: baseDirectory,
      updates: Updates.statusAndProgress,
      metaData: jsonEncode(metadata),
      displayName: resolvedTitle,
      allowPause: true,
      retries: 3,
    );

    final BackgroundDownloadItem queueItem = BackgroundDownloadItem(
      id: downloadId,
      url: url,
      title: resolvedTitle,
      fileName: finalFileName,
      outputDir: outputDirectory,
      notificationId: notificationId,
      status: DownloadStatus.queued,
      progress: 0,
      message: 'En attente de démarrage…',
      filePath: filePath,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _replaceOrAddInQueue(queueItem);
    _emitSnapshot();

    await NotificationService().showDownloadStarted(
      id: notificationId,
      title: resolvedTitle,
      fileName: finalFileName,
    );

    final bool enqueued = await _downloader.enqueue(task);
    if (!enqueued) {
      _downloadQueue.removeWhere((item) => item.id == downloadId);
      _emitSnapshot();
      throw Exception('Impossible de mettre en file le téléchargement.');
    }

    debugPrint('📥 Téléchargement en file: $resolvedTitle');
    return downloadId;
  }

  Future<void> cancelDownload(String downloadId) async {
    await _downloader.cancelTaskWithId(downloadId);

    final queuedIndex = _downloadQueue.indexWhere(
      (item) => item.id == downloadId,
    );
    BackgroundDownloadItem? removedItem = _activeDownloads.remove(downloadId);

    if (queuedIndex >= 0) {
      removedItem ??= _downloadQueue.removeAt(queuedIndex);
    }

    if (removedItem != null) {
      await NotificationService().cancelNotification(
        removedItem.notificationId,
      );
    }

    _emitSnapshot();
  }

  List<BackgroundDownloadItem> getQueuedDownloads() =>
      List.unmodifiable(_downloadQueue);

  Map<String, BackgroundDownloadItem> getActiveDownloads() =>
      Map.unmodifiable(_activeDownloads);

  bool isDownloading(String url) {
    return _downloadQueue.any((item) => item.url == url) ||
        _activeDownloads.values.any((item) => item.url == url);
  }

  void _handleTaskUpdate(TaskUpdate update) {
    if (update is TaskStatusUpdate) {
      unawaited(_handleStatusUpdate(update));
    } else if (update is TaskProgressUpdate) {
      _handleProgressUpdate(update);
    }
  }

  Future<void> _handleStatusUpdate(TaskStatusUpdate update) async {
    final task = update.task;
    if (task is! DownloadTask) return;

    final metadata = _metadataFromTask(task);
    final DownloadStatus status = _mapStatus(update.status);
    final BackgroundDownloadItem currentItem = _findOrCreateItem(
      task,
      metadata,
      status: status,
    );

    switch (update.status) {
      case TaskStatus.enqueued:
        _replaceOrAddInQueue(
          currentItem.copyWith(
            status: DownloadStatus.queued,
            message: 'En attente de démarrage…',
            updatedAt: DateTime.now(),
          ),
        );
        break;
      case TaskStatus.running:
        _promoteToActive(
          currentItem.copyWith(
            status: DownloadStatus.downloading,
            message: 'Téléchargement…',
            updatedAt: DateTime.now(),
          ),
        );
        break;
      case TaskStatus.waitingToRetry:
        _promoteToActive(
          currentItem.copyWith(
            status: DownloadStatus.downloading,
            message: 'Nouvelle tentative…',
            updatedAt: DateTime.now(),
          ),
        );
        break;
      case TaskStatus.paused:
        _promoteToActive(
          currentItem.copyWith(
            status: DownloadStatus.paused,
            message: 'Téléchargement en pause',
            updatedAt: DateTime.now(),
          ),
        );
        break;
      case TaskStatus.complete:
        final String filePath = await task.filePath();
        final completed = currentItem.copyWith(
          status: DownloadStatus.completed,
          progress: 1.0,
          message: 'Téléchargement terminé',
          filePath: filePath,
          updatedAt: DateTime.now(),
        );
        _activeDownloads.remove(completed.id);
        _downloadQueue.removeWhere((item) => item.id == completed.id);

        await NotificationService().showDownloadCompleted(
          id: completed.notificationId,
          fileName: completed.fileName,
          filePath: completed.filePath ?? '',
        );

        await _recordCompletion(completed, metadata);
        break;
      case TaskStatus.failed:
      case TaskStatus.notFound:
        final String errorMessage =
            update.exception?.toString() ?? 'Erreur inconnue';
        final failed = currentItem.copyWith(
          status: DownloadStatus.failed,
          message: errorMessage,
          updatedAt: DateTime.now(),
        );
        _activeDownloads.remove(failed.id);
        _downloadQueue.removeWhere((item) => item.id == failed.id);
        await NotificationService().showDownloadError(
          id: failed.notificationId,
          fileName: failed.fileName,
          error: errorMessage,
        );
        break;
      case TaskStatus.canceled:
        final cancelled = currentItem.copyWith(
          status: DownloadStatus.cancelled,
          message: 'Téléchargement annulé',
          updatedAt: DateTime.now(),
        );
        _activeDownloads.remove(cancelled.id);
        _downloadQueue.removeWhere((item) => item.id == cancelled.id);
        await NotificationService().cancelNotification(
          cancelled.notificationId,
        );
        break;
    }

    _emitSnapshot();
  }

  void _handleProgressUpdate(TaskProgressUpdate update) {
    final task = update.task;
    if (task is! DownloadTask) return;

    final metadata = _metadataFromTask(task);
    final double progress = update.progress.clamp(0.0, 1.0);
    final message = update.hasTimeRemaining
        ? 'Temps restant ${update.timeRemainingAsString}'
        : 'Téléchargement…';

    final BackgroundDownloadItem current =
        _findOrCreateItem(
          task,
          metadata,
          status: DownloadStatus.downloading,
        ).copyWith(
          progress: progress,
          status: DownloadStatus.downloading,
          message: message,
          updatedAt: DateTime.now(),
        );

    _promoteToActive(current);

    unawaited(
      NotificationService().updateDownloadProgress(
        id: current.notificationId,
        fileName: current.fileName,
        progress: progress,
        status: current.message,
      ),
    );

    _emitSnapshot();
  }

  Future<void> _restoreFromDatabase() async {
    _downloadQueue.clear();
    _activeDownloads.clear();

    final records = await _downloader.database.allRecords();
    for (final record in records) {
      final task = record.task;
      if (task is! DownloadTask) continue;
      if (record.status.isFinalState) continue;

      final metadata = _metadataFromTask(task);
      final BackgroundDownloadItem item = _findOrCreateItem(
        task,
        metadata,
        status: _mapStatus(record.status),
      ).copyWith(progress: record.progress, updatedAt: DateTime.now());

      if (record.status == TaskStatus.enqueued) {
        _replaceOrAddInQueue(item);
      } else {
        _activeDownloads[item.id] = item;
      }
    }
  }

  Map<String, dynamic> _metadataFromTask(Task task) {
    final String meta = task.metaData;
    if (meta.isEmpty) return {};
    try {
      final decoded = jsonDecode(meta);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      debugPrint(
        '⚠️ Impossible de décoder les métadonnées du téléchargement: $e',
      );
    }
    return {};
  }

  Map<String, dynamic> _buildMetadata({
    required String title,
    required String originalUrl,
    required String fileName,
    required String outputDir,
    required String filePath,
    required int notificationId,
    uqload.VideoInfo? videoInfo,
    required bool isUqload,
  }) {
    final map = <String, dynamic>{
      _metadataTitleKey: title,
      _metadataOriginalUrlKey: originalUrl,
      _metadataFileNameKey: fileName,
      _metadataOutputDirKey: outputDir,
      _metadataFilePathKey: filePath,
      _metadataNotificationIdKey: notificationId,
      _metadataIsUqloadKey: isUqload,
      _metadataCreatedAtKey: DateTime.now().millisecondsSinceEpoch,
    };

    if (videoInfo != null) {
      map[_metadataVideoInfoKey] = {
        'title': videoInfo.title,
        'url': videoInfo.url,
        'imageUrl': videoInfo.imageUrl,
        'resolution': videoInfo.resolution,
        'duration': videoInfo.duration,
        'size': videoInfo.size,
        'type': videoInfo.type,
      };
      map[_metadataThumbnailKey] = videoInfo.imageUrl;
      map[_metadataResolutionKey] = videoInfo.resolution;
      map[_metadataDurationKey] = videoInfo.duration;
      map[_metadataSizeKey] = videoInfo.size;
    }

    return map;
  }

  BackgroundDownloadItem _findOrCreateItem(
    DownloadTask task,
    Map<String, dynamic> metadata, {
    required DownloadStatus status,
  }) {
    final existing =
        _activeDownloads[task.taskId] ??
        _downloadQueue.firstWhere(
          (item) => item.id == task.taskId,
          orElse: () => _emptyItemForId(task.taskId),
        );

    if (existing.id == task.taskId) {
      return existing.copyWith(status: status, updatedAt: DateTime.now());
    }

    final String fileName =
        metadata[_metadataFileNameKey] as String? ?? task.filename;
    final String? outputDir = metadata[_metadataOutputDirKey] as String?;
    final String? filePath = metadata[_metadataFilePathKey] as String?;
    final int notificationId =
        metadata[_metadataNotificationIdKey] as int? ??
        NotificationService.generateNotificationId(task.url);
    final int? createdAtMillis = metadata[_metadataCreatedAtKey] as int?;

    return BackgroundDownloadItem(
      id: task.taskId,
      url: metadata[_metadataOriginalUrlKey] as String? ?? task.url,
      title: metadata[_metadataTitleKey] as String? ?? fileName,
      fileName: fileName,
      outputDir: outputDir,
      notificationId: notificationId,
      status: status,
      progress: existing.progress,
      message: existing.message,
      filePath: filePath,
      createdAt: createdAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(createdAtMillis)
          : DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _recordCompletion(
    BackgroundDownloadItem item,
    Map<String, dynamic> metadata,
  ) async {
    final videoInfo = _videoInfoFromMetadata(metadata, item);
    if (item.filePath != null &&
        videoInfo != null &&
        !DownloadManager.instance.isDownloaded(item.url)) {
      await DownloadManager.instance.recordDownload(
        videoInfo: videoInfo,
        filePath: item.filePath!,
        originalUrl: metadata[_metadataOriginalUrlKey] as String? ?? item.url,
      );
    }
  }

  uqload.VideoInfo? _videoInfoFromMetadata(
    Map<String, dynamic> metadata,
    BackgroundDownloadItem item,
  ) {
    final info = metadata[_metadataVideoInfoKey];
    if (info is Map<String, dynamic>) {
      final int size = (info['size'] as num?)?.toInt() ?? 0;
      return uqload.VideoInfo(
        title: info['title'] as String? ?? item.title,
        url: info['url'] as String? ?? item.url,
        imageUrl: info['imageUrl'] as String? ?? '',
        resolution: info['resolution'] as String?,
        duration: info['duration'] as String?,
        size: size,
        type: info['type'] as String? ?? 'video',
      );
    }

    if (metadata[_metadataIsUqloadKey] == true) {
      final int size = (metadata[_metadataSizeKey] as num?)?.toInt() ?? 0;
      return uqload.VideoInfo(
        title: item.title,
        url: item.url,
        imageUrl: metadata[_metadataThumbnailKey] as String? ?? '',
        resolution: metadata[_metadataResolutionKey] as String?,
        duration: metadata[_metadataDurationKey] as String?,
        size: size,
        type: 'video',
      );
    }

    return uqload.VideoInfo(
      title: item.title,
      url: item.url,
      imageUrl: '',
      size: 0,
      type: 'video',
    );
  }

  void _replaceOrAddInQueue(BackgroundDownloadItem item) {
    final index = _downloadQueue.indexWhere((element) => element.id == item.id);
    if (index >= 0) {
      _downloadQueue[index] = item;
    } else {
      _downloadQueue.add(item);
    }
  }

  void _promoteToActive(BackgroundDownloadItem item) {
    _downloadQueue.removeWhere((existing) => existing.id == item.id);
    _activeDownloads[item.id] = item;
  }

  void _emitSnapshot() {
    if (_stateController.isClosed) return;
    _stateController.add(
      BackgroundDownloadSnapshot(
        queuedDownloads: List.unmodifiable(_downloadQueue),
        activeDownloads: Map.unmodifiable(_activeDownloads),
      ),
    );
  }

  BackgroundDownloadItem _emptyItemForId(String id) {
    return BackgroundDownloadItem(
      id: '_empty_$id',
      url: '',
      title: '',
      fileName: '',
      notificationId: 0,
      status: DownloadStatus.queued,
      progress: 0.0,
      createdAt: DateTime.now(),
    );
  }

  DownloadStatus _mapStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.enqueued:
        return DownloadStatus.queued;
      case TaskStatus.running:
      case TaskStatus.waitingToRetry:
        return DownloadStatus.downloading;
      case TaskStatus.paused:
        return DownloadStatus.paused;
      case TaskStatus.complete:
        return DownloadStatus.completed;
      case TaskStatus.failed:
      case TaskStatus.notFound:
        return DownloadStatus.failed;
      case TaskStatus.canceled:
        return DownloadStatus.cancelled;
    }
  }

  String _ensureExtension(String baseName, Uri? uri) {
    if (baseName.contains('.')) {
      return baseName;
    }

    String? extension;
    if (uri != null && uri.pathSegments.isNotEmpty) {
      final segment = uri.pathSegments.last;
      final match = RegExp(r'\.[A-Za-z0-9]{2,5}').firstMatch(segment);
      extension = match?.group(0);
    }

    extension ??= '.mp4';
    return '$baseName$extension';
  }

  String _joinPath(String directory, String fileName) {
    if (directory.endsWith('/')) return '$directory$fileName';
    return '$directory/$fileName';
  }

  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }
}
