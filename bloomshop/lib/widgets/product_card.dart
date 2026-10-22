import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/theme/app_theme.dart';
import 'package:bloomshop/core/utils/formatters.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/core/utils/ui_helpers.dart';
import 'package:bloomshop/models/product.dart';
import 'package:bloomshop/pages/product_detail_page.dart';
import 'package:bloomshop/providers/favorite_provider.dart';
import 'package:bloomshop/widgets/product_image.dart';

void openProductDetail(BuildContext context, Product product) {
  Navigator.of(context).push(fadeSlideRoute(ProductDetailPage(product: product)));
}

/// Small heart button used on cards. Reads/updates FavoriteProvider.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.product, this.size = 32});

  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isFav = context
        .select<FavoriteProvider, bool>((f) => f.isFavorite(product.id));
    return Material(
      color: AppColors.white.withAlpha(235),
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          final added = await context.read<FavoriteProvider>().toggle(product);
          if (!context.mounted) return;
          showAppSnackBar(
            context,
            added ? 'Added to favorites' : 'Removed from favorites',
          );
        },
        child: SizedBox(
          width: size,
          height: size,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              key: ValueKey<bool>(isFav),
              size: size * 0.56,
              color: AppColors.mutedRose,
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
        const SizedBox(width: 2),
        Text(
          product.rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '(${Formatters.compactCount(product.reviewCount)})',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

/// Vertical product card (grid + Best Sellers list).
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: AppTheme.card(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => openProductDetail(context, product),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductImage(
                      imagePath: product.imagePath,
                      category: product.category,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FavoriteButton(product: product),
                    ),
                    if (product.hasDiscount)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mutedRose,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${product.discountPercent}%',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 34,
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      product.brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            Formatters.rupiah(product.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mutedRose,
                            ),
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              Formatters.rupiah(product.originalPrice!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    _RatingRow(product: product),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact horizontal card (New Arrivals list).
class ProductRowCard extends StatelessWidget {
  const ProductRowCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: AppTheme.card(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => openProductDetail(context, product),
          child: Row(
            children: [
              SizedBox(
                width: 108,
                height: double.infinity,
                child: ProductImage(
                  imagePath: product.imagePath,
                  category: product.category,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softPink,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.mutedRose,
                              ),
                            ),
                          ),
                          const Spacer(),
                          FavoriteButton(product: product, size: 26),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.rupiah(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedRose,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
