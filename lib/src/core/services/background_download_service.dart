import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uqload_downloader_dart/uqload_downloader_dart.dart' as uqload;
import 'package:workmanager/workmanager.dart';

import '../../logic/services/download_manager.dart';
import '../models/download_models.dart';
import 'notification_service.dart';

/// Service de téléchargement en arrière-plan
class BackgroundDownloadService {
  static final BackgroundDownloadService _instance =
      BackgroundDownloadService._internal();
  factory BackgroundDownloadService() => _instance;
  BackgroundDownloadService._internal();

  static const String _taskName = 'download_task';
  static const String _queueKey = 'download_queue';
  static const String _activeDownloadsKey = 'active_downloads';

  bool _isInitialized = false;
  final List<BackgroundDownloadItem> _downloadQueue = [];
  final Map<String, BackgroundDownloadItem> _activeDownloads = {};

  /// Initialise le service de téléchargement en arrière-plan
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialiser Workmanager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    // Charger la queue depuis le stockage
    await _loadQueueFromStorage();
    await _loadActiveDownloadsFromStorage();

    // Initialiser le service de notification
    await NotificationService().initialize();

    _isInitialized = true;
    debugPrint('✅ BackgroundDownloadService initialisé');
  }

  /// Démarre un téléchargement en arrière-plan
  Future<String> startBackgroundDownload({
    required String url,
    required String title,
    String? outputDir,
    String? fileName,
  }) async {
    if (!_isInitialized) await initialize();

    final downloadId = _generateDownloadId(url);
    final notificationId = NotificationService.generateNotificationId(url);

    final downloadItem = BackgroundDownloadItem(
      id: downloadId,
      url: url,
      title: title,
      fileName: fileName ?? _sanitizeFileName(title),
      outputDir: outputDir,
      notificationId: notificationId,
      status: DownloadStatus.queued,
      createdAt: DateTime.now(),
    );

    // Ajouter à la queue
    _downloadQueue.add(downloadItem);
    await _saveQueueToStorage();

    // Programmer la tâche
    await Workmanager().registerOneOffTask(
      downloadId,
      _taskName,
      inputData: downloadItem.toJson(),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: true,
      ),
    );

    // Afficher notification de début
    await NotificationService().showDownloadStarted(
      id: notificationId,
      title: title,
      fileName: downloadItem.fileName,
    );

    debugPrint('📥 Téléchargement en arrière-plan programmé: $title');
    return downloadId;
  }

  /// Annule un téléchargement
  Future<void> cancelDownload(String downloadId) async {
    // Annuler la tâche
    await Workmanager().cancelByUniqueName(downloadId);

    // Retirer de la queue
    _downloadQueue.removeWhere((item) => item.id == downloadId);
    await _saveQueueToStorage();

    // Retirer des téléchargements actifs
    final activeItem = _activeDownloads.remove(downloadId);
    if (activeItem != null) {
      await _saveActiveDownloadsToStorage();

      // Annuler la notification
      await NotificationService().cancelNotification(activeItem.notificationId);
    }

    debugPrint('❌ Téléchargement annulé: $downloadId');
  }

  /// Récupère la liste des téléchargements en queue
  List<BackgroundDownloadItem> getQueuedDownloads() {
    return List.unmodifiable(_downloadQueue);
  }

  /// Récupère la liste des téléchargements actifs
  Map<String, BackgroundDownloadItem> getActiveDownloads() {
    return Map.unmodifiable(_activeDownloads);
  }

  /// Vérifie si un téléchargement est en cours pour cette URL
  bool isDownloading(String url) {
    final downloadId = _generateDownloadId(url);
    return _activeDownloads.containsKey(downloadId) ||
        _downloadQueue.any((item) => item.id == downloadId);
  }

  /// Met à jour le statut d'un téléchargement
  Future<void> updateDownloadStatus({
    required String downloadId,
    required DownloadStatus status,
    double? progress,
    String? message,
    String? filePath,
  }) async {
    // Mettre à jour dans les téléchargements actifs
    final activeItem = _activeDownloads[downloadId];
    if (activeItem != null) {
      final updatedItem = activeItem.copyWith(
        status: status,
        progress: progress,
        message: message,
        filePath: filePath,
        updatedAt: DateTime.now(),
      );

      _activeDownloads[downloadId] = updatedItem;
      await _saveActiveDownloadsToStorage();

      // Mettre à jour la notification
      switch (status) {
        case DownloadStatus.downloading:
          if (progress != null) {
            await NotificationService().updateDownloadProgress(
              id: activeItem.notificationId,
              fileName: activeItem.fileName,
              progress: progress,
              status: message,
            );
          }
          break;
        case DownloadStatus.completed:
          await NotificationService().showDownloadCompleted(
            id: activeItem.notificationId,
            fileName: activeItem.fileName,
            filePath: filePath ?? '',
          );

          // Enregistrer dans le gestionnaire de téléchargements
          if (filePath != null) {
            final videoInfo = uqload.VideoInfo(
              title: activeItem.title,
              url: activeItem.url,
              imageUrl: '',
              size: 0,
              type: 'video',
            );
            await DownloadManager.instance.recordDownload(
              videoInfo: videoInfo,
              filePath: filePath,
              originalUrl: activeItem.url,
            );
          }

          // Retirer des téléchargements actifs
          _activeDownloads.remove(downloadId);
          await _saveActiveDownloadsToStorage();
          break;
        case DownloadStatus.failed:
          await NotificationService().showDownloadError(
            id: activeItem.notificationId,
            fileName: activeItem.fileName,
            error: message ?? 'Erreur inconnue',
          );

          // Retirer des téléchargements actifs
          _activeDownloads.remove(downloadId);
          await _saveActiveDownloadsToStorage();
          break;
        case DownloadStatus.cancelled:
          await NotificationService().cancelNotification(
            activeItem.notificationId,
          );

          // Retirer des téléchargements actifs
          _activeDownloads.remove(downloadId);
          await _saveActiveDownloadsToStorage();
          break;
        default:
          break;
      }
    }
  }

  /// Sauvegarde la queue dans le stockage
  Future<void> _saveQueueToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = _downloadQueue.map((item) => item.toJson()).toList();
    await prefs.setString(_queueKey, jsonEncode(queueJson));
  }

  /// Charge la queue depuis le stockage
  Future<void> _loadQueueFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final queueString = prefs.getString(_queueKey);

    if (queueString != null) {
      final queueJson = jsonDecode(queueString) as List;
      _downloadQueue.clear();
      _downloadQueue.addAll(
        queueJson.map((json) => BackgroundDownloadItem.fromJson(json)).toList(),
      );
    }
  }

  /// Sauvegarde les téléchargements actifs dans le stockage
  Future<void> _saveActiveDownloadsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final activeJson = _activeDownloads.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await prefs.setString(_activeDownloadsKey, jsonEncode(activeJson));
  }

  /// Charge les téléchargements actifs depuis le stockage
  Future<void> _loadActiveDownloadsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final activeString = prefs.getString(_activeDownloadsKey);

    if (activeString != null) {
      final activeJson = jsonDecode(activeString) as Map<String, dynamic>;
      _activeDownloads.clear();
      _activeDownloads.addAll(
        activeJson.map(
          (key, value) => MapEntry(key, BackgroundDownloadItem.fromJson(value)),
        ),
      );
    }
  }

  /// Génère un ID de téléchargement unique
  String _generateDownloadId(String url) {
    return 'download_${url.hashCode.abs()}';
  }

  /// Nettoie un nom de fichier
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }
}

/// Point d'entrée pour les tâches en arrière-plan
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint('🔄 Exécution de la tâche en arrière-plan: $task');

      if (task == BackgroundDownloadService._taskName && inputData != null) {
        return await _executeDownloadTask(inputData);
      }

      return Future.value(true);
    } catch (e) {
      debugPrint('❌ Erreur dans la tâche en arrière-plan: $e');
      return Future.value(false);
    }
  });
}

/// Exécute une tâche de téléchargement
Future<bool> _executeDownloadTask(Map<String, dynamic> inputData) async {
  try {
    final downloadItem = BackgroundDownloadItem.fromJson(inputData);

    // Initialiser les services
    await NotificationService().initialize();

    // Marquer comme actif
    final backgroundService = BackgroundDownloadService();
    backgroundService._activeDownloads[downloadItem.id] = downloadItem.copyWith(
      status: DownloadStatus.downloading,
      updatedAt: DateTime.now(),
    );
    await backgroundService._saveActiveDownloadsToStorage();

    // Ici vous pouvez intégrer votre logique UQLoad
    // Pour l'instant, on simule un téléchargement
    await _simulateDownload(downloadItem);

    return true;
  } catch (e) {
    debugPrint('❌ Erreur lors du téléchargement: $e');
    return false;
  }
}

/// Simule un téléchargement (à remplacer par la logique UQLoad réelle)
Future<void> _simulateDownload(BackgroundDownloadItem item) async {
  final backgroundService = BackgroundDownloadService();

  // Simuler la progression
  for (int i = 10; i <= 100; i += 10) {
    await Future.delayed(const Duration(seconds: 1));

    await backgroundService.updateDownloadStatus(
      downloadId: item.id,
      status: DownloadStatus.downloading,
      progress: i / 100,
      message: 'Téléchargement... $i%',
    );
  }

  // Marquer comme terminé
  await backgroundService.updateDownloadStatus(
    downloadId: item.id,
    status: DownloadStatus.completed,
    filePath: '/storage/emulated/0/Download/${item.fileName}.mp4',
  );
}
