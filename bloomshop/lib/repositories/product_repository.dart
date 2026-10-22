import 'package:bloomshop/data/product_data.dart';
import 'package:bloomshop/models/product.dart';

enum SortOption {
  featured('Featured'),
  priceLow('Price: Low to High'),
  priceHigh('Price: High to Low'),
  rating('Top Rated'),
  name('Name A-Z');

  const SortOption(this.label);
  final String label;
}

/// Single source of truth for the product catalog.
class ProductRepository {
  ProductRepository({List<Product>? products})
      : _products = products ?? ProductData.buildProducts();

  final List<Product> _products;

  List<Product> get all => List.unmodifiable(_products);

  List<Product> get bestSellers =>
      _products.where((p) => p.isBestSeller).toList();

  List<Product> get newArrivals =>
      _products.where((p) => p.isNewArrival).toList();

  Product? findById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  List<Product> byCategory(String category) =>
      _products.where((p) => p.category == category).toList();

  /// Filters by text query and/or category, then sorts.
  List<Product> search({
    String query = '',
    String? category,
    SortOption sort = SortOption.featured,
  }) {
    final q = query.trim().toLowerCase();
    final result = _products.where((p) {
      final matchesCategory = category == null || p.category == category;
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();

    switch (sort) {
      case SortOption.featured:
        break;
      case SortOption.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.name:
        result.sort((a, b) => a.name.compareTo(b.name));
    }
    return result;
  }
}
