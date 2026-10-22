import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/theme/app_theme.dart';
import 'package:bloomshop/core/utils/formatters.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/core/utils/ui_helpers.dart';
import 'package:bloomshop/models/product.dart';
import 'package:bloomshop/pages/product_detail_page.dart';
import 'package:bloomshop/providers/cart_provider.dart';
import 'package:bloomshop/providers/favorite_provider.dart';
import 'package:bloomshop/providers/nav_provider.dart';
import 'package:bloomshop/widgets/empty_state.dart';
import 'package:bloomshop/widgets/product_image.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoriteProvider>();
    final items = favorites.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        automaticallyImplyLeading: false,
      ),
      body: !favorites.isLoaded
          ? const LoadingState()
          : items.isEmpty
              ? EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'Your favorites will bloom here',
                  message:
                      'Tap the heart on any product to save it for later.',
                  actionLabel: 'Explore Products',
                  onAction: () => context.read<NavProvider>().setIndex(0),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FavoriteTile(product: items[index]),
                  ),
                ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: AppTheme.card(),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context)
            .push(fadeSlideRoute<void>(ProductDetailPage(product: product))),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 84,
                height: 84,
                child: ProductImage(
                  imagePath: product.imagePath,
                  category: product.category,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.brand,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.rupiah(product.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedRose,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  tooltip: 'Remove from favorites',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.favorite, color: AppColors.mutedRose),
                  onPressed: () async {
                    // Capture before awaiting: this tile leaves the tree.
                    final favorites = context.read<FavoriteProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    await favorites.remove(product);
                    showAppSnackBarOn(
                      messenger,
                      'Removed from favorites',
                      actionLabel: 'Undo',
                      onAction: () => favorites.toggle(product),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Add to cart',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.add_shopping_cart_rounded,
                    color: AppColors.darkBrown,
                  ),
                  onPressed: product.inStock
                      ? () async {
                          final ok =
                              await context.read<CartProvider>().add(product);
                          if (!context.mounted) return;
                          showAppSnackBar(
                            context,
                            ok
                                ? 'Added to cart'
                                : 'Maximum stock already in cart',
                          );
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
