import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/models/download_models.dart';
import '../../../core/services/background_download_service.dart';

part 'background_download_state.dart';

class BackgroundDownloadCubit extends Cubit<BackgroundDownloadState> {
  BackgroundDownloadCubit() : super(const BackgroundDownloadInitial());

  final BackgroundDownloadService _backgroundService =
      BackgroundDownloadService();
  StreamSubscription<BackgroundDownloadSnapshot>? _stateSubscription;

  /// Initialise le service de téléchargement en arrière-plan
  Future<void> initialize() async {
    if (isClosed) return;

    try {
      emit(const BackgroundDownloadLoading());
      await _backgroundService.initialize();

      _stateSubscription ??= _backgroundService.stateStream.listen((snapshot) {
        if (!isClosed) {
          emit(
            BackgroundDownloadUpdated(
              queuedDownloads: snapshot.queuedDownloads,
              activeDownloads: snapshot.activeDownloads,
            ),
          );
        }
      });

      // Charger l'état actuel
      await _loadCurrentState();

      if (!isClosed) {
        emit(const BackgroundDownloadReady());
      }
    } catch (e) {
      if (!isClosed) {
        emit(BackgroundDownloadError('Erreur d\'initialisation: $e'));
      }
    }
  }

  /// Démarre un téléchargement en arrière-plan
  Future<void> startBackgroundDownload({
    required String url,
    required String title,
    String? outputDir,
    String? fileName,
  }) async {
    if (isClosed) return;

    try {
      // Vérifier si déjà en cours
      if (_backgroundService.isDownloading(url)) {
        if (!isClosed) {
          emit(
            const BackgroundDownloadError(
              'Ce téléchargement est déjà en cours',
            ),
          );
        }
        return;
      }

      emit(const BackgroundDownloadStarting());

      final downloadId = await _backgroundService.startBackgroundDownload(
        url: url,
        title: title,
        outputDir: outputDir,
        fileName: fileName,
      );

      // Recharger l'état
      await _loadCurrentState();

      if (!isClosed) {
        emit(BackgroundDownloadStarted(downloadId));
      }
    } catch (e) {
      if (!isClosed) {
        emit(BackgroundDownloadError('Erreur lors du démarrage: $e'));
      }
    }
  }

  /// Annule un téléchargement
  Future<void> cancelDownload(String downloadId) async {
    if (isClosed) return;

    try {
      await _backgroundService.cancelDownload(downloadId);

      // Recharger l'état
      await _loadCurrentState();

      if (!isClosed) {
        emit(BackgroundDownloadCancelled(downloadId));
      }
    } catch (e) {
      if (!isClosed) {
        emit(BackgroundDownloadError('Erreur lors de l\'annulation: $e'));
      }
    }
  }

  /// Recharge l'état actuel des téléchargements
  Future<void> refreshDownloads() async {
    if (isClosed) return;

    try {
      emit(const BackgroundDownloadRefreshing());
      await _loadCurrentState();

      if (!isClosed) {
        emit(const BackgroundDownloadRefreshed());
      }
    } catch (e) {
      if (!isClosed) {
        emit(BackgroundDownloadError('Erreur lors du rafraîchissement: $e'));
      }
    }
  }

  /// Charge l'état actuel depuis le service
  Future<void> _loadCurrentState() async {
    final queuedDownloads = _backgroundService.getQueuedDownloads();
    final activeDownloads = _backgroundService.getActiveDownloads();

    if (!isClosed) {
      emit(
        BackgroundDownloadUpdated(
          queuedDownloads: queuedDownloads,
          activeDownloads: activeDownloads,
        ),
      );
    }
  }

  /// Vérifie si un téléchargement est en cours pour une URL
  bool isDownloading(String url) {
    return _backgroundService.isDownloading(url);
  }

  /// Récupère le nombre total de téléchargements actifs
  int getActiveDownloadsCount() {
    return _backgroundService.getActiveDownloads().length;
  }

  /// Récupère le nombre total de téléchargements en queue
  int getQueuedDownloadsCount() {
    return _backgroundService.getQueuedDownloads().length;
  }

  @override
  Future<void> close() {
    _stateSubscription?.cancel();
    return super.close();
  }
}
