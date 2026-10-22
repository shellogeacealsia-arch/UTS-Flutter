import 'package:flutter/material.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/constants/app_strings.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/pages/login_page.dart';
import 'package:bloomshop/pages/register_page.dart';
import 'package:bloomshop/widgets/bloom_logo.dart';
import 'package:bloomshop/widgets/primary_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.softPink, AppColors.cream],
            stops: [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _ProductComposition(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your Beauty Journey\nStarts Here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '${AppStrings.appName} brings skincare, makeup, body care '
                      'and hair care favourites together in one beautiful place.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        height: 1.5,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Get Started',
                      onPressed: () => Navigator.of(context)
                          .push(fadeSlideRoute<void>(const RegisterPage())),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'I Already Have an Account',
                      outlined: true,
                      onPressed: () => Navigator.of(context)
                          .push(fadeSlideRoute<void>(const LoginPage())),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Decorative composition of product images and the logo.
class _ProductComposition extends StatelessWidget {
  const _ProductComposition();

  Widget _bubble(String asset, double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x26B76E79),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.spa_outlined, color: AppColors.mutedRose),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 6,
            left: 14,
            child: _bubble(
              'assets/images/products/vitamin_c_serum.png',
              118,
              AppColors.categoryTint('Skincare'),
            ),
          ),
          Positioned(
            top: 40,
            right: 8,
            child: _bubble(
              'assets/images/products/matte_lipstick.png',
              126,
              AppColors.categoryTint('Make Up'),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 38,
            child: _bubble(
              'assets/images/products/shea_body_lotion.png',
              112,
              AppColors.categoryTint('Body Care'),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 40,
            child: _bubble(
              'assets/images/products/hair_serum.png',
              104,
              AppColors.categoryTint('Hair Care'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33B76E79),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const BloomLogo(size: 64),
          ),
        ],
      ),
    );
  }
}
