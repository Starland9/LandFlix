import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/screens/wishlist/components/wishlist_collection_view.dart';
import 'package:french_stream_downloader/src/screens/wishlist/components/wishlist_header.dart';

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
  // TODO(starland): brancher un vrai service de persistance.
  final List<String> _wishlistItems = [];

  @override
  void initState() {
    super.initState();
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: WishlistCollectionView(
                      key: ValueKey<int>(_wishlistItems.length),
                      items: _wishlistItems,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
