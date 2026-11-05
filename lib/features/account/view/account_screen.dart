import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_mode_notifier.dart';
import '../../auth/model/auth_repository.dart';
import '../../auth/view_model/session_provider.dart';
import '../../catalog/model/catalog_seeder.dart';
import '../../onboarding/view_model/onboarding_view_model.dart';

/// TEMPORARY placeholder: your email, Log out, and the developer tools that
/// used to live on Home. The real Account screen is built in Phase 4.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          if ((user?.displayName ?? '').isNotEmpty)
            Text(
              user!.displayName!,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
          Text(user?.email ?? ''),
          SizedBox(height: 4.w),
          Text(
            user?.uid ?? '',
            style: TextStyle(color: p.muted, fontSize: 12.sp),
          ),
          SizedBox(height: 24.w),
                    OutlinedButton(
            onPressed: () => context.push(AppRoutes.addresses),
            child: const Text('My addresses'),
          ),
          SizedBox(height: 12.w),
          OutlinedButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            child: const Text('Log out'),
          ),
          SizedBox(height: 32.w),
          Text(
            'Developer tools (temporary)',
            style: TextStyle(color: p.muted, fontSize: 13.sp),
          ),
          SizedBox(height: 12.w),
          OutlinedButton(
            onPressed: () => themeModeNotifier.value =
                isDark ? ThemeMode.light : ThemeMode.dark,
            child: Text(isDark ? 'Switch to light' : 'Switch to dark'),
          ),
          SizedBox(height: 12.w),
          OutlinedButton(
            onPressed: () {
              ref.read(onboardingSeenProvider.notifier).reset();
              context.go(AppRoutes.onboarding);
            },
            child: const Text('Show intro again'),
          ),
          SizedBox(height: 12.w),
          OutlinedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final count = await ref.read(catalogSeederProvider).seed();
                messenger.showSnackBar(
                  SnackBar(content: Text('Wrote $count documents')),
                );
              } on AppException catch (e) {
                messenger.showSnackBar(SnackBar(content: Text(e.message)));
              }
            },
            child: const Text('Seed catalog (admin only)'),
          ),
        ],
      ),
    );
  }
}