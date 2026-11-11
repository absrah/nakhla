import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../model/checkout_totals.dart';

/// Subtotal, delivery, VAT and total, as a card. Shared by the delivery and
/// payment steps of the checkout.
class TotalsCard extends StatelessWidget {
  const TotalsCard({super.key, required this.totals});

  final CheckoutTotals totals;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    Widget row(String label, String value, {bool bold = false}) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: bold ? 18.sp : 15.sp,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: bold ? null : p.muted,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: bold ? 18.sp : 15.sp,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: bold ? null : onSurface,
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
          row(
            'Subtotal (${totals.itemCount} ${totals.itemCount == 1 ? 'item' : 'items'})',
            formatSar(totals.subtotalExVat),
          ),
          row(
            'Delivery',
            totals.deliveryFee == 0 ? 'Free' : formatSar(totals.deliveryExVat),
          ),
          row('VAT (15%)', formatSar(totals.vat)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.w),
            child: const Divider(),
          ),
          row('Total', formatSar(totals.total), bold: true),
          Padding(
            padding: EdgeInsets.only(top: 2.w),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                'Prices include VAT',
                style: TextStyle(fontSize: 12.sp, color: p.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
