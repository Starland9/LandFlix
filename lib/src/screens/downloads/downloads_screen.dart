import 'dart:async';
import 'dart:developer' as dev;

import 'package:auto_route/annotations.dart';
import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/logic/models/download_item.dart';
import 'package:french_stream_downloader/src/logic/services/download_manager.dart';
import 'package:french_stream_downloader/src/logic/services/download_stream_service.dart';
import 'package:french_stream_downloader/src/logic/services/uqload_download_service.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/active_download_card.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/download_card.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/downloads_header.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/empty_state.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/loading_state.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/section_header.dart';
import 'package:uqload_downloader_dart/uqload_downloader_dart.dart';

@RoutePage()
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen>
    with SingleTickerProviderStateMixin {
  late final DownloadManager _downloadManager;
  late final StreamSubscription<bd.TaskUpdate> _downloadSubscription;
  late final AnimationController _emptyAnimationController;
  late final Animation<double> _emptyFadeAnimation;

  final Map<String, _ActiveDownloadInfo> _activeDownloads = {};
  final Map<String, VideoInfo> _videoInfoCache = {};
  final Map<String, Future<VideoInfo?>> _videoInfoRequests = {};

  bool _isLoading = true;
  bool _isEmpty = false;

  @override
  void initState() {
    super.initState();
    _downloadManager = DownloadManager.instance;

    _emptyAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _emptyFadeAnimation = CurvedAnimation(
      parent: _emptyAnimationController,
      curve: Curves.easeInOut,
    );

    _downloadManager.downloadsNotifier.addListener(_updateEmptyState);
    _downloadSubscription = DownloadStreamService.instance.updates.listen(
      _handleTaskUpdate,
    );

    _loadInitialData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateEmptyState());
  }

  @override
  void dispose() {
    _downloadManager.downloadsNotifier.removeListener(_updateEmptyState);
    _downloadSubscription.cancel();
    _emptyAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    await _downloadManager.refreshFileStatus();
    await _syncActiveDownloads();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    _updateEmptyState();
  }

  Future<void> _syncActiveDownloads() async {
    try {
      final tasks = await bd.FileDownloader().allTasks();
      if (!mounted) return;

      final Map<String, _ActiveDownloadInfo> updated = {};

      for (final task in tasks) {
        if (task is! bd.DownloadTask) continue;
        final downloadTask = task;
        final metaData = downloadTask.metaData.trim();
        final url = metaData.isNotEmpty ? metaData : downloadTask.url;
        if (url.isEmpty) continue;

        final existing = _activeDownloads[url];
        final info = _ActiveDownloadInfo(
          url: url,
          title: existing?.title ?? _titleFromTask(downloadTask),
          progress: existing?.progress ?? 0,
          status: existing?.status ?? bd.TaskStatus.enqueued,
          taskId: downloadTask.taskId,
          videoInfo: existing?.videoInfo,
          task: downloadTask,
        );

        updated[url] = info;
        if (existing?.videoInfo == null) {
          _ensureVideoInfo(url);
        }
      }

      setState(() {
        _activeDownloads
          ..clear()
          ..addAll(updated);
      });
    } catch (e, stack) {
      dev.log(
        'Erreur lors de la synchronisation des tâches actives',
        error: e,
        stackTrace: stack,
      );
    }
  }

  void _handleTaskUpdate(bd.TaskUpdate update) {
    final task = update.task;
    if (task is! bd.DownloadTask) return;
    final downloadTask = task;

    final metaData = downloadTask.metaData.trim();
    final url = metaData.isNotEmpty ? metaData : downloadTask.url;

    if (url.isEmpty) return;

    if (update is bd.TaskProgressUpdate) {
      _upsertActiveDownload(
        url: url,
        task: downloadTask,
        status: bd.TaskStatus.running,
        progress: update.progress,
      );
    } else if (update is bd.TaskStatusUpdate) {
      _upsertActiveDownload(
        url: url,
        task: downloadTask,
        status: update.status,
      );

      switch (update.status) {
        case bd.TaskStatus.complete:
          _onTaskCompleted(downloadTask, url);
          break;
        case bd.TaskStatus.failed:
        case bd.TaskStatus.canceled:
        case bd.TaskStatus.notFound:
          _removeActiveDownload(url);
          break;
        default:
          break;
      }
    }
  }

  void _upsertActiveDownload({
    required String url,
    required bd.DownloadTask task,
    bd.TaskStatus? status,
    double? progress,
  }) {
    final existing = _activeDownloads[url];
    final normalizedProgress = (progress ?? existing?.progress ?? 0).clamp(
      0.0,
      1.0,
    );

    setState(() {
      _activeDownloads[url] =
          (existing ??
                  _ActiveDownloadInfo(
                    url: url,
                    title: _titleFromTask(task),
                    progress: 0,
                    status: bd.TaskStatus.enqueued,
                    taskId: task.taskId,
                    videoInfo: null,
                    task: task,
                  ))
              .copyWith(
                progress: normalizedProgress,
                status: status ?? existing?.status,
                taskId: task.taskId,
                task: task,
              );
    });

    if (existing?.videoInfo == null) {
      _ensureVideoInfo(url);
    }

    _updateEmptyState();
  }

  void _removeActiveDownload(String url) {
    if (!_activeDownloads.containsKey(url)) {
      _updateEmptyState();
      return;
    }

    if (!mounted) return;
    setState(() {
      _activeDownloads.remove(url);
    });

    _updateEmptyState();
  }

  Future<void> _onTaskCompleted(bd.DownloadTask task, String url) async {
    final entry = _activeDownloads[url];

    VideoInfo? videoInfo = entry?.videoInfo;
    videoInfo ??= await _ensureVideoInfo(url);

    final filePath = _resolveFilePath(task);

    if (videoInfo == null || filePath == null) {
      dev.log(
        'Impossible d’enregistrer le téléchargement : info manquante',
        error: {'url': url, 'filePath': filePath},
      );
      _removeActiveDownload(url);
      return;
    }

    try {
      await _downloadManager.recordDownload(
        videoInfo: videoInfo,
        filePath: filePath,
        originalUrl: url,
      );
    } catch (e, stack) {
      dev.log(
        'Erreur lors de l’enregistrement du téléchargement',
        error: e,
        stackTrace: stack,
      );
    }

    _removeActiveDownload(url);
  }

  Future<VideoInfo?> _ensureVideoInfo(String url) {
    if (_videoInfoCache.containsKey(url)) {
      return Future.value(_videoInfoCache[url]);
    }

    if (_videoInfoRequests.containsKey(url)) {
      return _videoInfoRequests[url]!;
    }

    final future = _fetchVideoInfo(url);
    _videoInfoRequests[url] = future;

    future
        .then((info) {
          _videoInfoRequests.remove(url);
          if (info == null) return;
          _videoInfoCache[url] = info;
          if (!mounted) return;

          final entry = _activeDownloads[url];
          if (entry != null) {
            setState(() {
              _activeDownloads[url] = entry.copyWith(
                title: info.title,
                videoInfo: info,
              );
            });
          }
        })
        .catchError((error, stack) {
          dev.log(
            'Impossible de récupérer les informations de la vidéo',
            error: error,
            stackTrace: stack,
          );
        });

    return future;
  }

  Future<VideoInfo?> _fetchVideoInfo(String url) async {
    try {
      return await UQLoadDownloadService.getVideoInfo(url);
    } catch (e, stack) {
      dev.log(
        'Erreur lors de la récupération des infos vidéo',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  String _titleFromTask(bd.DownloadTask task) {
    String filename = task.filename;
    if (filename.isEmpty) {
      filename = 'Téléchargement';
    }

    final withoutExtension = filename.replaceAll(RegExp(r'\.[^.]+$'), '');
    final formatted = withoutExtension.replaceAll('_', ' ').trim();
    return formatted.isEmpty ? 'Téléchargement' : formatted;
  }

  String? _resolveFilePath(bd.DownloadTask task) {
    final directory = task.directory;
    final filename = task.filename;

    if (directory.isEmpty || filename.isEmpty) {
      return null;
    }

    final normalizedDirectory = directory.endsWith('/')
        ? directory.substring(0, directory.length - 1)
        : directory;

    return '$normalizedDirectory/$filename';
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      _downloadManager.refreshFileStatus(),
      _syncActiveDownloads(),
    ]);
  }

  Future<void> _cleanupDeletedDownloads() async {
    await _downloadManager.cleanupDeletedDownloads();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Téléchargements supprimés nettoyés.')),
    );
    _updateEmptyState();
  }

  Future<void> _openDownload(DownloadItem download) async {
    if (!download.fileExists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fichier introuvable sur le stockage.')),
      );
      return;
    }

    try {
      await bd.FileDownloader().openFile(filePath: download.filePath);
    } catch (e, stack) {
      dev.log("Impossible d'ouvrir le fichier", error: e, stackTrace: stack);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir ce fichier.")),
      );
    }
  }

  Future<void> _deleteDownload(DownloadItem download) async {
    await _downloadManager.removeDownload(download.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          download.status == DownloadStatus.deleted
              ? 'Entrée supprimée.'
              : 'Téléchargement supprimé.',
        ),
      ),
    );
    _updateEmptyState();
  }

  Future<void> _togglePauseResume(_ActiveDownloadInfo info) async {
    if (info.status != bd.TaskStatus.running &&
        info.status != bd.TaskStatus.paused) {
      return;
    }

    final downloader = bd.FileDownloader();

    try {
      if (info.status == bd.TaskStatus.paused) {
        await downloader.resume(info.task);
        if (!mounted) return;
        _upsertActiveDownload(
          url: info.url,
          task: info.task,
          status: bd.TaskStatus.running,
          progress: info.progress,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Téléchargement repris.')));
      } else {
        await downloader.pause(info.task);
        if (!mounted) return;
        _upsertActiveDownload(
          url: info.url,
          task: info.task,
          status: bd.TaskStatus.paused,
          progress: info.progress,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Téléchargement mis en pause.')),
        );
      }
    } catch (e, stack) {
      dev.log(
        'Erreur pause/reprise du téléchargement',
        error: e,
        stackTrace: stack,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action indisponible pour ce téléchargement.'),
        ),
      );
    }
  }

  Future<void> _cancelActiveDownload(String url) async {
    await UQLoadDownloadService.stopBackgroundDownload(url);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Téléchargement annulé.')));
    _removeActiveDownload(url);
  }

  void _updateEmptyState() {
    final downloads = _downloadManager.downloadsNotifier.value;
    final shouldBeEmpty =
        !_isLoading && downloads.isEmpty && _activeDownloads.isEmpty;

    if (shouldBeEmpty == _isEmpty) {
      if (shouldBeEmpty) {
        _emptyAnimationController.forward();
      } else {
        _emptyAnimationController.reverse();
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      _isEmpty = shouldBeEmpty;
    });

    if (_isEmpty) {
      _emptyAnimationController.forward();
    } else {
      _emptyAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<DownloadItem>>(
        valueListenable: _downloadManager.downloadsNotifier,
        builder: (context, downloads, child) {
          final activeDownloads = _activeDownloads.values.toList();
          final completedDownloads = downloads
              .where((item) => item.status == DownloadStatus.completed)
              .toList();
          final deletedDownloads = downloads
              .where((item) => item.status == DownloadStatus.deleted)
              .toList();

          final totalBytes = completedDownloads.fold<int>(
            0,
            (previousValue, element) => previousValue + element.fileSize,
          );
          final totalSize = totalBytes > 0
              ? UQLoadDownloadService.formatFileSize(totalBytes)
              : '0 B';

          if (_isLoading) {
            return const LoadingState();
          }

          if (_isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  DownloadsHeader(
                    isLoading: false,
                    activeDownloadsCount: activeDownloads.length,
                    completedDownloadsCount: completedDownloads.length,
                    totalSize: totalSize,
                    onCleanUp: _cleanupDeletedDownloads,
                    canCleanUp: deletedDownloads.isNotEmpty,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: EmptyState(fadeAnimation: _emptyFadeAnimation),
                  ),
                ],
              ),
            );
          }

          final List<Widget> children = [
            DownloadsHeader(
              isLoading: false,
              activeDownloadsCount: activeDownloads.length,
              completedDownloadsCount: completedDownloads.length,
              totalSize: totalSize,
              onCleanUp: _cleanupDeletedDownloads,
              canCleanUp: deletedDownloads.isNotEmpty,
            ),
          ];

          if (activeDownloads.isNotEmpty) {
            children
              ..add(
                SectionHeader(
                  title: 'Téléchargements en cours',
                  count: activeDownloads.length,
                ),
              )
              ..addAll(
                activeDownloads.map(
                  (active) => ActiveDownloadCard(
                    url: active.url,
                    status: active.status,
                    progress: active.progress,
                    title: active.title,
                    onCancel: () => _cancelActiveDownload(active.url),
                    onTogglePause: () => _togglePauseResume(active),
                  ),
                ),
              );
          }

          if (completedDownloads.isNotEmpty) {
            children
              ..add(
                SectionHeader(
                  title: 'Téléchargements terminés',
                  count: completedDownloads.length,
                ),
              )
              ..addAll(
                completedDownloads.map(
                  (download) => DownloadCard(
                    download: download,
                    onOpen: () => _openDownload(download),
                    onDelete: () => _deleteDownload(download),
                  ),
                ),
              );
          }

          if (deletedDownloads.isNotEmpty) {
            children
              ..add(
                SectionHeader(
                  title: 'Téléchargements supprimés',
                  count: deletedDownloads.length,
                ),
              )
              ..addAll(
                deletedDownloads.map(
                  (download) => DownloadCard(
                    download: download,
                    onOpen: () => _openDownload(download),
                    onDelete: () => _deleteDownload(download),
                  ),
                ),
              );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: children,
            ),
          );
        },
      ),
    );
  }
}

class _ActiveDownloadInfo {
  final String url;
  final String title;
  final double progress;
  final bd.TaskStatus status;
  final String? taskId;
  final VideoInfo? videoInfo;
  final bd.DownloadTask task;

  const _ActiveDownloadInfo({
    required this.url,
    required this.title,
    required this.progress,
    required this.status,
    required this.taskId,
    required this.videoInfo,
    required this.task,
  });

  _ActiveDownloadInfo copyWith({
    String? url,
    String? title,
    double? progress,
    bd.TaskStatus? status,
    String? taskId,
    VideoInfo? videoInfo,
    bd.DownloadTask? task,
  }) {
    return _ActiveDownloadInfo(
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
