import 'package:flutter/material.dart';

/// TEMPORARY placeholder. The real wishlist is built later in Phase 2/3.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: const Center(child: Text('Wishlist placeholder')),
    );
  }
}