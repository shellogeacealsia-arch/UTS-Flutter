import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/utils/formatters.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/core/utils/ui_helpers.dart';
import 'package:bloomshop/models/cart_item.dart';
import 'package:bloomshop/pages/checkout_page.dart';
import 'package:bloomshop/pages/product_detail_page.dart';
import 'package:bloomshop/providers/cart_provider.dart';
import 'package:bloomshop/providers/nav_provider.dart';
import 'package:bloomshop/widgets/cart_item_card.dart';
import 'package:bloomshop/widgets/empty_state.dart';
import 'package:bloomshop/widgets/primary_button.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        automaticallyImplyLeading: false,
      ),
      body: !cart.isLoaded
          ? const LoadingState()
          : cart.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your cart is empty',
                  message: 'Add some beauty favourites and they will show up here.',
                  actionLabel: 'Start Shopping',
                  onAction: () => context.read<NavProvider>().setIndex(0),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CartItemCard(
                              item: item,
                              onTap: () => Navigator.of(context).push(
                                fadeSlideRoute<void>(
                                  ProductDetailPage(product: item.product),
                                ),
                              ),
                              onIncrease: () => cart.increase(item),
                              onDecrease: () => cart.decrease(item),
                              onRemove: () => _remove(context, cart, item),
                            ),
                          );
                        },
                      ),
                    ),
                    _CartSummary(cart: cart),
                  ],
                ),
    );
  }

  Future<void> _remove(
    BuildContext context,
    CartProvider cart,
    CartItem item,
  ) async {
    final product = item.product;
    final quantity = item.quantity;
    // Capture before awaiting: the item's card leaves the tree.
    final messenger = ScaffoldMessenger.of(context);
    await cart.remove(item);
    showAppSnackBarOn(
      messenger,
      '${product.name} removed',
      actionLabel: 'Undo',
      onAction: () => cart.add(product, quantity: quantity),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1AB76E79),
            blurRadius: 14,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Items', style: TextStyle(color: AppColors.textMuted)),
              const Spacer(),
              Text(
                '${cart.totalItems} item${cart.totalItems == 1 ? '' : 's'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                Formatters.rupiah(cart.totalPrice),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.mutedRose,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Proceed to Checkout',
            icon: Icons.lock_outline_rounded,
            onPressed: () => Navigator.of(context).push(
              fadeSlideRoute<void>(
                CheckoutPage(items: cart.items, fromCart: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
