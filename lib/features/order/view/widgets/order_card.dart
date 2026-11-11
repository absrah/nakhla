import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../model/order.dart';
import '../../model/order_status.dart';

/// Small pill with the order status. Delivered is lime, cancelled is red,
/// everything on its way is outlined.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final Color? background;
    final Color foreground;
    final Color border;

    switch (status) {
      case OrderStatus.delivered:
        background = p.accent;
        foreground = p.onAccent;
        border = p.accent;
      case OrderStatus.cancelled:
        background = null;
        foreground = p.link;
        border = p.link;
      default:
        background = null;
        foreground = Theme.of(context).colorScheme.onSurface;
        border = p.accent;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: border),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

/// One order in the "My orders" list.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final created = order.createdAt;
    final count = order.itemCount;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(AppRoutes.orderPath(order.id)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: p.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.number}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            SizedBox(height: 6.w),
            Text(
              created == null ? 'Just now' : formatOrderDate(created),
              style: TextStyle(fontSize: 13.sp, color: p.muted),
            ),
            SizedBox(height: 10.w),
            Text(
              '$count ${count == 1 ? 'item' : 'items'} · ${formatSar(order.total)}',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.w),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(44.w),
              ),
              onPressed: () => context.push(AppRoutes.orderPath(order.id)),
              child: Text(
                order.status.isActive ? 'Track order' : 'View details',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
