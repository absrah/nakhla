import 'package:flutter/material.dart';

import '../../model/product.dart';
import 'product_card.dart';

/// Two-column grid of product cards, to place inside a CustomScrollView.
class SliverProductGrid extends StatelessWidget {
  const SliverProductGrid({super.key, required this.products});

  final List<Product> products;

  static const _spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.crossAxisExtent - _spacing) / 2;
        return SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: _spacing,
            mainAxisSpacing: 20,
            mainAxisExtent: cardWidth + ProductCard.belowImage,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => ProductCard(product: products[index]),
        );
      },
    );
  }
}