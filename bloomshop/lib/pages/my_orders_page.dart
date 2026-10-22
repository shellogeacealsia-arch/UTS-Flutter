import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/theme/app_theme.dart';
import 'package:bloomshop/core/utils/formatters.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/models/order.dart';
import 'package:bloomshop/pages/order_detail_page.dart';
import 'package:bloomshop/providers/order_provider.dart';
import 'package:bloomshop/widgets/empty_state.dart';
import 'package:bloomshop/widgets/product_image.dart';
import 'package:bloomshop/widgets/status_chip.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final orders = provider.orders;

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: !provider.isLoaded
          ? const LoadingState()
          : orders.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No orders yet',
                  message: 'Your placed orders will appear here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: orders.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OrderCard(order: orders[index]),
                  ),
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final preview = order.items.take(3).toList();
    final names = order.items.map((i) => '${i.name} x${i.quantity}').join(', ');
    return Container(
      decoration: AppTheme.card(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(context).push(
            fadeSlideRoute<void>(OrderDetailPage(orderId: order.id)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    StatusChip(status: order.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.dateTime(order.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final item in preview)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 46,
                            height: 46,
                            child: ProductImage(
                              imagePath: item.imagePath,
                              category: item.category,
                            ),
                          ),
                        ),
                      ),
                    if (order.items.length > preview.length)
                      Text(
                        '+${order.items.length - preview.length}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  names,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, height: 1.35),
                ),
                const Divider(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.paymentMethod,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    Text(
                      Formatters.rupiah(order.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.mutedRose,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
