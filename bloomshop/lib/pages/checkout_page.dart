import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/constants/app_strings.dart';
import 'package:bloomshop/core/theme/app_theme.dart';
import 'package:bloomshop/core/utils/formatters.dart';
import 'package:bloomshop/core/utils/page_routes.dart';
import 'package:bloomshop/core/utils/ui_helpers.dart';
import 'package:bloomshop/core/utils/validators.dart';
import 'package:bloomshop/models/cart_item.dart';
import 'package:bloomshop/models/order.dart';
import 'package:bloomshop/pages/order_success_page.dart';
import 'package:bloomshop/providers/cart_provider.dart';
import 'package:bloomshop/providers/order_provider.dart';
import 'package:bloomshop/providers/profile_provider.dart';
import 'package:bloomshop/widgets/empty_state.dart';
import 'package:bloomshop/widgets/primary_button.dart';
import 'package:bloomshop/widgets/product_image.dart';

/// Checkout for either the whole cart ([fromCart] = true) or a single
/// "Buy Now" product ([fromCart] = false, cart is left untouched).
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.items, this.fromCart = true});

  final List<CartItem> items;
  final bool fromCart;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final _promoController = TextEditingController();

  ShippingOption _shipping = ShippingOption.options.first;
  String _payment = AppStrings.paymentMethods.first;
  bool _promoApplied = false;
  bool _isPlacing = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  int get _subtotal =>
      widget.items.fold(0, (sum, item) => sum + item.subtotal);

  int get _discount =>
      _promoApplied ? _subtotal * AppStrings.promoPercent ~/ 100 : 0;

  int get _total {
    final value = _subtotal + _shipping.cost - _discount;
    return value < 0 ? 0 : value;
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code == AppStrings.promoCode) {
      setState(() => _promoApplied = true);
      showAppSnackBar(context, 'Promo applied: ${AppStrings.promoPercent}% off');
    } else {
      showAppSnackBar(context, 'Invalid promo code');
    }
  }

  Future<void> _placeOrder() async {
    if (_isPlacing) return; // prevents duplicate orders on repeated taps
    if (!(_formKey.currentState?.validate() ?? false)) {
      showAppSnackBar(context, 'Please complete the required information');
      return;
    }
    setState(() => _isPlacing = true);

    final orders = context.read<OrderProvider>();
    final cart = context.read<CartProvider>();
    final navigator = Navigator.of(context);

    final order = await orders.placeOrder(
      items: widget.items,
      recipientName: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      shipping: _shipping,
      paymentMethod: _payment,
      discount: _discount,
    );

    if (order == null) {
      if (!mounted) return;
      setState(() => _isPlacing = false);
      showAppSnackBar(context, 'Could not place the order. Please try again.');
      return;
    }

    // The cart is cleared only AFTER the order was created successfully.
    if (widget.fromCart) {
      await cart.clear();
    }
    navigator.pushAndRemoveUntil(
      fadeSlideRoute<void>(OrderSuccessPage(order: order)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Nothing to checkout',
          message: 'Your cart has no items.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softPink.withAlpha(120),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.mutedRose),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.demoPaymentNotice,
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Order Summary',
              child: Column(
                children: [
                  for (final item in widget.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: ProductImage(
                                imagePath: item.product.imagePath,
                                category: item.product.category,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${item.quantity} x ${Formatters.rupiah(item.product.price)}',
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
            _SectionCard(
              title: 'Delivery Information',
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Recipient name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: Validators.fullName,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Full shipping address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: Validators.address,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Shipping Method',
              child: Column(
                children: [
                  for (final option in ShippingOption.options)
                    _OptionTile(
                      title: option.name,
                      subtitle: option.description,
                      trailing: Formatters.rupiah(option.cost),
                      selected: option.id == _shipping.id,
                      onTap: () => setState(() => _shipping = option),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Payment Method',
              child: Column(
                children: [
                  for (final method in AppStrings.paymentMethods)
                    _OptionTile(
                      title: method,
                      selected: method == _payment,
                      onTap: () => setState(() => _payment = method),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Promo Code',
              child: _promoApplied
                  ? Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${AppStrings.promoCode} applied - '
                            '${AppStrings.promoPercent}% off',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _promoApplied = false),
                          child: const Text('Remove'),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: 'Try ${AppStrings.promoCode}',
                              prefixIcon: Icon(Icons.local_offer_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: _applyPromo,
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Payment Details',
              child: Column(
                children: [
                  _PriceRow(label: 'Subtotal', value: Formatters.rupiah(_subtotal)),
                  _PriceRow(
                    label: 'Shipping (${_shipping.name})',
                    value: Formatters.rupiah(_shipping.cost),
                  ),
                  if (_discount > 0)
                    _PriceRow(
                      label: 'Discount',
                      value: '-${Formatters.rupiah(_discount)}',
                      valueColor: AppColors.success,
                    ),
                  const Divider(height: 22),
                  _PriceRow(
                    label: 'Total',
                    value: Formatters.rupiah(_total),
                    bold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
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
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  Text(
                    Formatters.rupiah(_total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mutedRose,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  label: 'Place Order',
                  isLoading: _isPlacing,
                  onPressed: _placeOrder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final String? trailing;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.softPink.withAlpha(90) : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.mutedRose : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.mutedRose : AppColors.textMuted,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: valueColor ?? (bold ? AppColors.mutedRose : AppColors.darkBrown),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bold ? 16 : 14,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
                color: bold ? AppColors.darkBrown : AppColors.textMuted,
              ),
            ),
          ),
          Text(value, style: style),
        ],
      ),
    );
  }
}
