import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/logic/cubits/download/download_cubit.dart';
import 'package:french_stream_downloader/src/logic/models/uqvideo.dart';
import 'package:french_stream_downloader/src/logic/services/download_manager.dart';
import 'package:french_stream_downloader/src/logic/services/uqload_download_service.dart';
import 'package:french_stream_downloader/src/shared/components/downloaded_badge.dart';
import 'package:french_stream_downloader/src/shared/components/modern_toast.dart';

class UqvideoWidget extends StatefulWidget {
  const UqvideoWidget({super.key, required this.uqvideo});

  final Uqvideo uqvideo;

  @override
  State<UqvideoWidget> createState() => _UqvideoWidgetState();
}

class _UqvideoWidgetState extends State<UqvideoWidget> {
  late DownloadCubit _downloadCubit;
  bool _isDownloading = false;
  bool _isAlreadyDownloaded = false;

  @override
  void initState() {
    super.initState();
    _downloadCubit = DownloadCubit();
    _checkIfDownloaded();
  }

  void _checkIfDownloaded() {
    _isAlreadyDownloaded = DownloadManager.instance.isDownloaded(
      widget.uqvideo.htmlUrl,
    );
  }

  @override
  void dispose() {
    _downloadCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadCubit>(
      create: (context) => _downloadCubit,
      child: BlocListener<DownloadCubit, DownloadState>(
        listener: (context, state) {
          if (state is DownloadInProgress) {
            setState(() {
              _isDownloading = true;
            });
          } else if (state is DownloadCompleted) {
            setState(() {
              _isDownloading = false;
              _isAlreadyDownloaded = true; // Marquer comme téléchargé
            });
            ModernToast.show(
              context: context,
              message: "Téléchargement terminé avec succès !",
              type: ToastType.success,
              title: "✅ Succès",
            );
          } else if (state is DownloadError) {
            setState(() {
              _isDownloading = false;
            });
            ModernToast.show(
              context: context,
              message: state.message,
              type: ToastType.error,
              title: "❌ Erreur",
            );
          } else if (state is DownloadCancelled) {
            setState(() {
              _isDownloading = false;
            });
            ModernToast.show(
              context: context,
              message: "Téléchargement annulé",
              type: ToastType.info,
              title: "ℹ️ Annulé",
            );
          } else {
            setState(() {
              _isDownloading = false;
            });
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _isDownloading ? null : () => _startDownload(),
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
                            color: AppColors.primaryPurple.withValues(
                              alpha: 0.3,
                            ),
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
                                  color: AppColors.accentTeal.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.accentTeal.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  UQLoadDownloadService.formatFileSize(
                                    widget.uqvideo.sizeInBytes,
                                  ),
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

                              // Badge "Téléchargé" si déjà téléchargé
                              if (_isAlreadyDownloaded) ...[
                                const SizedBox(width: 8),
                                const DownloadedBadge(),
                              ],
                            ],
                          ),

                          // Barre de progression si en téléchargement
                          BlocBuilder<DownloadCubit, DownloadState>(
                            builder: (context, state) {
                              if (state is DownloadInProgress) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            state.message,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          "${state.percentage}%",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
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
                                        value: state.progress,
                                        backgroundColor:
                                            AppColors.darkSurfaceVariant,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              AppColors.primaryPurple,
                                            ),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
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
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return BlocBuilder<DownloadCubit, DownloadState>(
      builder: (context, state) {
        if (state is DownloadInProgress) {
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _downloadCubit.cancelDownload(),
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
                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _startDownload(),
              child: const Icon(
                Icons.download_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Lance le téléchargement avec UQLoad
  void _startDownload() async {
    // Utiliser l'URL htmlUrl du modèle Uqvideo pour UQLoad
    final uqloadUrl = widget.uqvideo.htmlUrl;

    if (UQLoadDownloadService.isValidUQLoadUrl(uqloadUrl)) {
      try {
        final details = await UQLoadDownloadService.prepareDownload(uqloadUrl);
        _downloadCubit.startBackgroundDownload(details);
      } catch (e) {
        ModernToast.show(
          context: context,
          message: "Erreur lors de la préparation : $e",
          type: ToastType.error,
          title: "❌ Erreur",
        );
      }
    } else {
      ModernToast.show(
        context: context,
        message: "URL non compatible avec UQLoad",
        type: ToastType.error,
        title: "❌ Erreur",
      );
    }
  }
}
