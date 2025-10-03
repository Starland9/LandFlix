import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/logic/models/wishlist_item.dart';
import 'package:french_stream_downloader/src/logic/services/download_manager.dart';
import 'package:french_stream_downloader/src/logic/services/uqload_download_service.dart';
import 'package:french_stream_downloader/src/logic/services/wishlist_manager.dart';
import 'package:french_stream_downloader/src/screens/wishlist/components/wishlist_collection_view.dart';
import 'package:french_stream_downloader/src/screens/wishlist/components/wishlist_empty_state.dart';
import 'package:french_stream_downloader/src/screens/wishlist/components/wishlist_header.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page listant les contenus enregistrés par l’utilisateur.
@RoutePage()
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

/// Gère les animations d’apparition et la source des données favorites.
class _WishlistScreenState extends State<WishlistScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late final WishlistManager _wishlistManager;
  final Set<String> _downloadingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _wishlistManager = WishlistManager.instance;
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              Color(0xFF1A0A2E),
              AppColors.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const WishlistHeader(),

                // Contenu principal : affiche les favoris (ou l’état vide si nécessaire).
                Expanded(
                  child: ValueListenableBuilder<List<WishlistItem>>(
                    valueListenable: _wishlistManager.wishlistNotifier,
                    builder: (context, items, _) {
                      final child = items.isEmpty
                          ? const WishlistEmptyState()
                          : WishlistCollectionView(
                              key: ValueKey<int>(items.length),
                              items: items,
                              downloadingIds: _downloadingIds,
                              onRemove: _removeWishlistItem,
                              onDownload: _downloadWishlistItem,
                              onOpen: _openWishlistItem,
                            );

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: child,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _removeWishlistItem(WishlistItem item) async {
    await _wishlistManager.remove(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('“${item.title}” retiré de votre liste.')),
    );
  }

  Future<void> _downloadWishlistItem(WishlistItem item) async {
    if (DownloadManager.instance.isDownloaded(item.htmlUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('“${item.title}” est déjà téléchargé.')),
      );
      return;
    }

    if (_downloadingIds.contains(item.id)) {
      return;
    }

    setState(() {
      _downloadingIds.add(item.id);
    });

    try {
      final details = await UQLoadDownloadService.prepareDownload(item.htmlUrl);
      await UQLoadDownloadService.startBackgroundDownload(details: details);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Téléchargement lancé pour “${item.title}”.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de lancer le téléchargement : $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloadingIds.remove(item.id);
        });
      }
    }
  }

  Future<void> _openWishlistItem(WishlistItem item) async {
    final uri = Uri.parse(item.htmlUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d’ouvrir “${item.title}”.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’ouverture : $e')),
      );
    }
  }
}
