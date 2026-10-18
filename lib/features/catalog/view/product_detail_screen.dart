import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../view_model/catalog_providers.dart';
import 'widgets/product_image.dart';

/// TEMPORARY simple version so tapping a product works.
/// The real product detail screen is built in the next step.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productByIdProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: product.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(productsProvider),
        ),
        data: (p) {
          if (p == null) {
            return const EmptyView(
              icon: Icons.search_off,
              message: 'This product was not found.',
            );
          }
          return ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              ProductImage(product: p, height: 280.w),
              SizedBox(height: 16.w),
              Text(
                p.name,
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8.w),
              Text(
                formatSar(p.price),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12.w),
              Text(
                p.description,
                style: TextStyle(fontSize: 15.sp, color: context.palette.muted),
              ),
            ],
          );
        },
      ),
    );
  }
}