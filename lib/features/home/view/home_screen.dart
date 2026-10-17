import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_mode_notifier.dart';
import '../../auth/model/auth_repository.dart';
import '../../auth/view_model/session_provider.dart';
import '../../onboarding/view_model/onboarding_view_model.dart';

/// TEMPORARY placeholder for testing guest vs logged-in behavior.
/// Replaced by the real Home screen in Phase 2.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final isGuest = user == null;
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isGuest ? 'Home (guest)' : 'Home (logged in)'),
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
            if (isGuest)
              Text('Browsing as a guest', style: text.titleLarge)
            else ...[
              if ((user.displayName ?? '').isNotEmpty)
                Text(user.displayName!, style: text.titleLarge),
              Text(user.email ?? ''),
              SizedBox(height: 4.h),
              Text(
                user.uid,
                style: TextStyle(color: p.muted, fontSize: 12.sp),
              ),
            ],
            SizedBox(height: 24.h),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.cart),
              child: const Text('Open cart (needs login)'),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () async {
                await ref.read(onboardingSeenProvider.notifier).reset();
                if (!context.mounted) return;
                context.go(AppRoutes.onboarding);
              },
              child: const Text('Show intro again (testing)'),
            ),
            const Spacer(),
            if (isGuest)
              FilledButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Log in'),
              )
            else
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