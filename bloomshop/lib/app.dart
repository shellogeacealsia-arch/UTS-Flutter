import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloomshop/core/constants/app_strings.dart';
import 'package:bloomshop/core/theme/app_theme.dart';
import 'package:bloomshop/pages/splash_page.dart';
import 'package:bloomshop/providers/auth_provider.dart';
import 'package:bloomshop/providers/cart_provider.dart';
import 'package:bloomshop/providers/favorite_provider.dart';
import 'package:bloomshop/providers/nav_provider.dart';
import 'package:bloomshop/providers/order_provider.dart';
import 'package:bloomshop/providers/profile_provider.dart';
import 'package:bloomshop/providers/settings_provider.dart';
import 'package:bloomshop/repositories/product_repository.dart';
import 'package:bloomshop/services/auth_service.dart';
import 'package:bloomshop/services/cart_service.dart';
import 'package:bloomshop/services/favorite_service.dart';
import 'package:bloomshop/services/order_service.dart';
import 'package:bloomshop/services/profile_service.dart';
import 'package:bloomshop/services/settings_service.dart';

class BloomShopApp extends StatefulWidget {
  const BloomShopApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<BloomShopApp> createState() => _BloomShopAppState();
}

class _BloomShopAppState extends State<BloomShopApp> {
  late final ProductRepository _repository = ProductRepository();

  @override
  Widget build(BuildContext context) {
    final prefs = widget.prefs;
    return MultiProvider(
      providers: [
        Provider<ProductRepository>.value(value: _repository),
        ChangeNotifierProvider<NavProvider>(create: (_) => NavProvider()),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(LocalAuthService(prefs)),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(ProfileService(prefs)),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(SettingsService(prefs)),
        ),
        ChangeNotifierProvider<FavoriteProvider>(
          create: (_) =>
              FavoriteProvider(FavoriteService(prefs), _repository)..load(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(CartService(prefs), _repository)..load(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(OrderService(prefs))..load(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashPage(),
      ),
    );
  }
}
