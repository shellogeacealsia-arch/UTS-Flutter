import 'package:flutter/foundation.dart';

import 'package:bloomshop/models/cart_item.dart';
import 'package:bloomshop/models/order.dart';
import 'package:bloomshop/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._service);

  final OrderService _service;
  final List<Order> _orders = [];
  bool _isLoaded = false;
  bool _isPlacing = false;

  bool get isLoaded => _isLoaded;
  bool get isPlacing => _isPlacing;

  /// Newest first.
  List<Order> get orders => List.unmodifiable(_orders);

  Order? findById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<void> load() async {
    _orders
      ..clear()
      ..addAll(_service.load());
    _isLoaded = true;
    notifyListeners();
  }

  /// Creates and stores an order. Returns null when the order was not
  /// created (empty items, or another order is already being placed - this
  /// prevents duplicate orders from repeated taps).
  Future<Order?> placeOrder({
    required List<CartItem> items,
    required String recipientName,
    required String phone,
    required String address,
    required ShippingOption shipping,
    required String paymentMethod,
    int discount = 0,
  }) async {
    if (_isPlacing || items.isEmpty) return null;
    _isPlacing = true;
    notifyListeners();
    try {
      final now = DateTime.now();
      final order = Order(
        id: _newId(now),
        items: items.map(OrderItem.fromCartItem).toList(),
        recipientName: recipientName.trim(),
        phone: phone.trim(),
        address: address.trim(),
        shippingMethod: shipping.name,
        paymentMethod: paymentMethod,
        shippingCost: shipping.cost,
        discount: discount,
        createdAt: now,
      );
      _orders.insert(0, order);
      await _service.save(_orders);
      return order;
    } finally {
      _isPlacing = false;
      notifyListeners();
    }
  }

  String _newId(DateTime now) {
    final stamp = now.millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    final seq = (_orders.length + 1).toString().padLeft(3, '0');
    return 'BLM-$stamp-$seq';
  }

  /// Demo: moves Processing -> Shipped -> Delivered. Returns the new status.
  Future<OrderStatus?> advanceStatus(Order order) async {
    switch (order.status) {
      case OrderStatus.processing:
        order.status = OrderStatus.shipped;
      case OrderStatus.shipped:
        order.status = OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
    notifyListeners();
    await _service.save(_orders);
    return order.status;
  }

  Future<bool> cancel(Order order) async {
    if (!order.canCancel) return false;
    order.status = OrderStatus.cancelled;
    notifyListeners();
    await _service.save(_orders);
    return true;
  }
}
