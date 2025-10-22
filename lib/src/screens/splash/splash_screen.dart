import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/routing/app_router.gr.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/logic/services/app_infos_service.dart';
import 'package:french_stream_downloader/src/logic/services/version_check_service.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    // Contrôleurs d'animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animations du logo
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Animations du texte
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // Animation de la barre de progression
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Séquence d'animations
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Démarrer l'animation du logo
    _logoController.forward();

    // Attendre un peu puis démarrer le texte
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    // Démarrer la progression
    await Future.delayed(const Duration(milliseconds: 200));
    _progressController.forward();

    // Vérifier la version en parallèle des animations
    final versionCheckFuture = VersionCheckService().isUpdateAvailable();

    // Attendre la fin des animations
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Vérifier si une mise à jour est nécessaire
    final updateAvailable = await versionCheckFuture;

    if (updateAvailable) {
      // Récupérer la dernière version
      final latestVersion = await VersionCheckService().getLatestVersion();

      if (mounted && latestVersion != null) {
        context.router.pushAndPopUntil(
          UpdateRequiredRoute(latestVersion: latestVersion),
          predicate: (route) => false,
        );
        return;
      }
    }

    // Naviguer vers la page principale si pas de mise à jour
    if (mounted) {
      context.router.pushAndPopUntil(
        const MainWrapperRoute(),
        predicate: (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBackground,
              Color(0xFF1A0A2E),
              Color(0xFF16213E),
              AppColors.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Contenu principal
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo animé
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(35),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryPurple.withValues(
                                        alpha: 0.6,
                                      ),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 60,
                                      spreadRadius: 15,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(35),
                                  child: Hero(
                                    tag: "icon",
                                    child: Image.asset(
                                      "assets/icon/icon.jpeg",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Texte animé
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _textSlide,
                            child: FadeTransition(
                              opacity: _textOpacity,
                              child: Column(
                                children: [
                                  // Titre principal avec gradient
                                  ShaderMask(
                                    shaderCallback: (bounds) => AppColors
                                        .primaryGradient
                                        .createShader(bounds),
                                    child: Text(
                                      "LandFlix",
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: -1.5,
                                          ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Sous-titre
                                  Text(
                                    "Votre passerelle vers l'univers du streaming",
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 16,
                                          letterSpacing: 0.5,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 8),

                                  // Version
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      AppInfosService().version ?? "v1.0.0",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Barre de progression et crédit
              Column(
                children: [
                  // Barre de progression
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Container(
                        width: 200,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: 200 * _progressValue.value,
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Texte de chargement
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      final loadingTexts = [
                        "Initialisation...",
                        "Préparation de l'interface...",
                        "Configuration des services...",
                        "Finalisation...",
                        "Prêt !",
                      ];

                      final currentIndex =
                          (_progressValue.value * (loadingTexts.length - 1))
                              .round();

                      return FadeTransition(
                        opacity: _textOpacity,
                        child: Text(
                          loadingTexts[currentIndex],
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 14,
                              ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Crédit
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Text(
                      "Made with ❤️ by Landry",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
