import 'package:bloomshop/models/product.dart';

/// A product inside the cart with a quantity between 1 and the product stock.
class CartItem {
  CartItem({required this.product, int quantity = 1}) : _quantity = 1 {
    this.quantity = quantity; // goes through the validating setter
  }

  final Product product;
  int _quantity;

  int get quantity => _quantity;

  /// Keeps the quantity within 1..stock.
  set quantity(int value) {
    final limit = product.stock < 1 ? 1 : product.stock;
    if (value < 1) {
      _quantity = 1;
    } else if (value > limit) {
      _quantity = limit;
    } else {
      _quantity = value;
    }
  }

  bool get canIncrease => _quantity < product.stock;
  bool get canDecrease => _quantity > 1;

  int get subtotal => product.subtotalFor(_quantity);

  /// Returns false when the stock limit prevents the change.
  bool increase() {
    if (!canIncrease) return false;
    _quantity += 1;
    return true;
  }

  /// Returns false when already at the minimum of 1 (use remove instead).
  bool decrease() {
    if (!canDecrease) return false;
    _quantity -= 1;
    return true;
  }

  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'quantity': _quantity,
      };
}
