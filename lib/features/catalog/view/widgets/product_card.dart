import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../cart/view/add_to_cart.dart';
import '../../model/product.dart';
import 'product_image.dart';
import '../../../cart/view_model/cart_providers.dart';

/// Product card for the 2-column grids: image, name, rating, price and the
/// lime "Add to cart" button. Tapping the card opens the product.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  /// Height of everything under the image. The grid adds it to the card width.
  static double get belowImage => 156.w;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    // Grey once the cart already holds the most that may be bought.
    final inCart = ref.watch(cartQuantityProvider(product.id));
    final canAdd = product.inStock && inCart < product.maxOrderQuantity;
    final label = !product.inStock
        ? 'Out of stock'
        : (canAdd ? 'Add to cart' : 'Max in cart');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(AppRoutes.productPath(product.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(product: product),
          SizedBox(height: 8.w),
          SizedBox(
            height: 40.w,
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(height: 4.w),
          Row(
            children: [
              Icon(Icons.star_rounded, size: 16.w, color: p.sale),
              SizedBox(width: 4.w),
              Text(
                product.rating.toStringAsFixed(1),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 4.w),
              Text(
                '(${formatCount(product.reviewCount)})',
                style: TextStyle(fontSize: 13.sp, color: p.muted),
              ),
            ],
          ),
          SizedBox(height: 4.w),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8.w,
            children: [
              Text(
                formatSar(product.price),
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
              ),
              if (product.hasDiscount)
                Text(
                  formatSar(product.oldPrice!),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: p.muted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.w),
          SizedBox(
            height: 44.w,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canAdd ? () => addToCart(context, ref, product) : null,
              icon: Icon(canAdd ? Icons.add : Icons.block, size: 18.w),
              label: Text(label, style: TextStyle(fontSize: 15.sp)),
              style: FilledButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
