import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../catalog/view/widgets/product_grid.dart';
import '../view_model/wishlist_providers.dart';

/// My wishlist (opened from Account): the products saved with the heart.
/// Each card keeps its heart and its Add to cart button.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(wishlistProductsProvider);
    final count = saved.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallback: AppRoutes.account),
        title: Text(count == 0 ? 'Wishlist' : 'Wishlist ($count)'),
      ),
      body: saved.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(wishlistEntriesProvider),
        ),
        data: (products) => products.isEmpty
            ? const EmptyView(
                icon: Icons.favorite_border,
                message:
                    'Your wishlist is empty.\nTap the heart on a product to save it.',
              )
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                    sliver: SliverProductGrid(products: products),
                  ),
                ],
              ),
      ),
    );
  }
}
