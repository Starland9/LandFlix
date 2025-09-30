part of 'download_cubit.dart';

sealed class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object?> get props => [];
}

/// État initial, aucun téléchargement en cours
final class DownloadInitial extends DownloadState {}

/// État de préparation du téléchargement (récupération des infos)
final class DownloadPreparing extends DownloadState {}

/// État où les informations du téléchargement sont prêtes
final class DownloadPrepared extends DownloadState {
  final DownloadDetails details;

  const DownloadPrepared(this.details);

  @override
  List<Object?> get props => [details];
}

/// État de téléchargement en cours
final class DownloadInProgress extends DownloadState {
  final double progress; // Entre 0.0 et 1.0
  final String message;

  const DownloadInProgress(this.progress, this.message);

  @override
  List<Object?> get props => [progress, message];

  /// Retourne le pourcentage de progression (0-100)
  int get percentage => (progress * 100).round();
}

/// État de téléchargement terminé avec succès
final class DownloadCompleted extends DownloadState {
  final String filePath;

  const DownloadCompleted(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// État de téléchargement annulé
final class DownloadCancelled extends DownloadState {}

/// État d'erreur lors du téléchargement
final class DownloadError extends DownloadState {
  final String message;

  const DownloadError(this.message);

  @override
  List<Object?> get props => [message];
}
