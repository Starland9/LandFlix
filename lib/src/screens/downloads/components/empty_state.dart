import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';

/// Contenu décoré pour les états vides des écrans de téléchargement.
class DownloadsEmptyContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? tip;
  final IconData tipIcon;

  const DownloadsEmptyContent({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.tip,
    this.tipIcon = Icons.lightbulb_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(icon, size: 60, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            // if (tip != null) ...[
            //   const SizedBox(height: 32),
            //   Container(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 24,
            //       vertical: 16,
            //     ),
            //     decoration: BoxDecoration(
            //       gradient: AppColors.cardGradient,
            //       borderRadius: BorderRadius.circular(16),
            //       border: Border.all(
            //         color: AppColors.primaryPurple.withValues(alpha: 0.2),
            //       ),
            //     ),
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Icon(tipIcon, color: AppColors.accentOrange, size: 20),
            //         const SizedBox(width: 12),
            //         Text(
            //           tip!,
            //           style: Theme.of(context).textTheme.bodySmall?.copyWith(
            //             color: AppColors.textSecondary,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}

/// Animation d’apparition pour l’état vide des téléchargements.
class EmptyState extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const EmptyState({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: const DownloadsEmptyContent(
        icon: Icons.download_outlined,
        title: 'Aucun téléchargement',
        description: 'Vos téléchargements apparaîtront ici une fois terminés.',
        tip: 'Astuce : Lancez un téléchargement depuis la fiche d’un contenu.',
      ),
    );
  }
}
