import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/state_views.dart';
import '../model/product.dart';
import '../view_model/catalog_providers.dart';
import 'widgets/product_grid.dart';

/// A grid of products for one category, one type inside a category, or all
/// deals. Opened on top of the tabs, so it has its own back arrow.
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({
    super.key,
    this.categoryId,
    this.subcategoryId,
    this.dealsOnly = false,
  });

  final String? categoryId;
  final String? subcategoryId;
  final bool dealsOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Product>> products;
    if (dealsOnly) {
      products = ref.watch(dealsProvider);
    } else if (categoryId != null && subcategoryId != null) {
      products = ref.watch(
        productsBySubcategoryProvider((
          categoryId: categoryId!,
          subcategoryId: subcategoryId!,
        )),
      );
    } else if (categoryId != null) {
      products = ref.watch(productsByCategoryProvider(categoryId!));
    } else {
      products = ref.watch(productsProvider);
    }

    return Scaffold(
      appBar: AppBar(title: Text(_title(ref))),
      body: products.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(productsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyView(
              icon: Icons.inventory_2_outlined,
              message: 'No products here yet.',
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 4.w, 20.w, 14.w),
                  child: Text(
                    '${list.length} ${list.length == 1 ? 'product' : 'products'}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: context.palette.muted,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverProductGrid(products: list),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 24.w)),
            ],
          );
        },
      ),
    );
  }

  /// "Deals", the type name ("Phones"), the category name, or a fallback.
  String _title(WidgetRef ref) {
    if (dealsOnly) return 'Deals';
    final categories = ref.watch(categoriesProvider).value ?? const [];
    for (final c in categories) {
      if (c.id != categoryId) continue;
      for (final s in c.subcategories) {
        if (s.id == subcategoryId) return s.name;
      }
      return c.name;
    }
    return 'Products';
  }
}
