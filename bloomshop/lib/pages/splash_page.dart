import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/constants/app_strings.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/pages/home_page.dart';
import 'package:bloomshop/pages/welcome_page.dart';
import 'package:bloomshop/providers/auth_provider.dart';
import 'package:bloomshop/providers/profile_provider.dart';
import 'package:bloomshop/widgets/bloom_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<double> _scale = Tween<double>(begin: 0.8, end: 1)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _boot();
  }

  Future<void> _boot() async {
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    await Future.wait<void>([
      _restoreSession(auth, profile),
      Future<void>.delayed(const Duration(milliseconds: 2200)),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      fadeSlideRoute<void>(
        auth.isLoggedIn ? const HomePage() : const WelcomePage(),
      ),
    );
  }

  /// Never blocks the splash: any error just means "not logged in".
  Future<void> _restoreSession(
    AuthProvider auth,
    ProfileProvider profile,
  ) async {
    try {
      final result = await auth.restoreSession();
      if (result.success) {
        await profile.loadFor(
          result.email!,
          fallbackName: result.name ?? 'Beauty Lover',
        );
      }
    } catch (_) {
      // ignore - user will see the Welcome screen
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.softPink, AppColors.cream],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BloomLogo(size: 120),
                  const SizedBox(height: 18),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBrown,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.tagline,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: AppColors.mutedRose,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
