import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/active_download_card.dart';
import 'package:french_stream_downloader/src/logic/models/active_download_info.dart';

/// Liste verticale des téléchargements actifs en cours de traitement.
class ActiveDownloadsList extends StatelessWidget {
  final List<ActiveDownloadInfo> downloads;
  final ValueChanged<ActiveDownloadInfo> onCancel;
  final ValueChanged<ActiveDownloadInfo>? onTogglePause;

  const ActiveDownloadsList({
    super.key,
    required this.downloads,
    required this.onCancel,
    this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    if (downloads.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: const [_EmptyActiveDownloadPlaceholder()],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: downloads.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final download = downloads[index];
        return ActiveDownloadCard(
          url: download.url,
          status: download.status,
          progress: download.progress,
          title: download.title,
          onCancel: () => onCancel(download),
          onTogglePause: onTogglePause == null
              ? null
              : () => onTogglePause!(download),
        );
      },
    );
  }
}

class _EmptyActiveDownloadPlaceholder extends StatelessWidget {
  const _EmptyActiveDownloadPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.downloading_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun téléchargement actif',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Lancez un nouveau téléchargement pour le voir apparaître ici.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
