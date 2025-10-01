import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/notification_service.dart';
import '../../core/themes/colors.dart';
import '../../logic/cubits/background_download/background_download_cubit.dart';
import 'modern_toast.dart';

/// Widget de test pour les notifications de téléchargement
class DownloadTestWidget extends StatelessWidget {
  const DownloadTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🧪 Test des notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Test notification simple
          ElevatedButton.icon(
            onPressed: () => _testSimpleNotification(),
            icon: const Icon(Icons.notifications),
            label: const Text('Test notification simple'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Test notification de téléchargement
          ElevatedButton.icon(
            onPressed: () => _testDownloadNotifications(),
            icon: const Icon(Icons.download),
            label: const Text('Test notifications téléchargement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Test téléchargement en arrière-plan
          BlocBuilder<BackgroundDownloadCubit, BackgroundDownloadState>(
            builder: (context, state) {
              return ElevatedButton.icon(
                onPressed: () => _testBackgroundDownload(context),
                icon: const Icon(Icons.cloud_download),
                label: const Text('Test téléchargement arrière-plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _testSimpleNotification() async {
    final notificationService = NotificationService();
    await notificationService.initialize();

    await notificationService.showDownloadStarted(
      id: 1,
      title: 'Test notification',
      fileName: 'test_file.mp4',
    );

    debugPrint('✅ Notification de test envoyée');
  }

  void _testDownloadNotifications() async {
    final notificationService = NotificationService();
    await notificationService.initialize();

    const downloadId = 2;
    const fileName = 'test_download.mp4';

    // Notification de début
    await notificationService.showDownloadStarted(
      id: downloadId,
      title: 'Test téléchargement',
      fileName: fileName,
    );

    // Simuler la progression
    for (int i = 10; i <= 100; i += 20) {
      await Future.delayed(const Duration(seconds: 1));

      if (i < 100) {
        await notificationService.updateDownloadProgress(
          id: downloadId,
          fileName: fileName,
          progress: i / 100,
          status: 'Téléchargement... $i%',
        );
      } else {
        await notificationService.showDownloadCompleted(
          id: downloadId,
          fileName: fileName,
          filePath: '/storage/emulated/0/Download/$fileName',
        );
      }
    }

    debugPrint('✅ Test de notifications de téléchargement terminé');
  }

  void _testBackgroundDownload(BuildContext context) async {
    try {
      await context.read<BackgroundDownloadCubit>().startBackgroundDownload(
        url: 'https://example.com/test-video.mp4',
        title: 'Vidéo de test',
        fileName: 'test_background_video.mp4',
      );

      if (!context.mounted) return;
      ModernToast.show(
        context: context,
        message: 'Téléchargement en arrière-plan démarré',
        type: ToastType.success,
        title: '🚀 Test démarré',
      );
    } catch (e) {
      ModernToast.show(
        context: context,
        message: 'Erreur: $e',
        type: ToastType.error,
        title: '❌ Erreur',
      );
    }
  }
}
