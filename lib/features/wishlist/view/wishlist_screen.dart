import 'package:flutter/material.dart';

import '../../../core/widgets/state_views.dart';

/// The Wishlist tab. Saving favourites is a stretch feature after the
/// deadline, so for now the tab says so instead of showing a blank page.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: const EmptyView(
        icon: Icons.favorite_border,
        message: 'Saving favourites is coming soon.',
      ),
    );
  }
}
