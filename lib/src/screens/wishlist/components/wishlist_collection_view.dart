import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/logic/models/wishlist_item.dart';
import 'package:french_stream_downloader/src/logic/services/download_manager.dart';
import 'package:french_stream_downloader/src/logic/services/uqload_download_service.dart';
import 'package:french_stream_downloader/src/shared/components/downloaded_badge.dart';

/// Affichage principal de la collection de favoris.
class WishlistCollectionView extends StatelessWidget {
  final List<WishlistItem> items;
  final Set<String> downloadingIds;
  final ValueChanged<WishlistItem> onRemove;
  final ValueChanged<WishlistItem> onDownload;
  final ValueChanged<WishlistItem>? onOpen;

  const WishlistCollectionView({
    super.key,
    required this.items,
    required this.downloadingIds,
    required this.onRemove,
    required this.onDownload,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isDownloaded = DownloadManager.instance.isDownloaded(
          item.htmlUrl,
        );
        final isDownloading = downloadingIds.contains(item.id);

        return _WishlistCard(
          item: item,
          isDownloaded: isDownloaded,
          isDownloading: isDownloading,
          onRemove: () => onRemove(item),
          onDownload: () => onDownload(item),
          onOpen: onOpen == null ? null : () => onOpen!(item),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final WishlistItem item;
  final bool isDownloaded;
  final bool isDownloading;
  final VoidCallback onRemove;
  final VoidCallback onDownload;
  final VoidCallback? onOpen;

  const _WishlistCard({
    required this.item,
    required this.isDownloaded,
    required this.isDownloading,
    required this.onRemove,
    required this.onDownload,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.08),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildRemoveButton(context),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildBadge(
                            context,
                            label: item.resolution ?? 'Qualité inconnue',
                            icon: Icons.high_quality_rounded,
                          ),
                          _buildBadge(
                            context,
                            label: UQLoadDownloadService.formatFileSize(
                              item.sizeInBytes,
                            ),
                            icon: Icons.sd_storage_rounded,
                          ),
                          _buildBadge(
                            context,
                            label: item.duration ?? 'Durée inconnue',
                            icon: Icons.schedule_rounded,
                          ),
                          _buildBadge(
                            context,
                            label: 'Ajouté ${_formatSince(item.addedAt)}',
                            icon: Icons.bookmark_added_rounded,
                          ),
                          if (isDownloaded)
                            const DownloadedBadge(size: BadgeSize.small),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildDownloadButton(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return SizedBox(
        width: 90,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Image.network(
              item.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _thumbnailFallback(),
            ),
          ),
        ),
      );
    }
    return _thumbnailFallback();
  }

  Widget _thumbnailFallback() {
    return Container(
      width: 90,
      height: 42,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.movie_outlined, color: Colors.white, size: 24),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context) {
    return Tooltip(
      message: 'Retirer de la liste',
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    final child = isDownloading
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : const Icon(Icons.download_rounded, color: Colors.white, size: 18);

    return ElevatedButton.icon(
      onPressed: isDownloading ? null : onDownload,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      icon: child,
      label: Text(
        isDownloading ? 'Préparation…' : 'Télécharger',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatSince(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays >= 1) {
      return 'il y a ${diff.inDays} j';
    }
    if (diff.inHours >= 1) {
      return 'il y a ${diff.inHours} h';
    }
    if (diff.inMinutes >= 1) {
      return 'il y a ${diff.inMinutes} min';
    }
    return "à l'instant";
  }
}
