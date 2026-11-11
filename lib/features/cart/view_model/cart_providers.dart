import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/view_model/session_provider.dart';
import '../../catalog/view_model/catalog_providers.dart';
import '../model/cart_item.dart';
import '../model/cart_line.dart';
import '../model/cart_repository.dart';

/// The stored cart items of the logged-in user (empty for a guest).
final cartItemsProvider = StreamProvider<List<CartItem>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <CartItem>[]);
  return ref.watch(cartRepositoryProvider).watchCart(user.uid);
});

/// Cart items joined with their live product data (name, price, stock).
/// An item whose product was deleted from the catalog is left out.
final cartLinesProvider = Provider<AsyncValue<List<CartLine>>>((ref) {
  final items = ref.watch(cartItemsProvider);
  final products = ref.watch(productsProvider);

  return items.when(
    loading: () => const AsyncLoading<List<CartLine>>(),
    error: (error, stack) => AsyncError<List<CartLine>>(error, stack),
    data: (cartItems) => products.whenData((all) {
      final byId = {for (final p in all) p.id: p};
      final lines = <CartLine>[];
      for (final item in cartItems) {
        final product = byId[item.productId];
        if (product != null) {
          lines.add(CartLine(product: product, quantity: item.quantity));
        }
      }
      return lines;
    }),
  );
});

/// Totals and counts for the cart screen and the Cart tab badge.
final cartSummaryProvider = Provider<CartSummary>((ref) {
  return CartSummary(ref.watch(cartLinesProvider).value ?? const []);
});

/// How many pieces of one product are already in the cart (0 if none, and
/// always 0 for a guest). Lets buttons grey out once the cart holds the most
/// that may be bought.
final cartQuantityProvider = Provider.family<int, String>((ref, productId) {
  final items = ref.watch(cartItemsProvider).value ?? const <CartItem>[];
  for (final item in items) {
    if (item.productId == productId) return item.quantity;
  }
  return 0;
});
