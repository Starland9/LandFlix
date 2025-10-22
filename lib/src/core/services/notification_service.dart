import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'download_channel';
  static const String _channelName = 'Téléchargements';
  static const String _channelDescription =
      'Notifications de progression des téléchargements';

  bool _isInitialized = false;
  bool _permissionsHandled = false;

  /// Initialise le service de notification
  Future<void> initialize({bool requestPermissions = true}) async {
    if (!_isInitialized) {
      // Configuration Android
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // Configuration iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Configuration Linux
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        linux: linuxSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }

      _isInitialized = true;
      debugPrint('✅ NotificationService initialisé');
    }

    if (requestPermissions && !_permissionsHandled) {
      await _requestPermissions();
    }
  }

  /// Demande les permissions nécessaires
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      try {
        final status = await Permission.notification.request();
        if (status.isDenied) {
          debugPrint('⚠️ Permission de notification refusée');
        }
        _permissionsHandled = true;
      } catch (e) {
        debugPrint('⚠️ Échec de la demande de permission de notification: $e');
      }
    } else {
      _permissionsHandled = true;
    }
  }

  /// Crée le canal de notification Android
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Affiche une notification de début de téléchargement
  Future<void> showDownloadStarted({
    required int id,
    required String title,
    required String fileName,
  }) async {
    await initialize(requestPermissions: false);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      maxProgress: 100,
      progress: 0,
      indeterminate: false,
      autoCancel: false,
      ongoing: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      'Téléchargement démarré',
      fileName,
      notificationDetails,
    );
  }

  /// Met à jour la progression du téléchargement
  Future<void> updateDownloadProgress({
    required int id,
    required String fileName,
    required double progress,
    String? status,
  }) async {
    await initialize(requestPermissions: false);

    final progressPercent = (progress * 100).round();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      maxProgress: 100,
      progress: progressPercent,
      indeterminate: false,
      autoCancel: false,
      ongoing: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: true,
      presentSound: false,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final body = status ?? '$progressPercent% - $fileName';

    await _notifications.show(
      id,
      'Téléchargement en cours...',
      body,
      notificationDetails,
    );
  }

  /// Affiche une notification de téléchargement terminé
  Future<void> showDownloadCompleted({
    required int id,
    required String fileName,
    required String filePath,
  }) async {
    await initialize(requestPermissions: false);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      ongoing: false,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: Color(0xFF6C5CE7),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      '✅ Téléchargement terminé',
      fileName,
      notificationDetails,
      payload: filePath,
    );
  }

  /// Affiche une notification d'erreur
  Future<void> showDownloadError({
    required int id,
    required String fileName,
    required String error,
  }) async {
    await initialize(requestPermissions: false);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      ongoing: false,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: Color(0xFFE74C3C),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      '❌ Erreur de téléchargement',
      fileName,
      notificationDetails,
    );
  }

  /// Annule une notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Annule toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Callback quand une notification est tapée
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapée: ${response.payload}');

    // Ici vous pouvez naviguer vers l'écran des téléchargements
    // ou ouvrir le fichier selon le payload
    if (response.payload != null) {
      // Exemple: ouvrir le fichier ou naviguer vers l'écran approprié
    }
  }

  /// Vérifie si les permissions sont accordées
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    }
    return true; // iOS gère automatiquement
  }

  /// Génère un ID unique basé sur l'URL
  static int generateNotificationId(String url) {
    return url.hashCode.abs();
  }
}
