import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:french_stream_downloader/src/core/models/download_models.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/logic/cubits/background_download/background_download_cubit.dart';
import 'package:french_stream_downloader/src/shared/components/modern_toast.dart';

@RoutePage()
class BackgroundDownloadsScreen extends StatefulWidget {
  const BackgroundDownloadsScreen({super.key});

  @override
  State<BackgroundDownloadsScreen> createState() => _BackgroundDownloadsScreenState();
}

class _BackgroundDownloadsScreenState extends State<BackgroundDownloadsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
    _fadeController.forward();

    // Initialiser le cubit si nécessaire
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BackgroundDownloadCubit>().refreshDownloads();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Téléchargements en arrière-plan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<BackgroundDownloadCubit>().refreshDownloads();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: BlocConsumer<BackgroundDownloadCubit, BackgroundDownloadState>(
          listener: (context, state) {
            if (state is BackgroundDownloadError) {
              ModernToast.show(
                context: context,
                message: state.message,
                type: ToastType.error,
                title: 'Erreur',
              );
            } else if (state is BackgroundDownloadStarted) {
              ModernToast.show(
                context: context,
                message: 'Téléchargement démarré en arrière-plan',
                type: ToastType.success,
                title: 'Succès',
              );
            } else if (state is BackgroundDownloadCancelled) {
              ModernToast.show(
                context: context,
                message: 'Téléchargement annulé',
                type: ToastType.info,
                title: 'Information',
              );
            }
          },
          builder: (context, state) {
            if (state is BackgroundDownloadLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryPurple,
                ),
              );
            }

            if (state is BackgroundDownloadUpdated) {
              return _buildDownloadsList(state);
            }

            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildDownloadsList(BackgroundDownloadUpdated state) {
    final allDownloads = state.allDownloads;

    if (allDownloads.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BackgroundDownloadCubit>().refreshDownloads();
      },
      color: AppColors.primaryPurple,
      backgroundColor: AppColors.darkSurface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allDownloads.length,
        itemBuilder: (context, index) {
          final download = allDownloads[index];
          return _buildDownloadItem(download);
        },
      ),
    );
  }

  Widget _buildDownloadItem(BackgroundDownloadItem download) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec titre et statut
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        download.fileName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusChip(download.status),
              ],
            ),

            const SizedBox(height: 12),

            // Barre de progression
            if (download.status == DownloadStatus.downloading) ...[
              _buildProgressBar(download),
              const SizedBox(height: 8),
            ],

            // Message de statut
            if (download.message != null) ...[
              Text(
                download.message!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(download.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (download.status == DownloadStatus.downloading ||
                        download.status == DownloadStatus.queued) ...[
                      TextButton.icon(
                        onPressed: () => _cancelDownload(download.id),
                        icon: const Icon(
                          Icons.cancel_rounded,
                          size: 16,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Annuler',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                    if (download.status == DownloadStatus.completed &&
                        download.filePath != null) ...[
                      TextButton.icon(
                        onPressed: () => _openFile(download.filePath!),
                        icon: const Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: AppColors.primaryPurple,
                        ),
                        label: const Text(
                          'Ouvrir',
                          style: TextStyle(color: AppColors.primaryPurple),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(DownloadStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case DownloadStatus.queued:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        break;
      case DownloadStatus.downloading:
        backgroundColor = AppColors.primaryPurple.withOpacity(0.2);
        textColor = AppColors.primaryPurple;
        break;
      case DownloadStatus.completed:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        break;
      case DownloadStatus.failed:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        break;
      case DownloadStatus.cancelled:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.icon,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BackgroundDownloadItem download) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progression',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(download.progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: download.progress,
          backgroundColor: AppColors.darkSurfaceVariant,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun téléchargement en arrière-plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les téléchargements en arrière-plan\napparaîtront ici',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _cancelDownload(String downloadId) {
    context.read<BackgroundDownloadCubit>().cancelDownload(downloadId);
  }

  void _openFile(String filePath) {
    // TODO: Implémenter l'ouverture du fichier
    ModernToast.show(
      context: context,
      message: 'Ouverture du fichier: $filePath',
      type: ToastType.info,
      title: 'Information',
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}