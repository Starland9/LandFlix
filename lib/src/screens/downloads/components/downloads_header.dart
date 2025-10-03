import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';

class DownloadsHeader extends StatelessWidget {
  final bool isLoading;
  final int activeDownloadsCount;
  final int completedDownloadsCount;
  final String totalSize;
  final VoidCallback onCleanUp;
  final bool canCleanUp;

  const DownloadsHeader({
    super.key,
    required this.isLoading,
    required this.activeDownloadsCount,
    required this.completedDownloadsCount,
    required this.totalSize,
    required this.onCleanUp,
    required this.canCleanUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!isLoading) ...[
                  const SizedBox(height: 4),
                  Text(
                    "${activeDownloadsCount + completedDownloadsCount} téléchargement${(activeDownloadsCount + completedDownloadsCount) > 1 ? 's' : ''} • $totalSize",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (canCleanUp)
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: onCleanUp,
                icon: const Icon(
                  Icons.cleaning_services_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
