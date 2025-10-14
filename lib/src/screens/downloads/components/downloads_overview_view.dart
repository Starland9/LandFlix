import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/logic/models/active_download_info.dart';
import 'package:french_stream_downloader/src/logic/models/download_item.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/active_download_card.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/download_card.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/empty_state.dart';
import 'package:french_stream_downloader/src/screens/downloads/components/section_header.dart';

/// Vue d’ensemble mixant téléchargements actifs, terminés et supprimés.
class DownloadsOverviewView extends StatelessWidget {
  final List<ActiveDownloadInfo> activeDownloads;
  final List<DownloadItem> completedDownloads;
  final List<DownloadItem> deletedDownloads;
  final ValueChanged<ActiveDownloadInfo> onCancelActive;
  final ValueChanged<ActiveDownloadInfo>? onTogglePause;
  final ValueChanged<DownloadItem> onOpenDownload;
  final ValueChanged<DownloadItem> onDeleteDownload;

  const DownloadsOverviewView({
    super.key,
    required this.activeDownloads,
    required this.completedDownloads,
    required this.deletedDownloads,
    required this.onCancelActive,
    required this.onOpenDownload,
    required this.onDeleteDownload,
    this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        if (activeDownloads.isNotEmpty) ...[
          SectionHeader(
            title: 'Téléchargements en cours',
            count: activeDownloads.length,
          ),
          ...activeDownloads.map(
            (download) => ActiveDownloadCard(
              url: download.url,
              status: download.status,
              progress: download.progress,
              title: download.title,
              onCancel: () => onCancelActive(download),
              onTogglePause: onTogglePause == null
                  ? null
                  : () => onTogglePause!(download),
            ),
          ),
        ],
        if (completedDownloads.isNotEmpty) ...[
          SectionHeader(
            title: 'Téléchargements terminés',
            count: completedDownloads.length,
          ),
          ...completedDownloads.map(
            (download) => DownloadCard(
              download: download,
              onOpen: () => onOpenDownload(download),
              onDelete: () => onDeleteDownload(download),
            ),
          ),
        ],
        if (deletedDownloads.isNotEmpty) ...[
          SectionHeader(
            title: 'Téléchargements supprimés',
            count: deletedDownloads.length,
          ),
          ...deletedDownloads.map(
            (download) => DownloadCard(
              download: download,
              onOpen: () => onOpenDownload(download),
              onDelete: () => onDeleteDownload(download),
            ),
          ),
        ],
        if (activeDownloads.isEmpty &&
            completedDownloads.isEmpty &&
            deletedDownloads.isEmpty)
          const _OverviewEmptyState(),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _OverviewEmptyState extends StatelessWidget {
  const _OverviewEmptyState();

  @override
  Widget build(BuildContext context) {
    return const DownloadsEmptyContent(
      icon: Icons.inbox_rounded,
      title: 'Aucun téléchargement enregistré pour le moment.',
      description:
          'Commencez un téléchargement et suivez sa progression dans cette vue.',
      tip: 'Astuce : Utilisez la recherche pour ajouter un nouveau contenu.',
    );
  }
}
