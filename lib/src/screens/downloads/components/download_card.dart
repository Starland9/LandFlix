import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/logic/models/download_item.dart';

class DownloadCard extends StatelessWidget {
  final DownloadItem download;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const DownloadCard({
    super.key,
    required this.download,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDeleted = download.status == DownloadStatus.deleted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isDeleted
            ? LinearGradient(
                colors: [
                  AppColors.darkSurface.withAlpha(128),
                  AppColors.darkSurfaceVariant.withAlpha(77),
                ],
              )
            : AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDeleted
              ? AppColors.error.withAlpha(77)
              : AppColors.primaryPurple.withAlpha(51),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isDeleted ? null : onOpen,
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
                          _buildInfoBadge(
                            context,
                            download.formattedSize,
                            AppColors.accentTeal,
                          ),
                          const SizedBox(width: 8),
                          // Badge de date
                          _buildInfoBadge(
                            context,
                            download.formattedDate,
                            AppColors.primaryPurple,
                          ),
                          if (isDeleted) ...[
                            const SizedBox(width: 8),
                            _buildInfoBadge(
                              context,
                              "Supprimé",
                              AppColors.error,
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
                    color: AppColors.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withAlpha(77)),
                  ),
                  child: IconButton(
                    onPressed: onDelete,
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

  Widget _buildInfoBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
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
                  AppColors.error.withAlpha(77),
                  AppColors.error.withAlpha(25),
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
}
