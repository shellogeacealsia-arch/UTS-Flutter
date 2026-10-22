import 'package:flutter_test/flutter_test.dart';

import 'package:bloomshop/data/product_data.dart';
import 'package:bloomshop/models/cart_item.dart';
import 'package:bloomshop/models/order.dart';
import 'package:bloomshop/models/product.dart';
import 'package:bloomshop/core/utils/formatters.dart';

import 'test_helpers.dart';

void main() {
  group('Product', () {
    test('applyDiscount computes discounted price', () {
      expect(Product.applyDiscount(100000, 20), 80000);
      expect(Product.applyDiscount(65000, 15), 55250);
    });

    test('discountPercent and savings', () {
      final p = makeProduct(price: 80000, originalPrice: 100000);
      expect(p.hasDiscount, isTrue);
      expect(p.discountPercent, 20);
      expect(p.savings, 20000);
      expect(makeProduct().hasDiscount, isFalse);
    });

    test('setters validate their input', () {
      final p = makeProduct();
      p.stock = -5;
      expect(p.stock, 0);
      p.rating = 9;
      expect(p.rating, 5.0);
      p.price = 0;
      expect(p.price, 100000);
      p.isFavorite = true;
      expect(p.isFavorite, isTrue);
    });

    test('catalog has exactly 24 unique products, 6 per category', () {
      final products = ProductData.buildProducts();
      expect(products.length, 24);
      expect(products.map((p) => p.id).toSet().length, 24);
      for (final c in ['Skincare', 'Make Up', 'Body Care', 'Hair Care']) {
        expect(products.where((p) => p.category == c).length, 6);
      }
    });
  });

  group('CartItem', () {
    test('subtotal = price x quantity', () {
      final item = CartItem(product: makeProduct(price: 25000), quantity: 3);
      expect(item.subtotal, 75000);
    });

    test('quantity never exceeds stock or drops below 1', () {
      final item = CartItem(product: makeProduct(stock: 3), quantity: 99);
      expect(item.quantity, 3);
      expect(item.increase(), isFalse);
      item.quantity = 0;
      expect(item.quantity, 1);
      expect(item.decrease(), isFalse);
    });

    test('increase and decrease change quantity by one', () {
      final item = CartItem(product: makeProduct(), quantity: 2);
      expect(item.increase(), isTrue);
      expect(item.quantity, 3);
      expect(item.decrease(), isTrue);
      expect(item.quantity, 2);
    });
  });

  group('Order', () {
    test('total = subtotal + shipping - discount', () {
      final order = Order(
        id: 'X',
        items: const [
          OrderItem(
            productId: 'a',
            name: 'A',
            brand: 'B',
            imagePath: '',
            category: 'Skincare',
            unitPrice: 50000,
            quantity: 2,
          ),
        ],
        recipientName: 'N',
        phone: '08123456789',
        address: 'Some long address 123',
        shippingMethod: 'Regular',
        paymentMethod: 'Cash on Delivery',
        shippingCost: 15000,
        discount: 10000,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(order.subtotal, 100000);
      expect(order.total, 105000);
      expect(order.itemCount, 2);
    });

    test('toJson / fromJson round trip keeps data and status', () {
      final order = Order(
        id: 'X',
        items: const [
          OrderItem(
            productId: 'a',
            name: 'A',
            brand: 'B',
            imagePath: 'p.png',
            category: 'Skincare',
            unitPrice: 1000,
            quantity: 1,
          ),
        ],
        recipientName: 'N',
        phone: '1',
        address: 'addr',
        shippingMethod: 'Regular',
        paymentMethod: 'COD',
        shippingCost: 0,
        createdAt: DateTime(2026, 1, 1),
        status: OrderStatus.shipped,
      );
      final copy = Order.fromJson(order.toJson());
      expect(copy.id, 'X');
      expect(copy.status, OrderStatus.shipped);
      expect(copy.total, order.total);
    });
  });

  test('Rupiah formatter uses Indonesian thousands separators', () {
    expect(Formatters.rupiah(0), 'Rp 0');
    expect(Formatters.rupiah(999), 'Rp 999');
    expect(Formatters.rupiah(1000), 'Rp 1.000');
    expect(Formatters.rupiah(125000), 'Rp 125.000');
    expect(Formatters.rupiah(1250000), 'Rp 1.250.000');
  });
}
