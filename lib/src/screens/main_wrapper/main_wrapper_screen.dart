import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/routing/app_router.gr.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/screens/downloads/downloads_screen.dart';
import 'package:french_stream_downloader/src/screens/home/home_screen.dart';
import 'package:french_stream_downloader/src/screens/wishlist/wishlist_screen.dart';
import 'package:french_stream_downloader/src/shared/components/ripple_floating_button.dart';
import 'package:french_stream_downloader/src/shared/components/background_download_indicator.dart';

@RoutePage()
class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WishlistScreen(),
    const DownloadsScreen(),
  ];

  final List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Accueil',
    ),
    BottomNavItem(
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Ma Liste',
    ),
    BottomNavItem(
      icon: Icons.download_outlined,
      activeIcon: Icons.download_rounded,
      label: 'Téléchargements',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _screens,
          ),
          
          // Indicateur de téléchargements en arrière-plan
          BackgroundDownloadIndicator(
            onTap: () {
              // TODO: Naviguer vers l'écran des téléchargements en arrière-plan
              // AutoRouter.of(context).push(const BackgroundDownloadsRoute());
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNav(),
      floatingActionButton: _currentIndex == 1 ? _buildSearchFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSearchFAB() {
    return RippleFloatingButton(
      onPressed: () {
        // Revenir à l'accueil pour faire une recherche
        _onNavItemTapped(0);
      },
      icon: Icons.search_rounded,
      tooltip: "Rechercher du contenu",
      size: 60,
      showRipple: true,
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        border: Border(
          top: BorderSide(
            color: AppColors.primaryPurple.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _navItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isActive = index == _currentIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => _onNavItemTapped(index),
                child: SizedBox(
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Indicateur de sélection
                      AnimatedContainer(
                        padding: const EdgeInsets.all(2),
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? 120 : 0,
                        height: isActive ? 60 : 0,
                        decoration: BoxDecoration(
                          gradient: isActive ? AppColors.primaryGradient : null,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                      ),

                      // Contenu de l'icône
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            scale: isActive ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              isActive ? item.activeIcon : item.icon,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textTertiary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: isActive
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontSize: 11,
                                ),
                            duration: const Duration(milliseconds: 300),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
