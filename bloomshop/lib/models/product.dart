/// A cosmetic product sold in BloomShop.
///
/// OOP notes:
///  * Encapsulation: [price], [rating], [stock] and [isFavorite] are private
///    fields exposed through getters; setters validate their input.
///  * [isFavorite] is changed through its setter by FavoriteProvider.
class Product {
  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required int price,
    this.originalPrice,
    required this.description,
    required this.imagePath,
    required double rating,
    required this.reviewCount,
    this.isBestSeller = false,
    this.isNewArrival = false,
    required int stock,
    bool isFavorite = false,
  })  : _price = price,
        _rating = rating,
        _stock = stock < 0 ? 0 : stock,
        _isFavorite = isFavorite;

  final String id;
  final String name;
  final String brand;
  final String category;

  /// Regular price before discount (null when the product is not discounted).
  final int? originalPrice;
  final String description;
  final String imagePath;
  final int reviewCount;
  final bool isBestSeller;
  final bool isNewArrival;

  int _price;
  double _rating;
  int _stock;
  bool _isFavorite;

  // ---- getters ----------------------------------------------------------

  /// Current selling price (already discounted when [hasDiscount]).
  int get price => _price;
  double get rating => _rating;
  int get stock => _stock;
  bool get isFavorite => _isFavorite;

  bool get hasDiscount => originalPrice != null && originalPrice! > _price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - _price) * 100) / originalPrice!).round();
  }

  int get savings => hasDiscount ? originalPrice! - _price : 0;
  bool get inStock => _stock > 0;
  bool get isLowStock => _stock > 0 && _stock <= 5;

  // ---- setters (with validation) ---------------------------------------

  set price(int value) {
    if (value > 0) _price = value;
  }

  set rating(double value) {
    _rating = value.clamp(0.0, 5.0).toDouble();
  }

  set stock(int value) {
    _stock = value < 0 ? 0 : value;
  }

  set isFavorite(bool value) {
    _isFavorite = value;
  }

  // ---- methods ---------------------------------------------------------

  /// Price for [quantity] units at the current selling price.
  int subtotalFor(int quantity) => _price * quantity;

  /// Applies a percentage discount: applyDiscount(100000, 20) == 80000.
  static int applyDiscount(int basePrice, int percent) {
    return basePrice - (basePrice * percent ~/ 100);
  }
}
