import 'dart:async';

import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../services/uqload_download_service.dart';

part 'download_state.dart';

class DownloadCubit extends Cubit<DownloadState> {
  final String videoUrl;
  late final StreamSubscription<bd.TaskUpdate> _progressSubscription;

  static final Stream<bd.TaskUpdate> _updates = bd.FileDownloader().updates
      .asBroadcastStream();

  DownloadCubit({required this.videoUrl}) : super(DownloadInitial()) {
    _progressSubscription = _updates.listen((update) {
      if (isClosed || update.task.metaData != videoUrl) return;

      if (update is bd.TaskStatusUpdate) {
        final status = update.status;
        if (status == bd.TaskStatus.enqueued) {
          emit(const DownloadInProgress(0.0, "En file d'attente..."));
        } else if (status == bd.TaskStatus.running) {
          emit(const DownloadInProgress(0.0, "Démarrage..."));
        } else if (status == bd.TaskStatus.complete) {
          emit(DownloadCompleted(update.task.filename));
        } else if (status == bd.TaskStatus.failed ||
            status == bd.TaskStatus.canceled ||
            status == bd.TaskStatus.notFound) {
          emit(DownloadError("Erreur de téléchargement : ${update.exception}"));
        }
      } else if (update is bd.TaskProgressUpdate) {
        final progress = update.progress;
        emit(DownloadInProgress(progress, "Téléchargement en cours..."));
      }
    });
  }

  @override
  Future<void> close() {
    _progressSubscription.cancel();
    return super.close();
  }

  /// Prépare un téléchargement en récupérant les informations de la vidéo
  Future<void> prepareDownload(String url) async {
    if (isClosed) return;

    if (!UQLoadDownloadService.isValidUQLoadUrl(url)) {
      if (!isClosed) {
        emit(const DownloadError("URL invalide pour UQLoad"));
      }
      return;
    }

    if (!isClosed) {
      emit(DownloadPreparing());
    }

    try {
      final details = await UQLoadDownloadService.prepareDownload(url);
      if (!isClosed) {
        emit(DownloadPrepared(details));
      }
    } catch (e) {
      if (!isClosed) {
        emit(DownloadError("Erreur lors de la préparation : $e"));
      }
    }
  }

  /// Starts a background download
  Future<void> startBackgroundDownload(DownloadDetails details) async {
    if (isClosed) return;
    emit(const DownloadInProgress(0.0, "Mise en file d'attente..."));
    try {
      await UQLoadDownloadService.startBackgroundDownload(details: details);
    } catch (e) {
      if (!isClosed) {
        emit(DownloadError("Erreur lors du lancement du téléchargement : $e"));
      }
    }
  }

  /// Annule le téléchargement en cours
  void cancelDownload() {
    if (!isClosed) {
      emit(DownloadCancelled());
    }
  }

  /// Remet à zéro l'état du cubit
  void reset() {
    if (!isClosed) {
      emit(DownloadInitial());
    }
  }

  /// Récupère les informations d'une vidéo sans la télécharger
  Future<void> getVideoInfo(String url) async {
    if (isClosed) return;

    if (!UQLoadDownloadService.isValidUQLoadUrl(url)) {
      if (!isClosed) {
        emit(const DownloadError("URL invalide pour UQLoad"));
      }
      return;
    }

    if (!isClosed) {
      emit(DownloadPreparing());
    }

    try {
      final videoInfo = await UQLoadDownloadService.getVideoInfo(url);
      final downloadDir =
          await UQLoadDownloadService.getDefaultDownloadDirectory();
      final fileName = UQLoadDownloadService.sanitizeFileName(videoInfo.title);

      final details = DownloadDetails(
        videoInfo: videoInfo,
        downloadPath: '$downloadDir/$fileName.mp4',
        fileName: fileName,
        downloadDir: downloadDir,
        htmlUrl: url,
      );

      if (!isClosed) {
        emit(DownloadPrepared(details));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          DownloadError("Erreur lors de la récupération des informations : $e"),
        );
      }
    }
  }
}
