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