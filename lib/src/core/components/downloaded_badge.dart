import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';

/// Widget badge pour indiquer qu'un média est déjà téléchargé
class DownloadedBadge extends StatelessWidget {
  const DownloadedBadge({
    super.key,
    this.size = BadgeSize.small,
    this.showIcon = true,
  });

  final BadgeSize size;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size == BadgeSize.large ? 12 : 8,
        vertical: size == BadgeSize.large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size == BadgeSize.large ? 12 : 8),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: size == BadgeSize.large ? 16 : 12,
            ),
            SizedBox(width: size == BadgeSize.large ? 6 : 4),
          ],
          Text(
            "Téléchargé",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
              fontSize: size == BadgeSize.large ? 12 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tailles disponibles pour le badge
enum BadgeSize { small, large }

/// Widget pour indiquer un téléchargement dans les cartes de recherche
class DownloadIndicatorOverlay extends StatelessWidget {
  const DownloadIndicatorOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.download_done_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
