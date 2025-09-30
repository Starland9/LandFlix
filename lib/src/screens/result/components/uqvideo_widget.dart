import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/components/modern_toast.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/logic/models/uqvideo.dart';
import 'package:path_provider/path_provider.dart';

class UqvideoWidget extends StatefulWidget {
  const UqvideoWidget({super.key, required this.uqvideo});

  final Uqvideo uqvideo;

  @override
  State<UqvideoWidget> createState() => _UqvideoWidgetState();
}

class _UqvideoWidgetState extends State<UqvideoWidget> {
  final Dio _dio = Dio();
  bool _isDownloading = false;
  double _progress = 0.0;
  CancelToken _cancelToken = CancelToken();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isDownloading ? null : () => _download(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône de fichier vidéo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Informations de la vidéo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.uqvideo.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          // Badge de taille
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.accentTeal.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _formatFileSize(widget.uqvideo.sizeInBytes),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.accentTeal,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Badge de qualité
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "MP4",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                            ),
                          ),
                        ],
                      ),

                      // Barre de progression si en téléchargement
                      if (_isDownloading) ...[
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Téléchargement en cours...",
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                ),
                                Text(
                                  "${(_progress * 100).toInt()}%",
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.primaryPurple,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progress,
                                backgroundColor: AppColors.darkSurfaceVariant,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryPurple,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Bouton d'action
                _buildActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (_isDownloading) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _cancelDownload,
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.error,
              size: 24,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _download(context),
          child: const Icon(
            Icons.download_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
    } else if (bytes >= 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    } else if (bytes >= 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    } else {
      return "$bytes B";
    }
  }

  void _cancelDownload() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel();
    }
    setState(() {
      _isDownloading = false;
      _progress = 0.0;
    });
  }

  Future<void> _download(BuildContext context) async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _cancelToken = CancelToken();
    });

    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception("Could not get downloads directory");
      }
      final filePath = '${directory.path}/${widget.uqvideo.title}.mp4';

      final uri = Uri.parse(widget.uqvideo.url);
      final scheme = uri.scheme;
      final netloc = uri.host;

      final headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
        'Accept':
            "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        "Referer": "$scheme://$netloc",
      };

      final response = await _dio.get(
        widget.uqvideo.url,
        options: Options(headers: headers),
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      if (response.data == null || response.data != List<int>) {
        throw Exception("Could not download video");
      }

      final file = File(filePath);
      await file.writeAsBytes(response.data);

      if (!_cancelToken.isCancelled && context.mounted) {
        ModernToast.show(
          context: context,
          message: "Téléchargement terminé avec succès !",
          type: ToastType.success,
          title: "✅ Succès",
        );
      }
    } on DioException catch (error) {
      if (!CancelToken.isCancel(error) && context.mounted) {
        ModernToast.show(
          context: context,
          message: "Erreur lors du téléchargement: ${error.message}",
          type: ToastType.error,
          title: "❌ Erreur",
        );
      }
    } catch (error) {
      if (context.mounted) {
        ModernToast.show(
          context: context,
          message: "Erreur inattendue: $error",
          type: ToastType.error,
          title: "❌ Erreur",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _progress = 0.0;
        });
      }
    }
  }
}
