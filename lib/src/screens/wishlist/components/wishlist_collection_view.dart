import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';
import 'package:french_stream_downloader/src/screens/wishlist/components/wishlist_empty_state.dart';

/// Affichage principal de la collection de favoris.
///
/// Pour l’instant il s’agit d’un simple placeholder qui présente les éléments
/// sous forme de liste verticale. Lorsque la liste est vide, on délègue
/// directement au composant [`WishlistEmptyState`].
class WishlistCollectionView extends StatelessWidget {
  final List<String> items;

  const WishlistCollectionView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const WishlistEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.1),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            leading: const Icon(
              Icons.movie_outlined,
              color: AppColors.textSecondary,
            ),
            title: Text(
              item,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Ajouté récemment',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }
}
