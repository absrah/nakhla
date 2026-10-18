import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../model/product.dart';

/// Placeholder for a product photo (we have no image storage yet):
/// a tinted tile, a soft circle, the sale tag and the small type label.
/// Square when [height] is null, otherwise full width at that height.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product, this.height});

  final Product product;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tile = ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: ColoredBox(
        color: p.tileFor(product.id),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Container(
                width: 84.w,
                height: 84.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.6),
                ),
              ),
            ),
            if (product.hasDiscount)
              Positioned(
                top: 12.w,
                left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
                  decoration: BoxDecoration(
                    color: p.sale,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '-${product.discountPercent}%',
                    style: TextStyle(
                      color: p.onSale,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 14.w,
              bottom: 12.w,
              child: Text(
                slugToLabel(product.subcategoryId),
                style: TextStyle(
                  color: p.muted,
                  fontSize: 11.sp,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (height == null) return AspectRatio(aspectRatio: 1, child: tile);
    return SizedBox(height: height, width: double.infinity, child: tile);
  }
}