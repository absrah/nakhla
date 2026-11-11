import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/state_views.dart';
import '../view_model/catalog_providers.dart';
import '../view_model/search_view_model.dart';
import 'widgets/product_grid.dart';

/// Search over the whole catalog. Results update as you type.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);
    final viewModel = ref.read(searchQueryProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        toolbarHeight: 72.w,
        actions: [SizedBox(width: 20.w)],
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: viewModel.setQuery,
          decoration: InputDecoration(
            hintText: 'Search products, brands…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      viewModel.setQuery('');
                    },
                  ),
          ),
        ),
      ),
      body: query.trim().isEmpty
          ? const EmptyView(
              icon: Icons.search,
              message: 'Type to search products and brands.',
            )
          : results.when(
              loading: () => const LoadingView(),
              error: (error, _) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(productsProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return EmptyView(
                    icon: Icons.search_off,
                    message: 'No results for “${query.trim()}”.',
                  );
                }
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 14.w),
                        child: Text(
                          '${list.length} ${list.length == 1 ? 'result' : 'results'} for “${query.trim()}”',
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
}
