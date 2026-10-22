import 'package:flutter/material.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/models/cart_item.dart';

enum OrderStatus {
  processing('Processing'),
  shipped('Shipped'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const OrderStatus(this.label);
  final String label;

  Color get color {
    switch (this) {
      case OrderStatus.processing:
        return AppColors.warning;
      case OrderStatus.shipped:
        return AppColors.mauve;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  static OrderStatus fromName(String? name) {
    return OrderStatus.values.firstWhere(
      (s) => s.name == name,
      orElse: () => OrderStatus.processing,
    );
  }
}

/// Delivery option shown in checkout.
class ShippingOption {
  const ShippingOption({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
  });

  final String id;
  final String name;
  final String description;
  final int cost;

  static const List<ShippingOption> options = [
    ShippingOption(
      id: 'regular',
      name: 'Regular',
      description: 'Arrives in 3-5 days',
      cost: 15000,
    ),
    ShippingOption(
      id: 'express',
      name: 'Express',
      description: 'Arrives in 1-2 days',
      cost: 30000,
    ),
  ];
}

/// Snapshot of a purchased product (stays correct even if prices change).
class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.brand,
    required this.imagePath,
    required this.category,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String name;
  final String brand;
  final String imagePath;
  final String category;
  final int unitPrice;
  final int quantity;

  int get subtotal => unitPrice * quantity;

  factory OrderItem.fromCartItem(CartItem item) {
    return OrderItem(
      productId: item.product.id,
      name: item.product.name,
      brand: item.product.brand,
      imagePath: item.product.imagePath,
      category: item.product.category,
      unitPrice: item.product.price,
      quantity: item.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'brand': brand,
        'imagePath': imagePath,
        'category': category,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      category: json['category'] as String? ?? '',
      unitPrice: json['unitPrice'] as int,
      quantity: json['quantity'] as int,
    );
  }
}

class Order {
  Order({
    required this.id,
    required this.items,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.shippingCost,
    this.discount = 0,
    required this.createdAt,
    OrderStatus status = OrderStatus.processing,
  }) : _status = status;

  final String id;
  final List<OrderItem> items;
  final String recipientName;
  final String phone;
  final String address;
  final String shippingMethod;
  final String paymentMethod;
  final int shippingCost;
  final int discount;
  final DateTime createdAt;

  OrderStatus _status;

  OrderStatus get status => _status;
  set status(OrderStatus value) => _status = value;

  bool get canCancel => _status == OrderStatus.processing;
  bool get canAdvance =>
      _status == OrderStatus.processing || _status == OrderStatus.shipped;

  int get subtotal => items.fold(0, (sum, i) => sum + i.subtotal);
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  int get total {
    final value = subtotal + shippingCost - discount;
    return value < 0 ? 0 : value;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
        'recipientName': recipientName,
        'phone': phone,
        'address': address,
        'shippingMethod': shippingMethod,
        'paymentMethod': paymentMethod,
        'shippingCost': shippingCost,
        'discount': discount,
        'createdAt': createdAt.toIso8601String(),
        'status': _status.name,
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      recipientName: json['recipientName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      shippingMethod: json['shippingMethod'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      shippingCost: json['shippingCost'] as int? ?? 0,
      discount: json['discount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: OrderStatus.fromName(json['status'] as String?),
    );
  }
}
