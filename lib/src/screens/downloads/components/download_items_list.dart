import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/logic/models/download_item.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/download_card.dart';

/// Liste générique de téléchargements persistés (terminés ou supprimés).
class DownloadItemsList extends StatelessWidget {
  final List<DownloadItem> downloads;
  final ValueChanged<DownloadItem> onOpen;
  final ValueChanged<DownloadItem> onDelete;
  final String emptyLabel;
  final IconData emptyIcon;

  const DownloadItemsList({
    super.key,
    required this.downloads,
    required this.onOpen,
    required this.onDelete,
    required this.emptyLabel,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (downloads.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _EmptyDownloadPlaceholder(label: emptyLabel, icon: emptyIcon),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final download = downloads[index];
        return DownloadCard(
          download: download,
          onOpen: () => onOpen(download),
          onDelete: () => onDelete(download),
        );
      },
    );
  }
}

class _EmptyDownloadPlaceholder extends StatelessWidget {
  final String label;
  final IconData icon;

  const _EmptyDownloadPlaceholder({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
