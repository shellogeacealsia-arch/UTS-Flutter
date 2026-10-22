import 'package:flutter/material.dart';

import 'package:bloomshop/models/product.dart';
import 'package:bloomshop/widgets/product_card.dart';
import 'package:bloomshop/widgets/section_heading.dart';

enum HorizontalCardStyle { vertical, row }

/// Heading + horizontally scrolling ListView.builder of products.
class HorizontalProductSection extends StatelessWidget {
  const HorizontalProductSection({
    super.key,
    required this.title,
    required this.products,
    required this.onSeeAll,
    this.style = HorizontalCardStyle.vertical,
  });

  final String title;
  final List<Product> products;
  final VoidCallback onSeeAll;
  final HorizontalCardStyle style;

  @override
  Widget build(BuildContext context) {
    final isRow = style == HorizontalCardStyle.row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(title: title, onSeeAll: onSeeAll),
        SizedBox(
          height: isRow ? 126 : 252,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == products.length - 1 ? 0 : 12,
                ),
                child: SizedBox(
                  width: isRow ? 276 : 150,
                  child: isRow
                      ? ProductRowCard(product: product)
                      : ProductCard(product: product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
