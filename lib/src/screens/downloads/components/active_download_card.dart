import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';

class ActiveDownloadCard extends StatelessWidget {
  final String url;
  final bd.TaskStatus status;
  final double progress;
  final String title;
  final VoidCallback onCancel;
  final VoidCallback? onTogglePause;

  const ActiveDownloadCard({
    super.key,
    required this.url,
    required this.status,
    required this.progress,
    required this.title,
    required this.onCancel,
    this.onTogglePause,
  });

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

  @override
  Widget build(BuildContext context) {
    final statusText = _getStatusText(status);
    final statusColor = _getStatusColor(status);
    final percentage = (progress * 100).toInt();
    final canTogglePause =
        status == bd.TaskStatus.running || status == bd.TaskStatus.paused;
    final showToggle = canTogglePause && onTogglePause != null;
    final isPaused = status == bd.TaskStatus.paused;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withAlpha(77), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
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
                        title,
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
                              color: statusColor.withAlpha(51),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusColor.withAlpha(77),
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
                const SizedBox(width: 16),
                if (showToggle) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withAlpha(31),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryPurple.withAlpha(77),
                      ),
                    ),
                    child: IconButton(
                      onPressed: onTogglePause,
                      icon: Icon(
                        isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        color: AppColors.primaryPurple,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withAlpha(77)),
                  ),
                  child: IconButton(
                    onPressed: onCancel,
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
}
