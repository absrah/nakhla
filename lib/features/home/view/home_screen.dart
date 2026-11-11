import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/view_model/session_provider.dart';
import '../../catalog/view/widgets/deal_card.dart';
import '../../catalog/view/widgets/product_grid.dart';
import '../../catalog/view/widgets/search_bar_button.dart';
import '../../catalog/view_model/catalog_providers.dart';

/// The first tab: header, search, banner, categories, deals, popular products.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popular = ref.watch(popularProductsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _HomeTop()),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 28.w, 20.w, 14.w),
                child: const _SectionTitle('Popular right now'),
              ),
            ),
            popular.when(
              data: (products) => SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverProductGrid(products: products),
              ),
              loading: () => SliverToBoxAdapter(
                child: SizedBox(height: 160.w, child: const LoadingView()),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: SizedBox(
                  height: 200.w,
                  child: ErrorView(
                    error: error,
                    onRetry: () => ref.invalidate(productsProvider),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 24.w)),
          ],
        ),
      ),
    );
  }
}

/// Everything above the product grid.
class _HomeTop extends ConsumerWidget {
  const _HomeTop();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final dealList = ref.watch(dealsProvider).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 0),
          child: const _Header(),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 0),
          child: const SearchBarButton(),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.w, 20.w, 0),
          child: _Banner(
            maxDiscount: dealList.isEmpty ? 0 : dealList.first.discountPercent,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 28.w, 20.w, 14.w),
          child: _SectionTitle(
            'Categories',
            onSeeAll: () => context.go(AppRoutes.categories),
          ),
        ),
        categories.when(
          data: (list) => SizedBox(
            height: 112.w,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: list.length,
              separatorBuilder: (_, _) => SizedBox(width: 12.w),
              itemBuilder: (context, i) =>
                  _CategoryCircle(id: list[i].id, name: list[i].name),
            ),
          ),
          loading: () => SizedBox(height: 112.w, child: const LoadingView()),
          error: (error, _) => SizedBox(
            height: 160.w,
            child: ErrorView(
              error: error,
              onRetry: () => ref.invalidate(categoriesProvider),
            ),
          ),
        ),
        // Deals row: hidden when there are no discounted products.
        if (dealList.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 28.w, 20.w, 14.w),
            child: _SectionTitle(
              'Deals',
              onSeeAll: () => context.push(AppRoutes.deals),
            ),
          ),
          SizedBox(
            height: DealCard.height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: dealList.take(8).length,
              separatorBuilder: (_, _) => SizedBox(width: 12.w),
              itemBuilder: (context, i) => DealCard(product: dealList[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final isGuest = ref.watch(authStateProvider).value == null;

    return Row(
      children: [
        // Placeholder mark until the real logo file is added.
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: p.accent,
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 20.w,
            color: p.onAccent,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'nakhla',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const Spacer(),
        if (isGuest)
          TextButton(
            // go, not push: the router must see the log in screen.
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Log in'),
          ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.maxDiscount});

  final int maxDiscount;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // The banner uses the brand colors in light AND dark, on purpose.
    return Container(
      width: double.infinity,
      height: 172.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34.w,
            top: -44.w,
            child: Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(color: p.sale, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: 44.w,
            bottom: -96.w,
            child: Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                color: p.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TODAY\'S DEALS',
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.7,
                  ),
                ),
                SizedBox(height: 8.w),
                SizedBox(
                  width: 200.w,
                  child: Text(
                    maxDiscount > 0
                        ? 'Up to $maxDiscount% off top picks'
                        : 'Discover what is new',
                    style: TextStyle(
                      color: AppColors.fog,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => context.push(AppRoutes.deals),
                  style: FilledButton.styleFrom(
                    minimumSize: Size(0, 44.w),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('Shop now', style: TextStyle(fontSize: 15.sp)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
          ),
        ),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

class _CategoryCircle extends StatelessWidget {
  const _CategoryCircle({required this.id, required this.name});

  final String id;
  final String name;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(AppRoutes.categoryPath(id)),
      child: SizedBox(
        width: 84.w,
        child: Column(
          children: [
            Container(
              width: 68.w,
              height: 68.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.tileFor(id),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.65),
                ),
              ),
            ),
            SizedBox(height: 8.w),
            Text(
              name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
