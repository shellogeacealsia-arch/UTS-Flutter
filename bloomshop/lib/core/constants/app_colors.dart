import 'package:flutter/material.dart';

/// Central colour palette of BloomShop.
class AppColors {
  AppColors._();

  static const Color softPink = Color(0xFFF7C8D0);
  static const Color blushPink = Color(0xFFE9A3B0);
  static const Color cream = Color(0xFFFFF8F0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkBrown = Color(0xFF49383D);
  static const Color mutedRose = Color(0xFFB76E79);

  static const Color textMuted = Color(0xFF8A7A7F);
  static const Color border = Color(0xFFF0DFE2);
  static const Color success = Color(0xFF5E9B7A);
  static const Color warning = Color(0xFFD9962F);
  static const Color error = Color(0xFFC85A6A);
  static const Color star = Color(0xFFF2B33D);
  static const Color mauve = Color(0xFF8E6FA8);

  /// Soft background tint per product category (matches the product artwork).
  static Color categoryTint(String category) {
    switch (category) {
      case 'Skincare':
        return const Color(0xFFFBE0E4);
      case 'Make Up':
        return const Color(0xFFF7C8D0);
      case 'Body Care':
        return const Color(0xFFFFE8D6);
      case 'Hair Care':
        return const Color(0xFFEBDDF0);
      default:
        return softPink;
    }
  }
}
