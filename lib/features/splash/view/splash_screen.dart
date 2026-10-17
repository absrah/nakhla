import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_palette.dart';

/// Shown for a moment while Firebase restores the previous session.
/// The router moves on by itself; nothing to tap here.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Placeholder mark until the real logo file is added.
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: p.accent,
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 48.w,
                color: p.onAccent,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Nakhla',
              style: text.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 2.h),
            Text(
              'نخلة',
              style: text.titleMedium?.copyWith(color: p.muted),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: const CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}