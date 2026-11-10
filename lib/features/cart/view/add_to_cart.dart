import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../auth/view_model/session_provider.dart';
import '../../catalog/model/product.dart';
import '../view_model/cart_view_model.dart';

/// Adds a product to the cart and tells the user what happened.
/// A guest is sent to log in first and comes back to this same screen.
Future<void> addToCart(
  BuildContext context,
  WidgetRef ref,
  Product product, {
  int quantity = 1,
}) async {
  final user = ref.read(authStateProvider).value;
  if (user == null) {
    final here = GoRouterState.of(context).uri.toString();
    // go, not push: the router must see the log in screen.
    context.go('${AppRoutes.login}?from=${Uri.encodeComponent(here)}');
    return;
  }

  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  try {
    final added = await ref
        .read(cartViewModelProvider)
        .add(product, quantity: quantity);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          persist: false,
          content: Text(
            added ? 'Added to cart' : 'You already have the maximum quantity',
          ),
          action: added
              ? SnackBarAction(
                  label: 'View cart',
                  onPressed: () => router.go(AppRoutes.cart),
                )
              : null,
        ),
      );
  } on AppException catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(e.message)));
  }
}