import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';

/// TEMPORARY: lets us flip light/dark while testing the theme.
/// Replaced by a real setting (saved with shared_preferences) in Phase 4.
final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.system);

class NakhlaApp extends StatelessWidget {
  const NakhlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 390 x 844 is the size the screens were designed at.
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeMode,
        builder: (context, mode, _) => MaterialApp(
          title: 'Nakhla',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const _ThemePreview(),
        ),
      ),
    );
  }
}

/// Temporary screen to check both themes. Replaced when the router is added.
class _ThemePreview extends StatelessWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme preview'),
        actions: [
          IconButton(
            tooltip: 'Switch light / dark',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => _themeMode.value =
                isDark ? ThemeMode.light : ThemeMode.dark,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Text(
            'Nakhla',
            style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4.h),
          Text(
            'Everything you need, in one place.',
            style: text.bodyMedium?.copyWith(color: p.muted),
          ),
          SizedBox(height: 24.h),
          const TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          SizedBox(height: 12.h),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () {},
              child: const Text('Forgot password?'),
            ),
          ),
          SizedBox(height: 24.h),
          FilledButton(onPressed: () {}, child: const Text('Log in')),
          SizedBox(height: 12.h),
          OutlinedButton(onPressed: () {}, child: const Text('Sign up')),
          SizedBox(height: 32.h),
          Row(
            children: [
              for (var i = 0; i < p.tiles.length; i++)
                Expanded(
                  child: Container(
                    height: 64.h,
                    margin: EdgeInsets.only(
                      right: i == p.tiles.length - 1 ? 0 : 8.w,
                    ),
                    decoration: BoxDecoration(
                      color: p.tiles[i],
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: p.sale,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '-20%',
                style: TextStyle(
                  color: p.onSale,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}