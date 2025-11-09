import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service de gestion des notifications pour les téléchargements
/// Affiche des notifications de progression similaires à Google Chrome
class NotificationService {
  static const String _channelId = 'landflix_downloads';
  static const String _channelName = 'Téléchargements LandFlix';
  static const String _channelDescription =
      'Notifications de progression des téléchargements';

  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialise le service de notifications
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Configuration Android
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/launcher_icon',
      );

      // Configuration iOS/macOS
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: false,
      );

      // Configuration Linux
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Ouvrir',
      );

      // Configuration Windows
      const windowsSettings = WindowsInitializationSettings(
        appName: 'LandFlix',
        appUserModelId: 'com.landflix.app',
        guid: '12345678-1234-1234-1234-123456789012',
      );

      // Configuration globale
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
        windows: windowsSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      // Demander les permissions sur Android 13+
      if (Platform.isAndroid) {
        await _requestAndroidPermissions();
      }

      // Demander les permissions sur iOS/macOS
      if (Platform.isIOS || Platform.isMacOS) {
        await _requestDarwinPermissions();
      }

      _initialized = true;
      dev.log('NotificationService initialisé avec succès');
    } catch (e, stack) {
      dev.log(
        'Erreur lors de l\'initialisation du NotificationService',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Demande les permissions de notification sur Android
  Future<void> _requestAndroidPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  /// Demande les permissions de notification sur iOS/macOS
  Future<void> _requestDarwinPermissions() async {
    final darwinImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (darwinImplementation != null) {
      await darwinImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: false,
      );
    }

    final macosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();

    if (macosImplementation != null) {
      await macosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: false,
      );
    }
  }

  /// Gère le tap sur une notification
  void _handleNotificationTap(NotificationResponse response) {
    dev.log('Notification tapped: ${response.payload}');
    // TODO: Navigation vers l'écran des téléchargements
    // Cela sera géré par le DownloadManager en écoutant ce callback
  }

  /// Affiche une notification de progression de téléchargement
  Future<void> showDownloadProgress({
    required int notificationId,
    required String title,
    required String filename,
    required int progress,
    required int maxProgress,
  }) async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return;
    }

    if (!_initialized) {
      dev.log(
        'NotificationService non initialisé, tentative d\'initialisation...',
      );
      await initialize();
    }

    try {
      final progressPercent = maxProgress > 0
          ? ((progress / maxProgress) * 100).toInt()
          : 0;

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        maxProgress: maxProgress,
        progress: progress,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        playSound: false,
        enableVibration: false,
        category: AndroidNotificationCategory.progress,
        visibility: NotificationVisibility.public,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: true,
        presentSound: false,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _notifications.show(
        notificationId,
        title,
        '$filename - $progressPercent%',
        notificationDetails,
        payload: 'download_progress_$notificationId',
      );
    } catch (e, stack) {
      dev.log(
        'Erreur lors de l\'affichage de la notification de progression',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Affiche une notification de téléchargement terminé
  Future<void> showDownloadComplete({
    required int notificationId,
    required String title,
    required String filename,
    String? filePath,
  }) async {
    if (!_initialized) {
      dev.log(
        'NotificationService non initialisé, tentative d\'initialisation...',
      );
      await initialize();
    }

    try {
      final androidDetails = const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        ongoing: false,
        autoCancel: true,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.status,
        icon: '@mipmap/launcher_icon',
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const linuxDetails = LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.normal,
        actions: [
          LinuxNotificationAction(key: 'open_file', label: 'Ouvrir le fichier'),
          LinuxNotificationAction(
            key: 'open_downloads',
            label: 'Ouvrir les téléchargements',
          ),
        ],
      );

      const windowsDetails = WindowsNotificationDetails();

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
        linux: linuxDetails,
        windows: windowsDetails,
      );

      await _notifications.show(
        notificationId,
        '$title - Terminé',
        'Téléchargement de $filename terminé avec succès',
        notificationDetails,
        payload: filePath != null ? 'download_complete_$filePath' : null,
      );
    } catch (e, stack) {
      dev.log(
        'Erreur lors de l\'affichage de la notification de téléchargement terminé',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Affiche une notification d'erreur de téléchargement
  Future<void> showDownloadError({
    required int notificationId,
    required String title,
    required String filename,
    String? errorMessage,
  }) async {
    if (!_initialized) {
      dev.log(
        'NotificationService non initialisé, tentative d\'initialisation...',
      );
      await initialize();
    }

    try {
      final androidDetails = const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        ongoing: false,
        autoCancel: true,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.error,
        icon: '@mipmap/launcher_icon',
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const linuxDetails = LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.critical,
        actions: [
          LinuxNotificationAction(
            key: 'open_downloads',
            label: 'Ouvrir les téléchargements',
          ),
        ],
      );

      const windowsDetails = WindowsNotificationDetails();

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
        linux: linuxDetails,
        windows: windowsDetails,
      );

      final message = errorMessage != null
          ? 'Erreur: $errorMessage'
          : 'Le téléchargement de $filename a échoué';

      await _notifications.show(
        notificationId,
        '$title - Échec',
        message,
        notificationDetails,
        payload: 'download_error_$notificationId',
      );
    } catch (e, stack) {
      dev.log(
        'Erreur lors de l\'affichage de la notification d\'erreur',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Annule une notification spécifique
  Future<void> cancelNotification(int notificationId) async {
    try {
      await _notifications.cancel(notificationId);
    } catch (e, stack) {
      dev.log(
        'Erreur lors de l\'annulation de la notification',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Annule toutes les notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e, stack) {
      dev.log(
        'Erreur lors de l\'annulation de toutes les notifications',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Génère un ID de notification unique à partir d'une URL
  int getNotificationIdFromUrl(String url) {
    // Utilise le hashCode de l'URL pour générer un ID unique
    // Assure que l'ID est positif et dans la plage des entiers 32 bits
    return url.hashCode.abs() % 2147483647;
  }
}
