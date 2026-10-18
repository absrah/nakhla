import 'package:flutter/material.dart';

/// TEMPORARY placeholder. The real cart is built in the cart step.
/// No back button: Cart is a tab now, you leave it with the bottom bar.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: const Center(child: Text('Cart placeholder')),
    );
  }
}