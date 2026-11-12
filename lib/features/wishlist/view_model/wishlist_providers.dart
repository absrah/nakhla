import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/view_model/session_provider.dart';
import '../../catalog/model/product.dart';
import '../../catalog/view_model/catalog_providers.dart';
import '../model/wishlist_entry.dart';
import '../model/wishlist_repository.dart';

/// The saved products of the logged-in user (empty for a guest).
final wishlistEntriesProvider = StreamProvider<List<WishlistEntry>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <WishlistEntry>[]);
  return ref.watch(wishlistRepositoryProvider).watch(user.uid);
});

/// Is this product saved? The heart buttons watch this.
final isWishlistedProvider = Provider.family<bool, String>((ref, productId) {
  final entries =
      ref.watch(wishlistEntriesProvider).value ?? const <WishlistEntry>[];
  return entries.any((entry) => entry.productId == productId);
});

/// Saved entries joined with their live product data, newest first.
/// A product that was deleted from the catalog is left out.
final wishlistProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final entries = ref.watch(wishlistEntriesProvider);
  final products = ref.watch(productsProvider);

  return entries.when(
    loading: () => const AsyncLoading<List<Product>>(),
    error: (error, stack) => AsyncError<List<Product>>(error, stack),
    data: (saved) => products.whenData((all) {
      final byId = {for (final p in all) p.id: p};
      final result = <Product>[];
      for (final entry in saved) {
        final product = byId[entry.productId];
        if (product != null) result.add(product);
      }
      return result;
    }),
  );
});
