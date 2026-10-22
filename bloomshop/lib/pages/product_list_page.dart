import 'package:flutter/material.dart';

import 'package:bloomshop/models/product.dart';
import 'package:bloomshop/widgets/empty_state.dart';
import 'package:bloomshop/widgets/product_card.dart';

/// Full-screen grid for "See All" (Best Sellers / New Arrivals).
class ProductListPage extends StatelessWidget {
  const ProductListPage({
    super.key,
    required this.title,
    required this.products,
  });

  final String title;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: products.isEmpty
          ? const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Nothing here yet',
              message: 'No products to show in this list.',
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 262,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  ProductCard(product: products[index]),
            ),
    );
  }
}
