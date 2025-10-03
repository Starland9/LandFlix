import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';

class EmptyState extends StatelessWidget {
  final Animation<double> fadeAnimation;
  const EmptyState({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: AppColors.primaryPurple.withAlpha(77),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.download_outlined,
                  size: 60,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Aucun téléchargement",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Vos téléchargements apparaîtront ici une fois terminés.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
