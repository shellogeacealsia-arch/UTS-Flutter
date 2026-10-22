import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/constants/app_strings.dart';
import 'package:bloomshop/core/theme/app_theme.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/pages/edit_profile_page.dart';
import 'package:bloomshop/providers/settings_provider.dart';
import 'package:bloomshop/widgets/info_sheets.dart';
import 'package:bloomshop/widgets/logout_dialog.dart';
import 'package:bloomshop/widgets/menu_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _group(List<Widget> children) {
    final separated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      separated.add(children[i]);
      if (i < children.length - 1) {
        separated.add(const Divider(height: 1, indent: 70));
      }
    }
    return Container(
      decoration: AppTheme.card(),
      child: Column(children: separated),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 0, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          _label('Account'),
          _group([
            MenuTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () => Navigator.of(context)
                  .push(fadeSlideRoute<void>(const EditProfilePage())),
            ),
          ]),
          _label('Notifications (demo)'),
          _group([
            MenuTile(
              icon: Icons.notifications_none_rounded,
              title: 'Promo notifications',
              subtitle: 'Show the bell icon & promo inbox on Home',
              onTap: () => settings
                  .setPromoNotifications(!settings.promoNotifications),
              trailing: Switch(
                value: settings.promoNotifications,
                onChanged: settings.setPromoNotifications,
              ),
            ),
            MenuTile(
              icon: Icons.local_shipping_outlined,
              title: 'Order status alerts',
              subtitle: 'Show a message when an order status changes',
              onTap: () => settings.setOrderAlerts(!settings.orderAlerts),
              trailing: Switch(
                value: settings.orderAlerts,
                onChanged: settings.setOrderAlerts,
              ),
            ),
          ]),
          _label('About'),
          _group([
            MenuTile(
              icon: Icons.info_outline,
              title: 'About ${AppStrings.appName}',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: AppStrings.appName,
                applicationVersion: '1.0.0',
                applicationLegalese: 'Demo marketplace app. ${AppStrings.tagline}',
              ),
            ),
            MenuTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => showPrivacySheet(context),
            ),
            MenuTile(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () => showTermsSheet(context),
            ),
            MenuTile(
              icon: Icons.support_agent_outlined,
              title: 'Help & Support',
              onTap: () => showHelpSupportSheet(context),
            ),
          ]),
          const SizedBox(height: 18),
          _group([
            MenuTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              destructive: true,
              onTap: () => confirmLogout(context),
            ),
          ]),
        ],
      ),
    );
  }
}
