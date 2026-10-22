import 'package:flutter/material.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/constants/app_strings.dart';

Future<void> _showSheet(BuildContext context, String title, Widget body) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          body,
        ],
      ),
    ),
  );
}

Widget _paragraphs(List<String> texts) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final t in texts)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(t, style: const TextStyle(height: 1.5)),
        ),
    ],
  );
}

Future<void> showHelpSupportSheet(BuildContext context) {
  const faqs = <List<String>>[
    ['How do I place an order?', 'Add products to your cart, open Cart and tap Proceed to Checkout.'],
    ['Is payment real?', 'No. BloomShop is a demo - payments and deliveries are simulated.'],
    ['Where can I see my orders?', 'Profile > My Orders. You can open any order to see its details.'],
    ['How do I change my photo?', 'Profile > Edit Profile > tap the photo.'],
  ];
  return _showSheet(
    context,
    'Help & Support',
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final faq in faqs)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(faq[0], style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(faq[1], style: const TextStyle(height: 1.45)),
              ],
            ),
          ),
        const Divider(),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.mail_outline, color: AppColors.mutedRose),
          title: Text('support@bloomshop.example'),
          subtitle: Text('Demo address - no real mailbox'),
        ),
      ],
    ),
  );
}

Future<void> showPrivacySheet(BuildContext context) {
  return _showSheet(
    context,
    'Privacy Policy (Demo)',
    _paragraphs(const [
      'This is a demonstration policy for the BloomShop sample app.',
      'Your profile, cart, favorites and orders are stored only on this device using local storage. Nothing is sent to a server.',
      'Passwords are stored as salted hashes, but local authentication is for demonstration and is not suitable for production use.',
    ]),
  );
}

Future<void> showTermsSheet(BuildContext context) {
  return _showSheet(
    context,
    'Terms & Conditions (Demo)',
    _paragraphs(const [
      '${AppStrings.appName} is a sample application created for learning purposes.',
      'Products, prices and brands are fictional. Orders, payments and shipping are simulated and no real transaction takes place.',
      'By using the demo you agree that it is provided as is, without warranty.',
    ]),
  );
}
