import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/pages/welcome_page.dart';
import 'package:bloomshop/providers/auth_provider.dart';
import 'package:bloomshop/providers/nav_provider.dart';
import 'package:bloomshop/providers/profile_provider.dart';

/// Shows the confirmation dialog and, if confirmed, ends the session.
/// Orders, favorites, cart and preferences stay stored on the device.
Future<void> confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Logout'),
      content: const Text('Are you sure you want to log out of BloomShop?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Logout'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final auth = context.read<AuthProvider>();
  final profile = context.read<ProfileProvider>();
  final nav = context.read<NavProvider>();
  final navigator = Navigator.of(context);

  await auth.logout();
  profile.clear();
  nav.setIndex(0);
  navigator.pushAndRemoveUntil(
    fadeSlideRoute<void>(const WelcomePage()),
    (route) => false,
  );
}
