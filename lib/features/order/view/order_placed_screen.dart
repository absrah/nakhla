import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../model/order.dart';
import '../view_model/order_providers.dart';

/// Shown right after an order is placed. Back goes to Home, never back to
/// the checkout.
class OrderPlacedScreen extends ConsumerWidget {
  const OrderPlacedScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider(orderId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        body: SafeArea(
          child: order.when(
            loading: () => const LoadingView(),
            error: (error, _) => _Problem(
              child: ErrorView(
                error: error,
                onRetry: () => ref.invalidate(ordersProvider),
              ),
            ),
            data: (o) => o == null
                ? const _Problem(
                    child: EmptyView(
                      icon: Icons.search_off,
                      message: 'We could not find this order.',
                    ),
                  )
                : _Done(order: o),
          ),
        ),
      ),
    );
  }
}

/// A message with a way out to Home.
class _Problem extends StatelessWidget {
  const _Problem({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child),
        Padding(
          padding: EdgeInsets.all(20.w),
          child: FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Back to home'),
          ),
        ),
      ],
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget row(String label, String value) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15.sp, color: p.muted),
              ),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 40.w, 20.w, 20.w),
            child: Column(
              children: [
                Container(
                  width: 96.w,
                  height: 96.w,
                  decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
                  child: Icon(Icons.check, size: 52.w, color: p.onAccent),
                ),
                SizedBox(height: 24.w),
                Text(
                  'Order placed!',
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8.w),
                Text(
                  'Thanks for shopping with us. You will pay in cash when your order arrives.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.sp, height: 1.4, color: p.muted),
                ),
                SizedBox(height: 28.w),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: p.border),
                  ),
                  child: Column(
                    children: [
                      row('Order number', '#${order.number}'),
                      row('Estimated delivery', order.deliveryOption.eta),
                      row('Amount to pay', formatSar(order.total)),
                      row('Payment', 'Cash on delivery'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.w),
          child: Column(
            children: [
              FilledButton(
                onPressed: () => context.push(AppRoutes.orderPath(order.id)),
                child: const Text('Track order'),
              ),
              SizedBox(height: 12.w),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Continue shopping'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}