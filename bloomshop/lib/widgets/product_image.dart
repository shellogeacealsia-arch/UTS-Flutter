import 'package:flutter/material.dart';

import 'package:bloomshop/core/constants/app_colors.dart';

/// Local asset image with a tidy category-coloured fallback.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imagePath,
    required this.category,
    this.fit = BoxFit.cover,
  });

  final String imagePath;
  final String category;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final tint = AppColors.categoryTint(category);
    return ColoredBox(
      color: tint,
      child: Image.asset(
        imagePath,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.spa_outlined,
            size: 40,
            color: AppColors.mutedRose.withAlpha(160),
          ),
        ),
      ),
    );
  }
}
