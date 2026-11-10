import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../model/order.dart';
import '../../model/order_status.dart';

/// The steps of a delivery, top to bottom: done steps have a check, the
/// current one a dot, the rest are empty circles.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final steps = OrderStatus.timeline;
    final current = steps.indexOf(order.status);
    final delivered = order.status == OrderStatus.delivered;
    final created = order.createdAt;

    final rows = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      final done = i < current || delivered;
      final isCurrent = i == current && !delivered;
      final isLast = i == steps.length - 1;
      final reached = done || isCurrent;

      String? subtitle;
      if (i == 0 && created != null) {
        subtitle = formatOrderDate(created);
      } else if (isCurrent) {
        subtitle = 'Current status';
      }

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: reached ? p.accent : null,
                    border: reached ? null : Border.all(color: p.border),
                  ),
                  child: done
                      ? Icon(Icons.check, size: 15.w, color: p.onAccent)
                      : isCurrent
                          ? Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: p.onAccent,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                ),
                if (!isLast)
                  Container(
                    width: 2.w,
                    height: 30.w,
                    color: i < current || delivered ? p.accent : p.border,
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[i].label,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: reached ? FontWeight.w700 : FontWeight.w500,
                        color: reached ? null : p.muted,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12.sp, color: p.muted),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(children: rows);
  }
}