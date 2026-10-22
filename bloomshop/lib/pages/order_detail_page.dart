import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/theme/app_theme.dart';
import 'package:bloomshop/core/utils/formatters.dart';
import 'package:bloomshop/core/utils/ui_helpers.dart';
import 'package:bloomshop/models/order.dart';
import 'package:bloomshop/providers/order_provider.dart';
import 'package:bloomshop/providers/settings_provider.dart';
import 'package:bloomshop/widgets/empty_state.dart';
import 'package:bloomshop/widgets/primary_button.dart';
import 'package:bloomshop/widgets/product_image.dart';
import 'package:bloomshop/widgets/status_chip.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  Future<void> _advance(BuildContext context, Order order) async {
    final provider = context.read<OrderProvider>();
    final alerts = context.read<SettingsProvider>().orderAlerts;
    final messenger = ScaffoldMessenger.of(context);
    final status = await provider.advanceStatus(order);
    if (status != null && alerts) {
      showAppSnackBarOn(messenger, 'Order status: ${status.label}');
    }
  }

  Future<void> _cancel(BuildContext context, Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel order?'),
        content: const Text('This demo order will be marked as Cancelled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final provider = context.read<OrderProvider>();
    final alerts = context.read<SettingsProvider>().orderAlerts;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.cancel(order);
    if (ok && alerts) {
      showAppSnackBarOn(messenger, 'Order cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final order =
        context.select<OrderProvider, Order?>((p) => p.findById(orderId));
    // Rebuild whenever any order changes (status updates mutate the object).
    context.watch<OrderProvider>();

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Detail')),
        body: const ErrorState(message: 'This order could not be found.'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order Detail')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    StatusChip(status: order.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.dateTime(order.createdAt),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                ),
                const SizedBox(height: 14),
                _StatusTimeline(status: order.status),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            title: 'Items',
            child: Column(
              children: [
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: ProductImage(
                              imagePath: item.imagePath,
                              category: item.category,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${item.quantity} x ${Formatters.rupiah(item.unitPrice)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Formatters.rupiah(item.subtotal),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            title: 'Delivery',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.recipientName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(order.phone),
                const SizedBox(height: 6),
                Text(order.address, style: const TextStyle(height: 1.4)),
                const SizedBox(height: 8),
                Text(
                  'Shipping: ${order.shippingMethod}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            title: 'Payment',
            child: Column(
              children: [
                _Row(label: 'Method', value: order.paymentMethod),
                _Row(label: 'Subtotal', value: Formatters.rupiah(order.subtotal)),
                _Row(
                  label: 'Shipping',
                  value: Formatters.rupiah(order.shippingCost),
                ),
                if (order.discount > 0)
                  _Row(
                    label: 'Discount',
                    value: '-${Formatters.rupiah(order.discount)}',
                  ),
                const Divider(height: 20),
                _Row(
                  label: 'Total',
                  value: Formatters.rupiah(order.total),
                  bold: true,
                ),
              ],
            ),
          ),
          if (order.canAdvance || order.canCancel) ...[
            const SizedBox(height: 20),
            if (order.canAdvance)
              PrimaryButton(
                label: order.status == OrderStatus.processing
                    ? 'Simulate: Mark as Shipped'
                    : 'Simulate: Mark as Delivered',
                icon: Icons.local_shipping_outlined,
                onPressed: () => _advance(context, order),
              ),
            if (order.canCancel) ...[
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Cancel Order',
                outlined: true,
                onPressed: () => _cancel(context, order),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? AppColors.darkBrown : AppColors.textMuted,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                fontSize: bold ? 16 : 14,
                color: bold ? AppColors.mutedRose : AppColors.darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return const Row(
        children: [
          Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
          SizedBox(width: 8),
          Text('This order was cancelled'),
        ],
      );
    }
    const steps = [
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];
    final currentIndex = steps.indexOf(status);
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Column(
            children: [
              Icon(
                i <= currentIndex
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: i <= currentIndex
                    ? AppColors.mutedRose
                    : AppColors.textMuted,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                steps[i].label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight:
                      i == currentIndex ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Divider(
                  thickness: 2,
                  color: i < currentIndex
                      ? AppColors.mutedRose
                      : AppColors.border,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
