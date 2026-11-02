import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../../core/widgets/state_views.dart';
import '../../catalog/view_model/catalog_providers.dart';
import '../model/cart_line.dart';
import '../view_model/cart_providers.dart';
import '../view_model/cart_view_model.dart';
import 'cart_thumb.dart';

/// The Cart tab. The cart lives in Firestore, so changes made here (or on
/// another phone) show up at once.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartLinesProvider);
    final summary = ref.watch(cartSummaryProvider);
    final showCheckout = lines.hasValue && !summary.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(summary.isEmpty ? 'My cart' : 'My cart (${summary.itemCount})'),
      ),
      body: lines.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () {
            ref.invalidate(cartItemsProvider);
            ref.invalidate(productsProvider);
          },
        ),
        data: (list) => list.isEmpty
            ? const _EmptyCart()
            : ListView(
                padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                children: [
                  for (final line in list) ...[
                    _CartItemCard(line: line),
                    SizedBox(height: 12.w),
                  ],
                  SizedBox(height: 4.w),
                  _SummaryCard(summary: summary),
                ],
              ),
      ),
      bottomNavigationBar: showCheckout ? _CheckoutBar(summary: summary) : null,
    );
  }
}

/// Runs a cart command and shows its error message, if any.
Future<void> _run(BuildContext context, Future<void> Function() action) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
  } on AppException catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(e.message)));
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 56.w, color: p.muted),
            SizedBox(height: 16.w),
            Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.w),
            Text(
              'Add something you like and it will wait for you here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp, color: p.muted),
            ),
            SizedBox(height: 24.w),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              style: FilledButton.styleFrom(
                minimumSize: Size(200.w, 52.w),
              ),
              child: const Text('Start shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  const _CartItemCard({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final product = line.product;
    final vm = ref.read(cartViewModelProvider);

    String? warning;
    if (!product.inStock) {
      warning = 'Out of stock. Remove it to continue.';
    } else if (line.quantity > product.stock) {
      warning = 'Only ${product.stock} left. Lower the quantity.';
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(AppRoutes.productPath(product.id)),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: p.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CartThumb(product: product),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 2.w),
                  Text(
                    slugToLabel(product.subcategoryId),
                    style: TextStyle(fontSize: 12.sp, color: p.muted),
                  ),
                  if (warning != null) ...[
                    SizedBox(height: 4.w),
                    Text(
                      warning,
                      style: TextStyle(fontSize: 12.sp, color: p.link),
                    ),
                  ],
                  SizedBox(height: 8.w),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatSar(line.total),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      QuantityStepper(
                        quantity: line.quantity,
                        buttonSize: 32,
                        decreaseIsDelete: line.quantity == 1,
                        canIncrease:
                            product.inStock && line.quantity < product.maxOrderQuantity,
                        onDecrease: () => _run(
                          context,
                          () => line.quantity == 1
                              ? vm.remove(product.id)
                              : vm.setQuantity(product, line.quantity - 1),
                        ),
                        onIncrease: () => _run(
                          context,
                          () => vm.setQuantity(product, line.quantity + 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget row(String label, String value, {bool bold = false, Color? color}) {
      final style = TextStyle(
        fontSize: bold ? 18.sp : 15.sp,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        color: color ?? (bold ? null : p.muted),
      );
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.w),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(
              value,
              style: bold
                  ? style
                  : style.copyWith(
                      color: color ?? Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          row('Subtotal', formatSar(summary.subtotal)),
          row('Delivery', summary.delivery == 0 ? 'Free' : formatSar(summary.delivery)),
          if (summary.savings > 0)
            row('You save', formatSar(summary.savings), color: p.link),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.w),
            child: const Divider(),
          ),
          row('Total', formatSar(summary.total), bold: true),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final blocked = summary.hasUnavailable;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (blocked)
            Padding(
              padding: EdgeInsets.only(bottom: 8.w),
              child: Text(
                'Fix the items marked above to continue.',
                style: TextStyle(fontSize: 13.sp, color: p.link),
              ),
            ),
          FilledButton(
            onPressed: blocked
                ? null
                : () {
                    // TEMPORARY until Phase 3 (checkout).
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(content: Text('Checkout comes in the next phase')),
                      );
                  },
            style: FilledButton.styleFrom(minimumSize: Size.fromHeight(56.w)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Checkout'),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formatSar(summary.total)),
                    SizedBox(width: 4.w),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}