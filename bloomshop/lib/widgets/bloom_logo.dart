import 'package:flutter/material.dart';

import 'package:bloomshop/core/constants/app_colors.dart';

/// BloomShop flower logo (assets/images/logo.png) with an icon fallback.
class BloomLogo extends StatelessWidget {
  const BloomLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.local_florist,
        size: size,
        color: AppColors.mutedRose,
      ),
    );
  }
}
