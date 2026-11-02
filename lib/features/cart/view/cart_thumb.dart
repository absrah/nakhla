import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_palette.dart';
import '../../catalog/model/product.dart';

/// Small square stand-in for a product photo, used in the cart.
class CartThumb extends StatelessWidget {
  const CartThumb({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: SizedBox(
        width: 88.w,
        height: 88.w,
        child: ColoredBox(
          color: p.tileFor(product.id),
          child: Center(
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}