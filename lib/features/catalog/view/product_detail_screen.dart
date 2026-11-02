import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../../core/widgets/state_views.dart';
import '../../cart/view/add_to_cart.dart';
import '../model/product.dart';
import '../view_model/catalog_providers.dart';
import 'widgets/product_image.dart';
import 'widgets/rating_stars.dart';

/// One product: picture, price, stock, quantity and the Add to cart bar.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productByIdProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: _back,
        ),
      ),
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
          return _Body(
            product: p,
            quantity: _quantity,
            onQuantity: (q) => setState(() => _quantity = q),
          );
        },
      ),
      bottomNavigationBar: product.value == null
          ? null
          : _BottomBar(product: product.value!, quantity: _quantity),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.product,
    required this.quantity,
    required this.onQuantity,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantity;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final max = product.maxOrderQuantity;

    final String stockText;
    final Color stockColor;
    if (!product.inStock) {
      stockText = 'Out of stock';
      stockColor = p.link;
    } else if (product.stock <= 5) {
      stockText = 'Only ${product.stock} left';
      stockColor = p.link;
    } else {
      stockText = 'In stock';
      stockColor = scheme.primary;
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
          child: ProductImage(product: product, height: 300.w),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${product.brand}  ·  ${slugToLabel(product.subcategoryId)}'.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.sp,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                  color: p.muted,
                ),
              ),
              SizedBox(height: 6.w),
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 10.w),
              Row(
                children: [
                  RatingStars(rating: product.rating, size: 18),
                  SizedBox(width: 8.w),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '· ${formatCount(product.reviewCount)} reviews',
                    style: TextStyle(fontSize: 14.sp, color: p.muted),
                  ),
                ],
              ),
              SizedBox(height: 14.w),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10.w,
                children: [
                  Text(
                    formatSar(product.price),
                    style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700),
                  ),
                  if (product.hasDiscount) ...[
                    Text(
                      formatSar(product.oldPrice!),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: p.muted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
                      decoration: BoxDecoration(
                        color: p.sale,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: TextStyle(
                          color: p.onSale,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 20.w),
              Row(
                children: [
                  if (product.inStock)
                    QuantityStepper(
                      quantity: quantity > max ? max : quantity,
                      canDecrease: quantity > 1,
                      canIncrease: quantity < max,
                      onDecrease: () => onQuantity(quantity - 1),
                      onIncrease: () => onQuantity(quantity + 1),
                    ),
                  const Spacer(),
                  Icon(
                    product.inStock ? Icons.check_circle_outline : Icons.cancel_outlined,
                    size: 18.w,
                    color: stockColor,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    stockText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: stockColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.w),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: p.border),
                ),
                child: Column(
                  children: [
                    _Perk(icon: Icons.local_shipping_outlined, text: 'Free delivery'),
                    SizedBox(height: 10.w),
                    _Perk(icon: Icons.payments_outlined, text: 'Pay cash on delivery'),
                  ],
                ),
              ),
              SizedBox(height: 24.w),
              Text(
                'Description',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8.w),
              Text(
                product.description,
                style: TextStyle(fontSize: 15.sp, height: 1.5, color: p.muted),
              ),
              SizedBox(height: 24.w),
              Text(
                'Reviews',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10.w),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 14.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RatingStars(rating: product.rating, size: 20),
                      SizedBox(height: 4.w),
                      Text(
                        'Based on ${formatCount(product.reviewCount)} reviews',
                        style: TextStyle(fontSize: 13.sp, color: p.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22.w),
        SizedBox(width: 12.w),
        Text(text, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final qty = quantity > product.maxOrderQuantity
        ? product.maxOrderQuantity
        : quantity;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: TextStyle(fontSize: 13.sp, color: p.muted)),
                Text(
                  formatSar(product.price * (product.inStock ? qty : 1)),
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: FilledButton.icon(
                onPressed: product.inStock
                    ? () => addToCart(context, ref, product, quantity: qty)
                    : null,
                icon: Icon(Icons.shopping_cart_outlined, size: 20.w),
                label: Text(product.inStock ? 'Add to cart' : 'Out of stock'),
                style: FilledButton.styleFrom(minimumSize: Size.fromHeight(56.w)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}