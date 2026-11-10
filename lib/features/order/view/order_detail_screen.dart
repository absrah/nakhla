import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../checkout/model/checkout_totals.dart';
import '../../checkout/view/widgets/totals_card.dart';
import '../model/order.dart';
import '../model/order_status.dart';
import '../view_model/order_providers.dart';
import '../view_model/order_view_model.dart';
import 'widgets/order_card.dart';
import 'widgets/order_timeline.dart';

/// One order: status timeline, items, address, delivery, totals, and
/// (while still "placed") a Cancel button.
class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _cancelling = false;

  Future<void> _cancel(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _cancelling = true);
    try {
      await ref.read(orderViewModelProvider).cancelOrder(order.id);
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
    if (mounted) setState(() => _cancelling = false);
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderByIdProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallback: AppRoutes.orders),
        title: const Text('Order details'),
      ),
      body: order.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(ordersProvider),
        ),
        data: (o) => o == null
            ? const EmptyView(
                icon: Icons.search_off,
                message: 'We could not find this order.',
              )
            : _Details(
                order: o,
                cancelling: _cancelling,
                onCancel: () => _cancel(o),
              ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.order,
    required this.cancelling,
    required this.onCancel,
  });

  final Order order;
  final bool cancelling;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final created = order.createdAt;
    final address = order.address;

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 32.w),
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text(
                'Order #${order.number}',
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
              ),
            ),
            OrderStatusChip(status: order.status),
          ],
        ),
        SizedBox(height: 4.w),
        Text(
          created == null ? 'Just now' : 'Placed ${formatOrderDate(created)}',
          style: TextStyle(fontSize: 13.sp, color: p.muted),
        ),
        SizedBox(height: 20.w),

        // Progress
        if (order.status == OrderStatus.cancelled)
          _Card(
            child: Row(
              children: [
                Icon(Icons.cancel_outlined, color: p.link, size: 24.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'This order was cancelled.',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: p.link,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          _Card(child: OrderTimeline(order: order)),
        SizedBox(height: 20.w),

        // Items
        const _Title('Items'),
        SizedBox(height: 12.w),
        _Card(
          child: Column(
            children: [
              for (final item in order.items)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity} × ${item.name}',
                          style: TextStyle(fontSize: 14.sp, height: 1.3),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        formatSar(item.lineTotal),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 20.w),

        // Delivery
        const _Title('Delivery'),
        SizedBox(height: 12.w),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${address.label} · ${address.name}',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4.w),
              Text(
                '${address.streetLine}\n${address.cityLine}\n${address.phone}',
                style: TextStyle(fontSize: 14.sp, height: 1.4, color: p.muted),
              ),
              SizedBox(height: 12.w),
              Text(
                '${order.deliveryOption.title} · ${order.deliveryOption.eta}',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.w),
              Text(
                'Payment: Cash on delivery',
                style: TextStyle(fontSize: 14.sp, color: p.muted),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.w),

        // Totals
        const _Title('Summary'),
        SizedBox(height: 12.w),
        TotalsCard(
          totals: CheckoutTotals(
            itemCount: order.itemCount,
            subtotal: order.subtotal,
            deliveryFee: order.deliveryFee,
          ),
        ),

        if (order.status == OrderStatus.placed) ...[
          SizedBox(height: 24.w),
          OutlinedButton(
            onPressed: cancelling ? null : onCancel,
            child: Text(cancelling ? 'Cancelling…' : 'Cancel order'),
          ),
        ],
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.palette.border),
      ),
      child: child,
    );
  }
}