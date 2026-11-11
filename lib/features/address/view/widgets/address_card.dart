import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';
import '../../model/address.dart';

/// One address as a card: label, name, street, city, phone.
/// Used in the address list and on the checkout screen.
class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    this.selected = false,
    this.trailing,
    this.onTap,
  });

  final Address address;
  final bool selected; // highlighted border (the chosen address)
  final Widget? trailing; // buttons on the right (edit, delete, change...)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? scheme.primary : p.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.w),
              child: Icon(Icons.location_on_outlined, size: 22.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.w,
                    ),
                    decoration: BoxDecoration(
                      color: p.accent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      address.label,
                      style: TextStyle(
                        color: p.onAccent,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.w),
                  Text(
                    address.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.w),
                  Text(
                    address.streetLine,
                    style: TextStyle(fontSize: 14.sp, color: p.muted),
                  ),
                  Text(
                    address.cityLine,
                    style: TextStyle(fontSize: 14.sp, color: p.muted),
                  ),
                  SizedBox(height: 2.w),
                  Text(
                    address.phone,
                    style: TextStyle(fontSize: 14.sp, color: p.muted),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
