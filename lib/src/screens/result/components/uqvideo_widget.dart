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
            child: Column(
              children: [
                Row(
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

                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              // Badge de taille
                              _buildSizeBadge(context),
                              // Badge de qualité
                              _buildExtensionBadge(context),
                              // Badge "Téléchargé" si déjà téléchargé
                              if (_isAlreadyDownloaded)
                                const DownloadedBadge(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Barre de progression si en téléchargement
                _buildProgressBar(),

                // Boutons d'action en bas
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildWishlistButton()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDownloadButton()),
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
          return ElevatedButton.icon(
            onPressed: () => _downloadCubit.cancelDownload(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.15),
              foregroundColor: AppColors.error,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
              ),
            ),
            icon: const Icon(Icons.close_rounded, size: 20),
            label: Text(
              'Annuler',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          );
        }

        return ElevatedButton.icon(
          onPressed: isPreparing ? null : () => _startDownload(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: AppColors.primaryPurple.withValues(alpha: 0.3),
          ),
          icon: isPreparing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.download_rounded, size: 20),
          label: Text(
            isPreparing ? 'Préparation…' : 'Télécharger',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
    final label = _isInWishlist ? 'Ma liste' : 'Ajouter';

    return OutlinedButton.icon(
      onPressed: isDisabled ? null : _toggleWishlist,
      style: OutlinedButton.styleFrom(
        foregroundColor: _isInWishlist ? AppColors.primaryPurple : AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        side: BorderSide(
          color: _isInWishlist
              ? AppColors.primaryPurple.withValues(alpha: 0.4)
              : AppColors.darkSurfaceVariant.withValues(alpha: 0.4),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: isDisabled
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            )
          : Icon(icon, size: 20),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
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
