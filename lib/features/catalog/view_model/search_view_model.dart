import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/product.dart';
import 'catalog_providers.dart';

/// What the user has typed in the search field.
class SearchQueryViewModel extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final searchQueryProvider =
    NotifierProvider.autoDispose<SearchQueryViewModel, String>(
      SearchQueryViewModel.new,
    );

/// Products matching every word typed, in the name (English or Arabic),
/// the brand or the keywords. Empty query gives an empty list.
final searchResultsProvider = Provider.autoDispose<AsyncValue<List<Product>>>((
  ref,
) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final products = ref.watch(productsProvider);

  if (query.isEmpty) return const AsyncData<List<Product>>([]);

  final words = query.split(RegExp(r'\s+'));
  return products.whenData((all) {
    return all.where((p) {
      final text = '${p.name} ${p.nameAr} ${p.brand} ${p.keywords.join(' ')}'
          .toLowerCase();
      return words.every(text.contains);
    }).toList();
  });
});
