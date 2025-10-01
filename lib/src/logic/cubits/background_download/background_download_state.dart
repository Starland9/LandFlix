part of 'background_download_cubit.dart';

abstract class BackgroundDownloadState extends Equatable {
  const BackgroundDownloadState();

  @override
  List<Object?> get props => [];
}

/// État initial
class BackgroundDownloadInitial extends BackgroundDownloadState {
  const BackgroundDownloadInitial();
}

/// En cours de chargement/initialisation
class BackgroundDownloadLoading extends BackgroundDownloadState {
  const BackgroundDownloadLoading();
}

/// Service prêt à fonctionner
class BackgroundDownloadReady extends BackgroundDownloadState {
  const BackgroundDownloadReady();
}

/// En cours de démarrage d'un téléchargement
class BackgroundDownloadStarting extends BackgroundDownloadState {
  const BackgroundDownloadStarting();
}

/// Téléchargement démarré avec succès
class BackgroundDownloadStarted extends BackgroundDownloadState {
  final String downloadId;

  const BackgroundDownloadStarted(this.downloadId);

  @override
  List<Object?> get props => [downloadId];
}

/// Téléchargement annulé
class BackgroundDownloadCancelled extends BackgroundDownloadState {
  final String downloadId;

  const BackgroundDownloadCancelled(this.downloadId);

  @override
  List<Object?> get props => [downloadId];
}

/// En cours de rafraîchissement
class BackgroundDownloadRefreshing extends BackgroundDownloadState {
  const BackgroundDownloadRefreshing();
}

/// Rafraîchissement terminé
class BackgroundDownloadRefreshed extends BackgroundDownloadState {
  const BackgroundDownloadRefreshed();
}

/// État mis à jour avec les téléchargements actuels
class BackgroundDownloadUpdated extends BackgroundDownloadState {
  final List<BackgroundDownloadItem> queuedDownloads;
  final Map<String, BackgroundDownloadItem> activeDownloads;

  const BackgroundDownloadUpdated({
    required this.queuedDownloads,
    required this.activeDownloads,
  });

  @override
  List<Object?> get props => [queuedDownloads, activeDownloads];

  /// Récupère le nombre total de téléchargements
  int get totalDownloads => queuedDownloads.length + activeDownloads.length;

  /// Récupère tous les téléchargements sous forme de liste
  List<BackgroundDownloadItem> get allDownloads {
    return [...activeDownloads.values, ...queuedDownloads];
  }

  /// Vérifie si un téléchargement est en cours pour une URL
  bool isDownloading(String url) {
    final downloadId = 'download_${url.hashCode.abs()}';
    return activeDownloads.containsKey(downloadId) ||
        queuedDownloads.any((item) => item.id == downloadId);
  }
}

/// Erreur dans le service de téléchargement
class BackgroundDownloadError extends BackgroundDownloadState {
  final String message;

  const BackgroundDownloadError(this.message);

  @override
  List<Object?> get props => [message];
}
