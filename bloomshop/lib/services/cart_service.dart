import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloomshop/models/cart_item.dart';
import 'package:bloomshop/repositories/product_repository.dart';

class CartService {
  CartService(this._prefs);

  final SharedPreferences _prefs;
  static const String _key = 'cart_items';

  List<CartItem> load(ProductRepository repository) {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final items = <CartItem>[];
      for (final entry in list) {
        final map = Map<String, dynamic>.from(entry as Map);
        final product = repository.findById(map['productId'] as String);
        if (product == null || !product.inStock) continue;
        items.add(CartItem(product: product, quantity: map['quantity'] as int));
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<CartItem> items) async {
    await _prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}
