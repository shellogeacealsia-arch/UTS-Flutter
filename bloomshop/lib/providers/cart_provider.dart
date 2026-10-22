import 'package:flutter/foundation.dart';

import 'package:bloomshop/models/cart_item.dart';
import 'package:bloomshop/models/product.dart';
import 'package:bloomshop/repositories/product_repository.dart';
import 'package:bloomshop/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._service, this._repository);

  final CartService _service;
  final ProductRepository _repository;
  final List<CartItem> _items = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;

  /// Total number of units (used by the cart badge).
  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);

  /// Sum of all item subtotals.
  int get totalPrice => _items.fold(0, (sum, i) => sum + i.subtotal);

  Future<void> load() async {
    _items
      ..clear()
      ..addAll(_service.load(_repository));
    _isLoaded = true;
    notifyListeners();
  }

  int _indexOf(String productId) =>
      _items.indexWhere((i) => i.product.id == productId);

  int quantityOf(String productId) {
    final index = _indexOf(productId);
    return index < 0 ? 0 : _items[index].quantity;
  }

  /// Adds [quantity] units. Existing items get their quantity increased.
  /// Returns false when nothing could be added (out of stock / stock limit).
  Future<bool> add(Product product, {int quantity = 1}) async {
    if (!product.inStock || quantity < 1) return false;
    final index = _indexOf(product.id);
    if (index >= 0) {
      final item = _items[index];
      if (!item.canIncrease) return false;
      item.quantity = item.quantity + quantity; // setter caps at stock
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
    await _service.save(_items);
    return true;
  }

  Future<bool> increase(CartItem item) async {
    final ok = item.increase();
    if (ok) {
      notifyListeners();
      await _service.save(_items);
    }
    return ok;
  }

  /// Decreases by one, never below 1. Use [remove] to delete the item.
  Future<bool> decrease(CartItem item) async {
    final ok = item.decrease();
    if (ok) {
      notifyListeners();
      await _service.save(_items);
    }
    return ok;
  }

  Future<void> remove(CartItem item) async {
    _items.remove(item);
    notifyListeners();
    await _service.save(_items);
  }

  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    await _service.save(_items);
  }
}
