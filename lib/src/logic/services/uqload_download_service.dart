import 'dart:io';

import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:flutter/foundation.dart';
import 'package:french_stream_downloader/src/logic/models/download_details.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uqload_downloader_dart/uqload_downloader_dart.dart';

/// Callback type pour les mises à jour de progression
typedef ProgressCallback = void Function(int downloaded, int total);

/// Callback type pour les messages de statut
typedef StatusCallback = void Function(String message);

/// Service de téléchargement utilisant UQLoad Downloader
class UQLoadDownloadService {
  /// Starts a background download using the background_downloader package
  static Future<void> startBackgroundDownload({
    required DownloadDetails details,
  }) async {
    final videoUrl = details.videoInfo.url;
    final uri = Uri.parse(videoUrl);

    final task = bd.DownloadTask(
      url: videoUrl,
      filename: '${details.fileName}.mp4',
      directory: details.downloadDir,
      baseDirectory:
          bd.BaseDirectory.root, // Use root for absolute paths on Android
      updates: bd.Updates.statusAndProgress,
      requiresWiFi: false, // Allow downloads on mobile data
      allowPause: true, // Allow pausing downloads
      headers: {
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 OPR/120.0.0.0',
        'Referer': '${uri.scheme}://${uri.host}',
      },
      metaData: details.htmlUrl, // Use the HTML URL as a unique identifier
    );

    await bd.FileDownloader().enqueue(task);
  }

  // Stop a background download by its HTML URL
  static Future<void> stopBackgroundDownload(String htmlUrl) async {
    final tasks = await bd.FileDownloader().allTasks();
    for (var task in tasks) {
      if (task.metaData == htmlUrl) {
        await bd.FileDownloader().cancel(task);
        break;
      }
    }
  }

  /// Récupère les informations d'une vidéo UQLoad sans la télécharger
  static Future<VideoInfo> getVideoInfo(String url) async {
    try {
      final downloader = UQLoad(url: url);
      return await downloader.getVideoInfo();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des informations : $e");
    }
  }

  /// Valide si une URL est compatible avec UQLoad
  static bool isValidUQLoadUrl(String url) {
    return isUqloadUrl(url);
  }

  /// Obtient le dossier de téléchargement par défaut
  static Future<String> getDefaultDownloadDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError(
        "Les téléchargements ne sont pas supportés sur le web",
      );
    }

    Directory? directory;

    if (Platform.isAndroid) {
      // Pour Android, utiliser le dossier Downloads public
      directory = Directory('/storage/emulated/0/Download/LandFlix');
    } else if (Platform.isIOS) {
      // Pour iOS, utiliser le dossier Documents de l'app
      directory = await getApplicationDocumentsDirectory();
      directory = Directory('${directory.path}/Downloads');
    } else {
      // Pour desktop (Windows, macOS, Linux)
      directory = await getDownloadsDirectory();
      if (directory == null) {
        directory = await getApplicationDocumentsDirectory();
        directory = Directory('${directory.path}/Downloads');
      } else {
        directory = Directory('${directory.path}/LandFlix');
      }
    }

    // Créer le dossier s'il n'existe pas
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory.path;
  }

  /// Nettoie le nom de fichier pour éviter les caractères invalides
  static String sanitizeFileName(String fileName) {
    return removeSpecialCharacters(fileName)
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Formate la taille d'un fichier de manière lisible
  static String formatFileSize(int bytes) {
    return sizeOfFmt(bytes);
  }

  /// Classe pour encapsuler les détails de téléchargement
  static Future<DownloadDetails> prepareDownload(String url) async {
    final videoInfo = await getVideoInfo(url);
    final downloadDir = await getDefaultDownloadDirectory();
    final fileName = sanitizeFileName(videoInfo.title);
    final filePath = '$downloadDir/$fileName.mp4';

    return DownloadDetails(
      videoInfo: videoInfo,
      downloadPath: filePath,
      fileName: fileName,
      downloadDir: downloadDir,
      htmlUrl: url,
    );
  }
}
