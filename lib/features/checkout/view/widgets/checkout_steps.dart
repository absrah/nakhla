import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';

/// Address · Delivery · Payment progress row at the top of the checkout.
/// [step] is the current one (2 = delivery, 3 = payment). Earlier steps show
/// a check. With [addressDone] false, step 1 stays a plain "1" (no address
/// has been chosen yet).
class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({super.key, required this.step, this.addressDone = true});

  final int step;
  final bool addressDone;

  static const _labels = ['Address', 'Delivery', 'Payment'];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final children = <Widget>[];

    for (var i = 1; i <= 3; i++) {
      final done = i < step && (i != 1 || addressDone);
      final active = i == step;
      final highlighted = done || active;

      if (i > 1) {
        children.add(
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Divider(color: p.border),
            ),
          ),
        );
      }

      children.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlighted ? p.accent : null,
                border: highlighted ? null : Border.all(color: p.border),
              ),
              child: done
                  ? Icon(Icons.check, size: 15.w, color: p.onAccent)
                  : Text(
                      '$i',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: active ? p.onAccent : p.muted,
                      ),
                    ),
            ),
            SizedBox(width: 6.w),
            Text(
              _labels[i - 1],
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                color: highlighted ? null : p.muted,
              ),
            ),
          ],
        ),
      );
    }

    return Row(children: children);
  }
}