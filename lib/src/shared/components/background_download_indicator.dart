import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/themes/colors.dart';
import '../../logic/cubits/background_download/background_download_cubit.dart';

/// Widget d'indicateur de téléchargements en arrière-plan
class BackgroundDownloadIndicator extends StatefulWidget {
  final VoidCallback? onTap;

  const BackgroundDownloadIndicator({super.key, this.onTap});

  @override
  State<BackgroundDownloadIndicator> createState() =>
      _BackgroundDownloadIndicatorState();
}

class _BackgroundDownloadIndicatorState
    extends State<BackgroundDownloadIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
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
        if (state is BackgroundDownloadUpdated) {
          final hasActiveDownloads = state.activeDownloads.isNotEmpty;
          if (hasActiveDownloads) {
            _pulseController.repeat(reverse: true);
          } else {
            _pulseController.stop();
            _pulseController.reset();
          }
        }
      },
      builder: (context, state) {
        if (state is! BackgroundDownloadUpdated) {
          return const SizedBox.shrink();
        }

        final totalDownloads = state.totalDownloads;
        final activeDownloads = state.activeDownloads.length;

        if (totalDownloads == 0) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: activeDownloads > 0
                      ? AppColors.primaryGradient
                      : LinearGradient(
                          colors: [
                            Colors.grey.withValues(alpha: 0.8),
                            Colors.grey.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (activeDownloads > 0
                                  ? AppColors.primaryPurple
                                  : Colors.grey)
                              .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      activeDownloads > 0
                          ? Icons.download_rounded
                          : Icons.download_done_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$totalDownloads',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    if (activeDownloads > 0) ...[
                      const SizedBox(width: 4),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
