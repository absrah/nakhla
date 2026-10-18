import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/catalog_repository.dart';
import '../model/category.dart';
import '../model/product.dart';

/// Live list of categories. Screens read it with ref.watch(categoriesProvider)
/// and get loading / error / data states for free (AsyncValue).
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchCategories();
});

/// Live list of every product. Other providers below filter this one.
final productsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchProducts();
});

/// Products of one category: ref.watch(productsByCategoryProvider('fashion')).
final productsByCategoryProvider =
    Provider.family<AsyncValue<List<Product>>, String>((ref, categoryId) {
  return ref
      .watch(productsProvider)
      .whenData((all) => all.where((p) => p.categoryId == categoryId).toList());
});

/// A category plus one of its types, e.g. electronics + phones.
typedef CategoryTypeKey = ({String categoryId, String subcategoryId});

final productsBySubcategoryProvider =
    Provider.family<AsyncValue<List<Product>>, CategoryTypeKey>((ref, key) {
  return ref.watch(productsByCategoryProvider(key.categoryId)).whenData(
        (list) =>
            list.where((p) => p.subcategoryId == key.subcategoryId).toList(),
      );
});

/// One product by id, or null if it does not exist (for the detail screen).
final productByIdProvider =
    Provider.family<AsyncValue<Product?>, String>((ref, id) {
  return ref.watch(productsProvider).whenData((all) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  });
});

/// Discounted products, biggest discount first.
final dealsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  return ref.watch(productsProvider).whenData((all) {
    final deals = all.where((p) => p.hasDiscount).toList();
    deals.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    return deals;
  });
});

/// The 10 most reviewed products.
final popularProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  return ref.watch(productsProvider).whenData((all) {
    final sorted = [...all]
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return sorted.take(10).toList();
  });
});