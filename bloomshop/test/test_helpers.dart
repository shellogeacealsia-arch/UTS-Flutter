import 'package:bloomshop/models/product.dart';

Product makeProduct({
  String id = 't1',
  int price = 100000,
  int? originalPrice,
  int stock = 10,
}) {
  return Product(
    id: id,
    name: 'Test Product $id',
    brand: 'Test Brand',
    category: 'Skincare',
    price: price,
    originalPrice: originalPrice,
    description: 'Description',
    imagePath: 'assets/images/products/vitamin_c_serum.png',
    rating: 4.5,
    reviewCount: 10,
    stock: stock,
  );
}
