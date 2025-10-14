import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/logic/models/download_item.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/download_card.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/empty_state.dart';

/// Liste générique de téléchargements persistés (terminés ou supprimés).
class DownloadItemsList extends StatelessWidget {
  final List<DownloadItem> downloads;
  final ValueChanged<DownloadItem> onOpen;
  final ValueChanged<DownloadItem> onDelete;
  final String emptyLabel;
  final IconData emptyIcon;
  final String emptyDescription;
  final String? emptyTip;

  const DownloadItemsList({
    super.key,
    required this.downloads,
    required this.onOpen,
    required this.onDelete,
    required this.emptyLabel,
    required this.emptyIcon,
    required this.emptyDescription,
    this.emptyTip,
  });

  @override
  Widget build(BuildContext context) {
    if (downloads.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _EmptyDownloadPlaceholder(
            label: emptyLabel,
            description: emptyDescription,
            icon: emptyIcon,
            tip: emptyTip,
          ),
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
  final String description;
  final IconData icon;
  final String? tip;

  const _EmptyDownloadPlaceholder({
    required this.label,
    required this.description,
    required this.icon,
    this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return DownloadsEmptyContent(
      icon: icon,
      title: label,
      description: description,
      tip: tip,
    );
  }
}
