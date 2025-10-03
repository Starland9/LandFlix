import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/logic/models/download_item.dart';
import 'package:french_stream_downloader/src/logic/services/download_manager.dart';
import 'package:french_stream_downloader/src/logic/services/download_stream_service.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/active_download_card.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/download_card.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/downloads_header.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/empty_state.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/loading_state.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/section_header.dart';
import 'package:french_stream_downloader/src/shared/components/modern_toast.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<DownloadItem> _downloads = [];
  final Map<String, bd.TaskStatus> _activeDownloads = {};
  final Map<String, double> _downloadProgress = {};
  final Map<String, DownloadItem> _activeDownloadItems = {};
  bool _isLoading = true;

  late StreamSubscription<bd.TaskUpdate> _downloadSubscription;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _initializeDownloads();
  }

  Future<void> _initializeDownloads() async {
    await _loadDownloads();
    await _loadActiveDownloads();
    _setupDownloadListener();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _downloadSubscription.cancel();
    super.dispose();
  }

  void _setupDownloadListener() {
    _downloadSubscription = DownloadStreamService.instance.updates.listen((
      update,
    ) {
      if (!mounted) return;

      if (update.task.metaData.isEmpty) return;

      try {
        final item = DownloadItem.fromJson(jsonDecode(update.task.metaData));
        final url = item.originalUrl;

        setState(() {
          if (update is bd.TaskStatusUpdate) {
            final status = update.status;
            if (status == bd.TaskStatus.complete ||
                status == bd.TaskStatus.failed ||
                status == bd.TaskStatus.canceled ||
                status == bd.TaskStatus.notFound) {
              _activeDownloads.remove(url);
              _downloadProgress.remove(url);
              _activeDownloadItems.remove(url);
              if (status == bd.TaskStatus.complete) {
                _loadDownloads(); // Recharger pour afficher le nouveau téléchargement terminé
              }
            } else {
              _activeDownloads[url] = status;
              _activeDownloadItems[url] = item;
            }
          } else if (update is bd.TaskProgressUpdate) {
            _downloadProgress[url] = update.progress;
            _activeDownloadItems[url] = item;
          }
        });
      } catch (e) {
        debugPrint("Error processing download update: $e");
      }
    });
  }

  Future<void> _loadDownloads() async {
    await DownloadManager.instance.refreshFileStatus();
    if (mounted) {
      setState(() {
        _downloads = DownloadManager.instance.downloads;
      });
    }
  }

  Future<void> _loadActiveDownloads() async {
    try {
      final records = await bd.FileDownloader().database.allRecords();
      if (!mounted) return;

      final activeTasks = <String, bd.TaskStatus>{};
      final activeProgress = <String, double>{};
      final activeItems = <String, DownloadItem>{};

      for (final record in records) {
        final task = record.task;
        if (task.metaData.isNotEmpty) {
          if (record.status != bd.TaskStatus.complete &&
              record.status != bd.TaskStatus.failed &&
              record.status != bd.TaskStatus.canceled &&
              record.status != bd.TaskStatus.notFound) {
            try {
              final item = DownloadItem.fromJson(jsonDecode(task.metaData));
              final url = item.originalUrl;
              activeTasks[url] = record.status;
              activeProgress[url] = record.progress;
              activeItems[url] = item;
            } catch (e) {
              debugPrint("Error parsing DownloadItem from record metadata: $e");
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _activeDownloads.clear();
          _activeDownloads.addAll(activeTasks);
          _downloadProgress.clear();
          _downloadProgress.addAll(activeProgress);
          _activeDownloadItems.clear();
          _activeDownloadItems.addAll(activeItems);
        });
      }
    } catch (e) {
      debugPrint('Error loading active downloads: $e');
    }
  }

  String _getDownloadTitle(String url) {
    final item = _activeDownloadItems[url];
    if (item != null && item.title.isNotEmpty) {
      return item.title;
    }
    return "Téléchargement...";
  }

  Future<void> _deleteDownload(DownloadItem download) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          "Supprimer le téléchargement",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          "Voulez-vous supprimer '${download.title}' ?\nLe fichier sera supprimé définitivement.",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DownloadManager.instance.removeDownload(download.id);
      await _loadDownloads();

      if (mounted) {
        ModernToast.show(
          context: context,
          message: "Téléchargement supprimé",
          type: ToastType.info,
          title: "🗑️ Supprimé",
        );
      }
    }
  }

  Future<void> _openFile(DownloadItem download) async {
    final file = File(download.filePath);

    if (!file.existsSync()) {
      ModernToast.show(
        context: context,
        message: "Le fichier n'existe plus",
        type: ToastType.error,
        title: "❌ Erreur",
      );
      await _loadDownloads();
      return;
    }

    try {
      final uri = Uri.file(download.filePath);
      if (!await launchUrl(uri)) {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      if (mounted) {
        ModernToast.show(
          context: context,
          message:
              "Impossible d'ouvrir le fichier. Aucune application n'est disponible.",
          type: ToastType.error,
          title: "❌ Erreur",
        );
      }
    }
  }

  Future<void> _cancelActiveDownload(String url) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          "Annuler le téléchargement",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          "Voulez-vous vraiment annuler ce téléchargement ?",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Non"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text("Annuler"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final item = _activeDownloadItems[url];
      if (item != null) {
        final tasks = await bd.FileDownloader().database.allRecords();
        for (final record in tasks) {
          if (record.task.metaData.contains(item.id)) {
            await bd.FileDownloader().cancelTaskWithId(record.taskId);
            if (mounted) {
              ModernToast.show(
                context: context,
                message: "Téléchargement annulé",
                type: ToastType.info,
                title: "🚫 Annulé",
              );
            }
            break;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              Color(0xFF1A0A2E),
              AppColors.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              DownloadsHeader(
                isLoading: _isLoading,
                activeDownloadsCount: _activeDownloads.length,
                completedDownloadsCount: _downloads.length,
                totalSize: _formatTotalSize(),
                onCleanUp: _showCleanupDialog,
                canCleanUp: _downloads.isNotEmpty,
              ),
              Expanded(
                child: _isLoading
                    ? const LoadingState()
                    : (_downloads.isEmpty && _activeDownloads.isEmpty)
                    ? EmptyState(fadeAnimation: _fadeAnimation)
                    : _buildDownloadsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          if (_activeDownloads.isNotEmpty) ...[
            SectionHeader(title: "En cours", count: _activeDownloads.length),
            ..._activeDownloads.entries.map((entry) {
              return ActiveDownloadCard(
                url: entry.key,
                status: entry.value,
                progress: _downloadProgress[entry.key] ?? 0.0,
                title: _getDownloadTitle(entry.key),
                onCancel: () => _cancelActiveDownload(entry.key),
              );
            }),
            const SizedBox(height: 16),
          ],
          if (_downloads.isNotEmpty) ...[
            SectionHeader(title: "Terminés", count: _downloads.length),
            ..._downloads.asMap().entries.map((entry) {
              final index = entry.key;
              final download = entry.value;
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: Offset(0, 0.3 + (index * 0.1)),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _fadeController,
                        curve: Interval(
                          (index * 0.1).clamp(0.0, 0.8),
                          1.0,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                child: DownloadCard(
                  download: download,
                  onOpen: () => _openFile(download),
                  onDelete: () => _deleteDownload(download),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _formatTotalSize() {
    final totalBytes = DownloadManager.instance.totalSize;
    if (totalBytes <= 0) return '0 B';
    if (totalBytes >= 1024 * 1024 * 1024) {
      return "${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
    } else if (totalBytes >= 1024 * 1024) {
      return "${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    } else if (totalBytes >= 1024) {
      return "${(totalBytes / 1024).toStringAsFixed(1)} KB";
    }
    return "$totalBytes B";
  }

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          "Nettoyer les téléchargements",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          "Supprimer définitivement tous les téléchargements marqués comme supprimés ?",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await DownloadManager.instance.cleanupDeletedDownloads();
              await _loadDownloads();

              if (context.mounted) {
                ModernToast.show(
                  context: context,
                  message: "Nettoyage terminé",
                  type: ToastType.success,
                  title: "✨ Terminé",
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
            child: const Text("Nettoyer"),
          ),
        ],
      ),
    );
  }
}
