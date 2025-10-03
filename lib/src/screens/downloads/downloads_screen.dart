import 'dart:async';
import 'dart:developer' as dev;

import 'package:auto_route/annotations.dart';
import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/logic/models/active_download_info.dart';
import 'package:french_stream_downloader/src/logic/models/download_item.dart';
import 'package:french_stream_downloader/src/logic/services/download_manager.dart';
import 'package:french_stream_downloader/src/logic/services/download_stream_service.dart';
import 'package:french_stream_downloader/src/logic/services/uqload_download_service.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/active_downloads_list.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/download_items_list.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/downloads_header.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/downloads_overview_view.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/loading_state.dart';
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
  late final TabController _tabController;

  final Map<String, ActiveDownloadInfo> _activeDownloads = {};
  final Map<String, VideoInfo> _videoInfoCache = {};
  final Map<String, Future<VideoInfo?>> _videoInfoRequests = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadManager = DownloadManager.instance;
    _tabController = TabController(length: 4, vsync: this);

    _downloadSubscription = DownloadStreamService.instance.updates.listen(
      _handleTaskUpdate,
    );

    _loadInitialData();
  }

  @override
  void dispose() {
    _downloadSubscription.cancel();
    _tabController.dispose();
    super.dispose();
  }

  /// Charge l'état initial du gestionnaire et synchronise les tâches actives.
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
  }

  /// Synchronise les tâches en cours depuis le plugin natif.
  Future<void> _syncActiveDownloads() async {
    try {
      final tasks = await bd.FileDownloader().allTasks();
      if (!mounted) return;

      final Map<String, ActiveDownloadInfo> updated = {};

      for (final task in tasks) {
        if (task is! bd.DownloadTask) continue;
        final downloadTask = task;
        final metaData = downloadTask.metaData.trim();
        final url = metaData.isNotEmpty ? metaData : downloadTask.url;
        if (url.isEmpty) continue;

        final existing = _activeDownloads[url];
        final info = ActiveDownloadInfo(
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

  /// Gère les mises à jour de tâches remontées par le service d'arrière-plan.
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

  /// Insère ou met à jour un téléchargement actif suivi par l'interface.
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
      final next =
          (existing ??
                  ActiveDownloadInfo(
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
                status: status ?? existing?.status ?? bd.TaskStatus.enqueued,
                taskId: task.taskId,
                task: task,
              );

      _activeDownloads[url] = next;
    });

    if (existing?.videoInfo == null) {
      _ensureVideoInfo(url);
    }
  }

  /// Supprime un téléchargement actif de la carte locale.
  void _removeActiveDownload(String url) {
    if (!_activeDownloads.containsKey(url)) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _activeDownloads.remove(url);
    });
  }

  /// Enregistre un téléchargement complété dans la base puis nettoie l'état actif.
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

  /// Garantit que les métadonnées vidéo sont disponibles en mémoire.
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

  /// Récupère les métadonnées vidéo auprès du service UQLoad.
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

  /// Formate un titre lisible à partir du nom de fichier de la tâche.
  String _titleFromTask(bd.DownloadTask task) {
    String filename = task.filename;
    if (filename.isEmpty) {
      filename = 'Téléchargement';
    }

    final withoutExtension = filename.replaceAll(RegExp(r'\.[^.]+$'), '');
    final formatted = withoutExtension.replaceAll('_', ' ').trim();
    return formatted.isEmpty ? 'Téléchargement' : formatted;
  }

  /// Construit le chemin complet du fichier téléchargé.
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

  /// Rafraîchit simultanément la liste locale et les tâches actives.
  Future<void> _handleRefresh() async {
    await Future.wait([
      _downloadManager.refreshFileStatus(),
      _syncActiveDownloads(),
    ]);
  }

  /// Supprime définitivement les enregistrements marqués comme supprimés.
  Future<void> _cleanupDeletedDownloads() async {
    await _downloadManager.cleanupDeletedDownloads();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Téléchargements supprimés nettoyés.')),
    );
  }

  /// Tente d'ouvrir un fichier téléchargé via le gestionnaire natif.
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

  /// Supprime un téléchargement persisté puis affiche une notification.
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
  }

  /// Met en pause ou reprend un téléchargement actif si supporté.
  Future<void> _togglePauseResume(ActiveDownloadInfo info) async {
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

  /// Annule un téléchargement actif côté natif et nettoie l'état local.
  Future<void> _cancelActiveDownload(String url) async {
    await UQLoadDownloadService.stopBackgroundDownload(url);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Téléchargement annulé.')));
    _removeActiveDownload(url);
  }

  /// Construit un onglet enveloppé dans un `RefreshIndicator`.
  Widget _buildRefreshableTab(Widget child) {
    return RefreshIndicator(onRefresh: _handleRefresh, child: child);
  }

  /// Retourne un poids de tri pour un statut de tâche donné.
  int _statusPriority(bd.TaskStatus status) {
    switch (status) {
      case bd.TaskStatus.running:
        return 0;
      case bd.TaskStatus.paused:
        return 1;
      case bd.TaskStatus.enqueued:
        return 2;
      default:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<List<DownloadItem>>(
          valueListenable: _downloadManager.downloadsNotifier,
          builder: (context, downloads, _) {
            final activeDownloads = _activeDownloads.values.toList()
              ..sort((a, b) {
                final priorityComparison = _statusPriority(
                  a.status,
                ).compareTo(_statusPriority(b.status));
                if (priorityComparison != 0) {
                  return priorityComparison;
                }
                return a.title.toLowerCase().compareTo(b.title.toLowerCase());
              });

            final completedDownloads =
                downloads
                    .where((item) => item.status == DownloadStatus.completed)
                    .toList()
                  ..sort((a, b) => b.downloadDate.compareTo(a.downloadDate));

            final deletedDownloads =
                downloads
                    .where((item) => item.status == DownloadStatus.deleted)
                    .toList()
                  ..sort((a, b) => b.downloadDate.compareTo(a.downloadDate));

            final totalBytes = completedDownloads.fold<int>(
              0,
              (previousValue, element) => previousValue + element.fileSize,
            );
            final totalSize = totalBytes > 0
                ? UQLoadDownloadService.formatFileSize(totalBytes)
                : '0 B';

            final header = DownloadsHeader(
              isLoading: _isLoading,
              activeDownloadsCount: activeDownloads.length,
              completedDownloadsCount: completedDownloads.length,
              totalSize: totalSize,
              onCleanUp: _cleanupDeletedDownloads,
              canCleanUp: deletedDownloads.isNotEmpty,
            );

            if (_isLoading) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const Expanded(child: LoadingState()),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildTabBar(context),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRefreshableTab(
                        DownloadsOverviewView(
                          activeDownloads: activeDownloads,
                          completedDownloads: completedDownloads,
                          deletedDownloads: deletedDownloads,
                          onCancelActive: (info) =>
                              unawaited(_cancelActiveDownload(info.url)),
                          onTogglePause: (info) =>
                              unawaited(_togglePauseResume(info)),
                          onOpenDownload: (download) =>
                              unawaited(_openDownload(download)),
                          onDeleteDownload: (download) =>
                              unawaited(_deleteDownload(download)),
                        ),
                      ),
                      _buildRefreshableTab(
                        ActiveDownloadsList(
                          downloads: activeDownloads,
                          onCancel: (info) =>
                              unawaited(_cancelActiveDownload(info.url)),
                          onTogglePause: (info) =>
                              unawaited(_togglePauseResume(info)),
                        ),
                      ),
                      _buildRefreshableTab(
                        DownloadItemsList(
                          downloads: completedDownloads,
                          onOpen: (download) =>
                              unawaited(_openDownload(download)),
                          onDelete: (download) =>
                              unawaited(_deleteDownload(download)),
                          emptyLabel:
                              'Aucun téléchargement terminé pour le moment.',
                          emptyIcon: Icons.save_alt_rounded,
                        ),
                      ),
                      _buildRefreshableTab(
                        DownloadItemsList(
                          downloads: deletedDownloads,
                          onOpen: (download) =>
                              unawaited(_openDownload(download)),
                          onDelete: (download) =>
                              unawaited(_deleteDownload(download)),
                          emptyLabel:
                              'Aucun téléchargement supprimé à afficher.',
                          emptyIcon: Icons.delete_sweep_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  TabBar _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      indicator: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
      labelStyle: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      splashBorderRadius: BorderRadius.circular(12),
      tabs: const [
        Tab(text: 'Vue d’ensemble'),
        Tab(text: 'Actifs'),
        Tab(text: 'Terminés'),
        Tab(text: 'Supprimés'),
      ],
    );
  }
}
