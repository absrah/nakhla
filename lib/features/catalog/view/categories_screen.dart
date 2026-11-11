import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/state_views.dart';
import '../model/category.dart';
import '../view_model/catalog_providers.dart';
import 'widgets/search_bar_button.dart';

/// Second tab: a list of categories on the left, and on the right the types
/// inside the selected one ("shop by type").
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categories.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyView(
              icon: Icons.category_outlined,
              message: 'No categories yet.',
            );
          }
          final selected = list.firstWhere(
            (c) => c.id == _selectedId,
            orElse: () => list.first,
          );
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 4.w, 20.w, 12.w),
                child: const SearchBarButton(hint: 'Search in all categories'),
              ),
              Expanded(
                child: Row(
                  children: [
                    _Rail(
                      categories: list,
                      selectedId: selected.id,
                      onSelect: (id) => setState(() => _selectedId = id),
                    ),
                    Expanded(child: _TypesPane(category: selected)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Category> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final page = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      width: 104.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: p.border)),
      ),
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final c = categories[i];
          final isSelected = c.id == selectedId;
          return InkWell(
            onTap: () => onSelect(c.id),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.w),
              decoration: BoxDecoration(
                color: isSelected ? page : null,
                border: Border(
                  left: BorderSide(
                    color: isSelected ? p.accent : Colors.transparent,
                    width: 4.w,
                  ),
                ),
              ),
              child: Text(
                c.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? null : p.muted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TypesPane extends ConsumerWidget {
  const _TypesPane({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = ref
        .watch(productsByCategoryProvider(category.id))
        .value
        ?.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand card: same colors in light and dark, on purpose.
          GestureDetector(
            onTap: () => context.push(AppRoutes.categoryPath(category.id)),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SHOP ALL',
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 11.sp,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.w),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: AppColors.fog,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (count != null)
                          Text(
                            '$count products',
                            style: TextStyle(
                              color: AppColors.fog.withValues(alpha: 0.7),
                              fontSize: 13.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: p.accent, size: 22.w),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.w),
          Text(
            'SHOP BY TYPE',
            style: TextStyle(
              color: p.muted,
              fontSize: 11.sp,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.w),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 10.w,
            crossAxisSpacing: 10.w,
            childAspectRatio: 0.82,
            children: [
              for (final sub in category.subcategories)
                GestureDetector(
                  onTap: () => context.push(
                    AppRoutes.categoryPath(category.id, type: sub.id),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: p.tileFor(sub.id),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(
                              alpha: isDark ? 0.10 : 0.65,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.w),
                        Text(
                          sub.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
