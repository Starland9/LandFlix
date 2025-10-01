import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/cubits/background_download/background_download_cubit.dart';
import '../../shared/components/modern_toast.dart';
import '../../core/themes/colors.dart';

/// Bouton pour démarrer un téléchargement en arrière-plan
class BackgroundDownloadButton extends StatefulWidget {
  final String url;
  final String title;
  final String? fileName;
  final String? outputDir;
  final VoidCallback? onDownloadStarted;

  const BackgroundDownloadButton({
    super.key,
    required this.url,
    required this.title,
    this.fileName,
    this.outputDir,
    this.onDownloadStarted,
  });

  @override
  State<BackgroundDownloadButton> createState() => _BackgroundDownloadButtonState();
}

class _BackgroundDownloadButtonState extends State<BackgroundDownloadButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BackgroundDownloadCubit, BackgroundDownloadState>(
      listener: (context, state) {
        setState(() {
          _isStarting = state is BackgroundDownloadStarting;
        });

        if (state is BackgroundDownloadStarted) {
          _pulseController.repeat(reverse: true);
          widget.onDownloadStarted?.call();
          
          ModernToast.show(
            context: context,
            message: 'Téléchargement démarré en arrière-plan',
            type: ToastType.success,
            title: '📥 Succès',
          );
        } else if (state is BackgroundDownloadError) {
          _pulseController.stop();
          
          ModernToast.show(
            context: context,
            message: state.message,
            type: ToastType.error,
            title: '❌ Erreur',
          );
        }
      },
      builder: (context, state) {
        final isDownloading = state is BackgroundDownloadUpdated &&
            state.isDownloading(widget.url);

        return ScaleTransition(
          scale: _pulseAnimation,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDownloading || _isStarting ? null : _startBackgroundDownload,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isDownloading
                      ? LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.8),
                            Colors.green.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : _isStarting
                          ? LinearGradient(
                              colors: [
                                AppColors.primaryPurple.withOpacity(0.8),
                                AppColors.primaryPurple.withOpacity(0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isDownloading ? Colors.green : AppColors.primaryPurple)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isStarting) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ] else if (isDownloading) ...[
                      const Icon(
                        Icons.cloud_download_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ] else ...[
                      const Icon(
                        Icons.download_for_offline_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      _isStarting
                          ? 'Démarrage...'
                          : isDownloading
                              ? 'En cours'
                              : 'Télécharger',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _startBackgroundDownload() async {
    setState(() {
      _isStarting = true;
    });

    await context.read<BackgroundDownloadCubit>().startBackgroundDownload(
          url: widget.url,
          title: widget.title,
          fileName: widget.fileName,
          outputDir: widget.outputDir,
        );
  }
}