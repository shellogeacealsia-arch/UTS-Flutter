import 'package:flutter/foundation.dart';

import 'package:bloomshop/models/product.dart';
import 'package:bloomshop/repositories/product_repository.dart';
import 'package:bloomshop/services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider(this._service, this._repository);

  final FavoriteService _service;
  final ProductRepository _repository;
  final Set<String> _ids = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  int get count => _ids.length;

  List<Product> get favorites =>
      _repository.all.where((p) => _ids.contains(p.id)).toList();

  bool isFavorite(String productId) => _ids.contains(productId);

  Future<void> load() async {
    _ids
      ..clear()
      ..addAll(_service.load());
    // Keep the mutable Product.isFavorite flag in sync (uses the setter).
    for (final product in _repository.all) {
      product.isFavorite = _ids.contains(product.id);
    }
    _isLoaded = true;
    notifyListeners();
  }

  /// Returns the new favorite state.
  Future<bool> toggle(Product product) async {
    if (_ids.contains(product.id)) {
      _ids.remove(product.id);
    } else {
      _ids.add(product.id);
    }
    product.isFavorite = _ids.contains(product.id);
    notifyListeners();
    await _service.save(_ids);
    return product.isFavorite;
  }

  Future<void> remove(Product product) async {
    if (!_ids.remove(product.id)) return;
    product.isFavorite = false;
    notifyListeners();
    await _service.save(_ids);
  }
}
