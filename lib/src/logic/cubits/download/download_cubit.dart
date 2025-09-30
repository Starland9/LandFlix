import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:french_stream_downloader/src/core/services/uqload_download_service.dart';

part 'download_state.dart';

class DownloadCubit extends Cubit<DownloadState> {
  DownloadCubit() : super(DownloadInitial());

  /// Prépare un téléchargement en récupérant les informations de la vidéo
  Future<void> prepareDownload(String url) async {
    if (!UQLoadDownloadService.isValidUQLoadUrl(url)) {
      emit(DownloadError("URL invalide pour UQLoad"));
      return;
    }

    emit(DownloadPreparing());

    try {
      final details = await UQLoadDownloadService.prepareDownload(url);
      emit(DownloadPrepared(details));
    } catch (e) {
      emit(DownloadError("Erreur lors de la préparation : $e"));
    }
  }

  /// Lance le téléchargement d'une vidéo
  Future<void> startDownload({
    required String url,
    String? outputFile,
    String? outputDir,
  }) async {
    emit(DownloadInProgress(0.0, "Initialisation..."));

    try {
      final filePath = await UQLoadDownloadService.downloadVideo(
        url: url,
        outputFile: outputFile,
        outputDir: outputDir,
        onProgress: (downloaded, total) {
          if (total > 0) {
            final progress = downloaded / total;
            final percentString = "${(progress * 100).toInt()}%";
            emit(
              DownloadInProgress(
                progress,
                "Téléchargement en cours... $percentString",
              ),
            );
          }
        },
        onStatus: (message) {
          if (state is DownloadInProgress) {
            final currentState = state as DownloadInProgress;
            emit(DownloadInProgress(currentState.progress, message));
          }
        },
      );

      emit(DownloadCompleted(filePath));
    } catch (e) {
      emit(DownloadError("Erreur lors du téléchargement : $e"));
    }
  }

  /// Annule le téléchargement en cours
  void cancelDownload() {
    emit(DownloadCancelled());
  }

  /// Remet à zéro l'état du cubit
  void reset() {
    emit(DownloadInitial());
  }

  /// Récupère les informations d'une vidéo sans la télécharger
  Future<void> getVideoInfo(String url) async {
    if (!UQLoadDownloadService.isValidUQLoadUrl(url)) {
      emit(DownloadError("URL invalide pour UQLoad"));
      return;
    }

    emit(DownloadPreparing());

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
      );

      emit(DownloadPrepared(details));
    } catch (e) {
      emit(
        DownloadError("Erreur lors de la récupération des informations : $e"),
      );
    }
  }
}
