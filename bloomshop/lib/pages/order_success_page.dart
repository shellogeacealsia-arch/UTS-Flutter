import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/constants/app_strings.dart';
import 'package:bloomshop/core/theme/app_theme.dart';
import 'package:bloomshop/core/utils/formatters.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/models/order.dart';
import 'package:bloomshop/pages/my_orders_page.dart';
import 'package:bloomshop/providers/nav_provider.dart';
import 'package:bloomshop/widgets/primary_button.dart';

class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({super.key, required this.order});

  final Order order;

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continueShopping() {
    final nav = context.read<NavProvider>();
    Navigator.of(context).popUntil((route) => route.isFirst);
    nav.setIndex(0);
  }

  void _viewOrders() {
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    navigator.push(fadeSlideRoute<void>(const MyOrdersPage()));
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _controller,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: const BoxDecoration(
                        color: AppColors.softPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 64,
                        color: AppColors.mutedRose,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Order Placed!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thank you for shopping with BloomShop.\n'
                    'Your demo order has been created.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, height: 1.5),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.card(),
                    child: Column(
                      children: [
                        _Line(label: 'Order ID', value: order.id),
                        _Line(
                          label: 'Items',
                          value: '${order.itemCount}',
                        ),
                        _Line(label: 'Payment', value: order.paymentMethod),
                        _Line(
                          label: 'Total',
                          value: Formatters.rupiah(order.total),
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    AppStrings.demoPaymentNotice,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: 'View My Orders', onPressed: _viewOrders),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Continue Shopping',
                    outlined: true,
                    onPressed: _continueShopping,
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

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: highlight ? 16 : 14,
                color: highlight ? AppColors.mutedRose : AppColors.darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
