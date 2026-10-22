import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloomshop/models/cart_item.dart';
import 'package:bloomshop/models/order.dart';
import 'package:bloomshop/providers/cart_provider.dart';
import 'package:bloomshop/providers/favorite_provider.dart';
import 'package:bloomshop/providers/order_provider.dart';
import 'package:bloomshop/repositories/product_repository.dart';
import 'package:bloomshop/services/cart_service.dart';
import 'package:bloomshop/services/favorite_service.dart';
import 'package:bloomshop/services/order_service.dart';

import 'test_helpers.dart';

void main() {
  late SharedPreferences prefs;
  late ProductRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = ProductRepository();
  });

  group('CartProvider', () {
    test('add, merge quantity, totals and badge count', () async {
      final cart = CartProvider(CartService(prefs), repository);
      await cart.load();
      final a = repository.findById('p01')!;
      final b = repository.findById('p03')!;

      expect(await cart.add(a, quantity: 2), isTrue);
      expect(await cart.add(a), isTrue); // merges
      expect(await cart.add(b), isTrue);

      expect(cart.items.length, 2);
      expect(cart.quantityOf('p01'), 3);
      expect(cart.totalItems, 4);
      expect(cart.totalPrice, a.price * 3 + b.price);
    });

    test('quantity cannot exceed stock', () async {
      final cart = CartProvider(CartService(prefs), repository);
      await cart.load();
      final low = repository.findById('p23')!; // stock 3
      await cart.add(low, quantity: 10);
      expect(cart.quantityOf('p23'), 3);
      expect(await cart.add(low), isFalse);
    });

    test('increase, decrease (min 1) and remove', () async {
      final cart = CartProvider(CartService(prefs), repository);
      await cart.load();
      final p = repository.findById('p01')!;
      await cart.add(p);
      final item = cart.items.first;

      expect(await cart.increase(item), isTrue);
      expect(item.quantity, 2);
      expect(await cart.decrease(item), isTrue);
      expect(await cart.decrease(item), isFalse); // stays at 1
      expect(item.quantity, 1);

      await cart.remove(item);
      expect(cart.isEmpty, isTrue);
      expect(cart.totalPrice, 0);
    });

    test('cart persists and reloads', () async {
      final first = CartProvider(CartService(prefs), repository);
      await first.load();
      await first.add(repository.findById('p05')!, quantity: 2);

      final second = CartProvider(CartService(prefs), ProductRepository());
      await second.load();
      expect(second.quantityOf('p05'), 2);
    });
  });

  group('FavoriteProvider', () {
    test('toggle adds and removes, keeps Product flag in sync', () async {
      final favorites = FavoriteProvider(FavoriteService(prefs), repository);
      await favorites.load();
      final p = repository.findById('p07')!;

      expect(await favorites.toggle(p), isTrue);
      expect(favorites.isFavorite('p07'), isTrue);
      expect(p.isFavorite, isTrue);
      expect(favorites.favorites.map((e) => e.id), ['p07']);

      expect(await favorites.toggle(p), isFalse);
      expect(favorites.isFavorite('p07'), isFalse);
      expect(p.isFavorite, isFalse);
    });

    test('favorites persist and reload', () async {
      final first = FavoriteProvider(FavoriteService(prefs), repository);
      await first.load();
      await first.toggle(repository.findById('p10')!);

      final freshRepo = ProductRepository();
      final second = FavoriteProvider(FavoriteService(prefs), freshRepo);
      await second.load();
      expect(second.isFavorite('p10'), isTrue);
      expect(freshRepo.findById('p10')!.isFavorite, isTrue);
    });
  });

  group('OrderProvider', () {
    Future<Order?> place(OrderProvider orders, List<CartItem> items) {
      return orders.placeOrder(
        items: items,
        recipientName: 'Ayu',
        phone: '081234567890',
        address: 'Jl. Mawar No. 12, Madiun',
        shipping: ShippingOption.options.first,
        paymentMethod: 'Cash on Delivery',
        discount: 5000,
      );
    }

    test('creates an order from checkout items with correct totals', () async {
      final orders = OrderProvider(OrderService(prefs));
      await orders.load();
      final items = [
        CartItem(product: makeProduct(id: 'a', price: 50000), quantity: 2),
        CartItem(product: makeProduct(id: 'b', price: 30000)),
      ];

      final order = await place(orders, items);

      expect(order, isNotNull);
      expect(order!.id, startsWith('BLM-'));
      expect(order.status, OrderStatus.processing);
      expect(order.subtotal, 130000);
      expect(order.total, 130000 + 15000 - 5000);
      expect(orders.orders.first.id, order.id);
    });

    test('rejects empty orders and keeps ids unique', () async {
      final orders = OrderProvider(OrderService(prefs));
      await orders.load();
      expect(await place(orders, []), isNull);

      final item = CartItem(product: makeProduct());
      final o1 = await place(orders, [item]);
      final o2 = await place(orders, [item]);
      expect(o1!.id == o2!.id, isFalse);
      expect(orders.orders.length, 2);
    });

    test('orders persist and status can advance / cancel', () async {
      final orders = OrderProvider(OrderService(prefs));
      await orders.load();
      final order = (await place(orders, [CartItem(product: makeProduct())]))!;

      expect(await orders.advanceStatus(order), OrderStatus.shipped);
      expect(await orders.advanceStatus(order), OrderStatus.delivered);
      expect(await orders.advanceStatus(order), isNull);
      expect(await orders.cancel(order), isFalse);

      final reloaded = OrderProvider(OrderService(prefs));
      await reloaded.load();
      expect(reloaded.orders.single.status, OrderStatus.delivered);
    });
  });
}
