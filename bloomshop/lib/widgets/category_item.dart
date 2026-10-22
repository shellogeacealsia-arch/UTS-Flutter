import 'package:flutter/material.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/constants/app_strings.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  static IconData iconFor(String category) {
    switch (category) {
      case AppStrings.skincare:
        return Icons.spa_outlined;
      case AppStrings.makeUp:
        return Icons.brush_outlined;
      case AppStrings.bodyCare:
        return Icons.water_drop_outlined;
      case AppStrings.hairCare:
        return Icons.auto_awesome_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SizedBox(
        width: 78,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.mutedRose
                    : AppColors.categoryTint(name),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                iconFor(name),
                size: 26,
                color: selected ? AppColors.white : AppColors.mutedRose,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
