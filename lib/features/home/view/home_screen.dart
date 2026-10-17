import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_mode_notifier.dart';
import '../../auth/model/auth_repository.dart';
import '../../auth/view_model/session_provider.dart';

/// TEMPORARY placeholder: proves the session works.
/// Replaced by the real Home screen in Phase 2.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged in'),
        actions: [
          IconButton(
            tooltip: 'Switch light / dark',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeModeNotifier.value =
                isDark ? ThemeMode.light : ThemeMode.dark,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if ((user?.displayName ?? '').isNotEmpty)
              Text(
                user!.displayName!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            Text(user?.email ?? ''),
            SizedBox(height: 4.h),
            Text(
              user?.uid ?? '',
              style: TextStyle(color: p.muted, fontSize: 12.sp),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}