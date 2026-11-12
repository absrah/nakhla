import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../model/product.dart';
import 'product_image.dart';
import '../../../wishlist/view/wishlist_button.dart';

/// Smaller card for the horizontal "Deals" row on Home (no button).
class DealCard extends StatelessWidget {
  const DealCard({super.key, required this.product});

  final Product product;

  /// Total height of the card, for the row that holds it.
  static double get height => 232.w;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;

    return SizedBox(
      width: 168.w,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push(AppRoutes.productPath(product.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ProductImage(product: product, height: 150.w),
                PositionedDirectional(
                  top: 8.w,
                  end: 8.w,
                  child: WishlistButton(product: product, size: 32),
                ),
              ],
            ),
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
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8.w,
              children: [
                Text(
                  formatSar(product.price),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
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
          ],
        ),
      ),
    );
  }
}
