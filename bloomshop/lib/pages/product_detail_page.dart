import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/theme/app_theme.dart';
import 'package:bloomshop/core/utils/formatters.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/core/utils/ui_helpers.dart';
import 'package:bloomshop/models/cart_item.dart';
import 'package:bloomshop/models/product.dart';
import 'package:bloomshop/pages/checkout_page.dart';
import 'package:bloomshop/providers/cart_provider.dart';
import 'package:bloomshop/providers/favorite_provider.dart';
import 'package:bloomshop/providers/nav_provider.dart';
import 'package:bloomshop/widgets/product_image.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  Product get _product => widget.product;

  void _changeQuantity(int delta) {
    final next = _quantity + delta;
    if (next < 1) return;
    if (next > _product.stock) {
      showAppSnackBar(context, 'Only ${_product.stock} in stock');
      return;
    }
    setState(() => _quantity = next);
  }

  Future<void> _addToCart() async {
    final cart = context.read<CartProvider>();
    final nav = context.read<NavProvider>();
    final navigator = Navigator.of(context);
    final before = cart.quantityOf(_product.id);
    final ok = await cart.add(_product, quantity: _quantity);
    if (!mounted) return;
    if (!ok) {
      showAppSnackBar(context, 'You already have the maximum stock in your cart');
      return;
    }
    final added = cart.quantityOf(_product.id) - before;
    final message = added < _quantity
        ? 'Added $added to cart (stock limit reached)'
        : 'Added to cart';
    showAppSnackBar(
      context,
      message,
      actionLabel: 'View Cart',
      onAction: () {
        navigator.popUntil((route) => route.isFirst);
        nav.setIndex(2);
      },
    );
  }

  void _buyNow() {
    Navigator.of(context).push(
      fadeSlideRoute<void>(
        CheckoutPage(
          items: [CartItem(product: _product, quantity: _quantity)],
          fromCart: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final isFav = context
        .select<FavoriteProvider, bool>((f) => f.isFavorite(product.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: AppColors.mutedRose,
            ),
            onPressed: () async {
              final added =
                  await context.read<FavoriteProvider>().toggle(product);
              if (!context.mounted) return;
              showAppSnackBar(
                context,
                added ? 'Added to favorites' : 'Removed from favorites',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(
                    imagePath: product.imagePath,
                    category: product.category,
                    fit: BoxFit.contain,
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mutedRose,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            product.category.toUpperCase(),
            style: const TextStyle(
              fontSize: 11.5,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.mutedRose,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'by ${product.brand}',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.star, size: 20),
              const SizedBox(width: 4),
              Text(
                product.rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              Text(
                '(${product.reviewCount} reviews)',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            children: [
              Text(
                Formatters.rupiah(product.price),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.mutedRose,
                ),
              ),
              if (product.hasDiscount)
                Text(
                  Formatters.rupiah(product.originalPrice!),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          if (product.hasDiscount) ...[
            const SizedBox(height: 4),
            Text(
              'You save ${Formatters.rupiah(product.savings)}',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: AppTheme.card(radius: 16),
            child: Row(
              children: [
                Icon(
                  product.inStock
                      ? Icons.inventory_2_outlined
                      : Icons.remove_shopping_cart_outlined,
                  color: product.inStock
                      ? (product.isLowStock
                          ? AppColors.warning
                          : AppColors.success)
                      : AppColors.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    !product.inStock
                        ? 'Out of stock'
                        : product.isLowStock
                            ? 'Only ${product.stock} left - order soon!'
                            : 'In stock: ${product.stock} available',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            product.description,
            style: const TextStyle(height: 1.55, color: AppColors.darkBrown),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Quantity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              _QuantitySelector(
                quantity: _quantity,
                enabled: product.inStock,
                onMinus: () => _changeQuantity(-1),
                onPlus: () => _changeQuantity(1),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x1AB76E79),
                blurRadius: 14,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: product.inStock ? _addToCart : null,
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 19),
                  label: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: product.inStock ? _buyNow : null,
                  child: const Text('Buy Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.enabled,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final bool enabled;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, VoidCallback onTap) {
      return Material(
        color: AppColors.softPink,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 20, color: AppColors.mutedRose),
          ),
        ),
      );
    }

    return Row(
      children: [
        button(Icons.remove, onMinus),
        SizedBox(
          width: 48,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        button(Icons.add, onPlus),
      ],
    );
  }
}
