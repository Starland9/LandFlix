import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/logic/models/download_item.dart';
import 'package:french_stream_downloader/src/logic/services/download_manager.dart';
import 'package:french_stream_downloader/src/logic/services/download_stream_service.dart';
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
    _loadDownloads();
    _setupDownloadListener();
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

      final metaData = update.task.metaData;
      if (metaData.isEmpty) return;

      setState(() {
        if (update is bd.TaskStatusUpdate) {
          final status = update.status;
          if (status == bd.TaskStatus.complete ||
              status == bd.TaskStatus.failed ||
              status == bd.TaskStatus.canceled ||
              status == bd.TaskStatus.notFound) {
            _activeDownloads.remove(metaData);
            _downloadProgress.remove(metaData);
            if (status == bd.TaskStatus.complete) {
              _loadDownloads(); // Recharger pour afficher le nouveau téléchargement terminé
            }
          } else {
            _activeDownloads[metaData] = status;
          }
        } else if (update is bd.TaskProgressUpdate) {
          _downloadProgress[metaData] = update.progress;
        }
      });
    });
  }

  Future<void> _loadDownloads() async {
    await DownloadManager.instance.refreshFileStatus();
    setState(() {
      _downloads = DownloadManager.instance.downloads;
      _isLoading = false;
    });
    _fadeController.forward();
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
      return;
    }

    try {
      final uri = Uri.file(download.filePath);
      await launchUrl(uri);
    } catch (e) {
      if (mounted) {
        ModernToast.show(
          context: context,
          message: "Impossible d'ouvrir le fichier",
          type: ToastType.error,
          title: "❌ Erreur",
        );
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
              // Header moderne
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => {},
                        icon: const Icon(
                          Icons.download_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mes Téléchargements",
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          if (!_isLoading) ...[
                            const SizedBox(height: 4),
                            Text(
                              "${_activeDownloads.length + _downloads.length} téléchargement${(_activeDownloads.length + _downloads.length) > 1 ? 's' : ''} • ${DownloadManager.instance.totalSize > 0 ? _formatTotalSize() : '0 B'}",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_downloads.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _showCleanupDialog,
                          icon: const Icon(
                            Icons.cleaning_services_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Contenu
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : (_downloads.isEmpty && _activeDownloads.isEmpty)
                    ? _buildEmptyState()
                    : _buildDownloadsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: AppColors.primaryPurple.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.download_outlined,
                  size: 60,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Aucun téléchargement",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Vos téléchargements apparaîtront ici une fois terminés.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
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
          // Section des téléchargements actifs
          if (_activeDownloads.isNotEmpty) ...[
            _buildSectionHeader("En cours", _activeDownloads.length),
            ..._activeDownloads.entries.map((entry) {
              return _buildActiveDownloadCard(
                entry.key,
                entry.value,
                _downloadProgress[entry.key] ?? 0.0,
              );
            }),
            const SizedBox(height: 16),
          ],

          // Section des téléchargements terminés
          if (_downloads.isNotEmpty) ...[
            _buildSectionHeader("Terminés", _downloads.length),
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
                child: _buildDownloadCard(download),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDownloadCard(
    String url,
    bd.TaskStatus status,
    double progress,
  ) {
    final statusText = _getStatusText(status);
    final statusColor = _getStatusColor(status);
    final percentage = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    status == bd.TaskStatus.paused
                        ? Icons.pause_circle_filled_rounded
                        : Icons.downloading_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Téléchargement en cours...",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$percentage%",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () => _cancelActiveDownload(url),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.darkSurfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(bd.TaskStatus status) {
    switch (status) {
      case bd.TaskStatus.enqueued:
        return "En file d'attente";
      case bd.TaskStatus.running:
        return "Téléchargement";
      case bd.TaskStatus.paused:
        return "En pause";
      case bd.TaskStatus.complete:
        return "Terminé";
      case bd.TaskStatus.failed:
        return "Échec";
      case bd.TaskStatus.canceled:
        return "Annulé";
      case bd.TaskStatus.notFound:
        return "Non trouvé";
      default:
        return "Inconnu";
    }
  }

  Color _getStatusColor(bd.TaskStatus status) {
    switch (status) {
      case bd.TaskStatus.enqueued:
        return AppColors.accentTeal;
      case bd.TaskStatus.running:
        return AppColors.primaryPurple;
      case bd.TaskStatus.paused:
        return Colors.orange;
      case bd.TaskStatus.complete:
        return Colors.green;
      case bd.TaskStatus.failed:
      case bd.TaskStatus.canceled:
      case bd.TaskStatus.notFound:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
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
      // Trouver et annuler la tâche
      final tasks = await bd.FileDownloader().database.allRecords();
      for (final record in tasks) {
        if (record.task.metaData == url) {
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

  Widget _buildDownloadCard(DownloadItem download) {
    final isDeleted = download.status == DownloadStatus.deleted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isDeleted
            ? LinearGradient(
                colors: [
                  AppColors.darkSurface.withValues(alpha: 0.5),
                  AppColors.darkSurfaceVariant.withValues(alpha: 0.3),
                ],
              )
            : AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDeleted
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.primaryPurple.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isDeleted ? null : () => _openFile(download),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Thumbnail ou icône
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.darkSurfaceVariant,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: download.thumbnailUrl.isNotEmpty && !isDeleted
                        ? Image.network(
                            download.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFileIcon(download),
                          )
                        : _buildFileIcon(download),
                  ),
                ),

                const SizedBox(width: 16),

                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDeleted
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          // Badge de taille
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.accentTeal.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              download.formattedSize,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.accentTeal,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Badge de date
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primaryPurple.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              download.formattedDate,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.primaryPurple,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                            ),
                          ),

                          if (isDeleted) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                "Supprimé",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (download.resolution != "Unknown" ||
                          download.duration != "Unknown") ...[
                        const SizedBox(height: 6),
                        Text(
                          "${download.resolution} • ${download.duration}",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Bouton d'action
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () => _deleteDownload(download),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon(DownloadItem download) {
    return Container(
      decoration: BoxDecoration(
        gradient: download.status == DownloadStatus.deleted
            ? LinearGradient(
                colors: [
                  AppColors.error.withValues(alpha: 0.3),
                  AppColors.error.withValues(alpha: 0.1),
                ],
              )
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        download.status == DownloadStatus.deleted
            ? Icons.delete_outline_rounded
            : Icons.play_circle_fill_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  String _formatTotalSize() {
    final totalBytes = DownloadManager.instance.totalSize;
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
