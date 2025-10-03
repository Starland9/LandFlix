import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/logic/cubits/download/download_cubit.dart';
import 'package:french_stream_downloader/src/logic/models/uqvideo.dart';
import 'package:french_stream_downloader/src/logic/services/download_manager.dart';
import 'package:french_stream_downloader/src/logic/services/uqload_download_service.dart';
import 'package:french_stream_downloader/src/logic/services/wishlist_manager.dart';
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
  bool isPreparing = false;
  bool _isAlreadyDownloaded = false;
  late final WishlistManager _wishlistManager;
  late final VoidCallback _wishlistListener;
  bool _isInWishlist = false;
  bool _isUpdatingWishlist = false;

  @override
  void initState() {
    super.initState();
    _downloadCubit = DownloadCubit(videoUrl: widget.uqvideo.htmlUrl);
    _wishlistManager = WishlistManager.instance;
    _wishlistListener = _handleWishlistChanged;
    _wishlistManager.wishlistNotifier.addListener(_wishlistListener);
    _checkIfDownloaded();
    _handleWishlistChanged();
  }

  void _checkIfDownloaded() {
    _isAlreadyDownloaded = DownloadManager.instance.isDownloaded(
      widget.uqvideo.htmlUrl,
    );
  }

  void _handleWishlistChanged() {
    final saved = _wishlistManager.contains(widget.uqvideo.htmlUrl);
    if (!mounted) return;
    if (saved != _isInWishlist) {
      setState(() {
        _isInWishlist = saved;
      });
    }
  }

  @override
  void dispose() {
    _wishlistManager.wishlistNotifier.removeListener(_wishlistListener);
    _downloadCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadCubit>(
      create: (context) => _downloadCubit,
      child: BlocListener<DownloadCubit, DownloadState>(
        listener: _onCubitListen,
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône de fichier vidéo
                _buildLeadingIcon(),
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
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          // Badge de taille
                          _buildSizeBadge(context),
                          const SizedBox(width: 8),
                          // Badge de qualité
                          _buildExtensionBadge(context),
                          // Badge "Téléchargé" si déjà téléchargé
                          if (_isAlreadyDownloaded) ...[
                            const SizedBox(width: 8),
                            const DownloadedBadge(),
                          ],
                        ],
                      ),

                      // Barre de progression si en téléchargement
                      _buildProgressBar(),
                    ],
                  ),
                ),

                const SizedBox(width: 16),
                // Bouton d'action
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWishlistButton(),
                    const SizedBox(height: 12),
                    _buildDownloadButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCubitListen(BuildContext context, DownloadState state) {
    if (state is DownloadCompleted) {
      setState(() {
        _isAlreadyDownloaded = true; // Marquer comme téléchargé
      });
      ModernToast.show(
        context: context,
        message: "Téléchargement terminé avec succès !",
        type: ToastType.success,
        title: "✅ Succès",
      );
    } else if (state is DownloadError) {
      ModernToast.show(
        context: context,
        message: state.message,
        type: ToastType.error,
        title: "❌ Erreur",
      );
    } else if (state is DownloadCancelled) {
      ModernToast.show(
        context: context,
        message: "Téléchargement annulé",
        type: ToastType.info,
        title: "ℹ️ Annulé",
      );
    }
  }

  Container _buildLeadingIcon() {
    return Container(
      width: 56,
      height: 56,
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
      child: const Icon(
        Icons.play_circle_fill_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Container _buildSizeBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3)),
      ),
      child: Text(
        UQLoadDownloadService.formatFileSize(widget.uqvideo.sizeInBytes),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.accentTeal,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Container _buildExtensionBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "MP4",
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  BlocBuilder<DownloadCubit, DownloadState> _buildProgressBar() {
    return BlocBuilder<DownloadCubit, DownloadState>(
      builder: (context, state) {
        if (state is DownloadInProgress) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "${state.percentage}%",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                  backgroundColor: AppColors.darkSurfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(
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
    );
  }

  Widget _buildDownloadButton() {
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
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _downloadCubit.cancelDownload(),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.error,
                size: 24,
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
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _startDownload(),
            child: isPreparing
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildWishlistButton() {
    final isDisabled = _isUpdatingWishlist;
    final icon = _isInWishlist
        ? Icons.favorite_rounded
        : Icons.favorite_outline_rounded;
    final color = _isInWishlist ? AppColors.primaryPurple : Colors.white;

    return Tooltip(
      message: _isInWishlist ? 'Retirer de ma liste' : 'Ajouter à ma liste',
      child: InkWell(
        onTap: isDisabled ? null : _toggleWishlist,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isInWishlist
                  ? AppColors.primaryPurple.withValues(alpha: 0.4)
                  : AppColors.darkSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
          child: isDisabled
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.4),
                )
              : Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  /// Lance le téléchargement avec UQLoad
  void _startDownload() async {
    // Utiliser l'URL htmlUrl du modèle Uqvideo pour UQLoad
    final uqloadUrl = widget.uqvideo.htmlUrl;

    if (UQLoadDownloadService.isValidUQLoadUrl(uqloadUrl)) {
      try {
        // Préparer les détails du téléchargement
        setState(() {
          isPreparing = true;
        });
        final details = await UQLoadDownloadService.prepareDownload(uqloadUrl);

        _downloadCubit.startBackgroundDownload(details);
      } catch (e) {
        if (mounted) {
          ModernToast.show(
            context: context,
            message: "Erreur lors de la préparation : $e",
            type: ToastType.error,
            title: "❌ Erreur",
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isPreparing = false;
          });
        }
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

  Future<void> _toggleWishlist() async {
    setState(() {
      _isUpdatingWishlist = true;
    });

    final wasSaved = _isInWishlist;
    try {
      await _wishlistManager.toggle(widget.uqvideo);
      if (!mounted) return;
      final added = !wasSaved;
      ModernToast.show(
        context: context,
        message: added
            ? 'Ajouté à votre liste avec succès.'
            : 'Retiré de votre liste.',
        type: added ? ToastType.success : ToastType.info,
        title: added ? '❤️ Ajouté' : '💔 Retiré',
      );
    } catch (e) {
      if (!mounted) return;
      ModernToast.show(
        context: context,
        message: 'Impossible de mettre à jour la liste : $e',
        type: ToastType.error,
        title: '❌ Erreur',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingWishlist = false;
        });
      }
    }
  }
}
