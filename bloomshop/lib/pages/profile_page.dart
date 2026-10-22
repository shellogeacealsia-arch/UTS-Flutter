import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/theme/app_theme.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/models/user_profile.dart';
import 'package:bloomshop/pages/edit_profile_page.dart';
import 'package:bloomshop/pages/my_orders_page.dart';
import 'package:bloomshop/pages/settings_page.dart';
import 'package:bloomshop/providers/profile_provider.dart';
import 'package:bloomshop/widgets/info_sheets.dart';
import 'package:bloomshop/widgets/logout_dialog.dart';
import 'package:bloomshop/widgets/menu_tile.dart';
import 'package:bloomshop/widgets/primary_button.dart';
import 'package:bloomshop/widgets/profile_avatar.dart';

/// Opened only from the profile icon at the top right of Home.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfile? profile =
        context.select<ProfileProvider, UserProfile?>((p) => p.profile);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Center(child: ProfileAvatar(profile: profile, radius: 54)),
          const SizedBox(height: 14),
          Text(
            profile?.name ?? 'Beauty Lover',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            profile?.email ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          if ((profile?.phone ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              profile!.phone,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
          const SizedBox(height: 18),
          Center(
            child: SizedBox(
              width: 200,
              child: PrimaryButton(
                label: 'Edit Profile',
                icon: Icons.edit_outlined,
                outlined: true,
                onPressed: () => Navigator.of(context)
                    .push(fadeSlideRoute<void>(const EditProfilePage())),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            decoration: AppTheme.card(),
            child: Column(
              children: [
                MenuTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'My Orders',
                  onTap: () => Navigator.of(context)
                      .push(fadeSlideRoute<void>(const MyOrdersPage())),
                ),
                const Divider(height: 1, indent: 70),
                MenuTile(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => Navigator.of(context)
                      .push(fadeSlideRoute<void>(const SettingsPage())),
                ),
                const Divider(height: 1, indent: 70),
                MenuTile(
                  icon: Icons.support_agent_outlined,
                  title: 'Help & Support',
                  onTap: () => showHelpSupportSheet(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Logout',
            icon: Icons.logout_rounded,
            outlined: true,
            onPressed: () => confirmLogout(context),
          ),
        ],
      ),
    );
  }
}
