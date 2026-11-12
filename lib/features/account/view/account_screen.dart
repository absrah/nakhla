import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../auth/model/auth_repository.dart';
import '../../auth/view_model/session_provider.dart';
import '../../catalog/model/catalog_seeder.dart';
import '../../onboarding/view_model/onboarding_view_model.dart';
import '../view_model/profile_providers.dart';

/// The Account tab: who you are, shortcuts, appearance, log out.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _confirmLogOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(profileProvider).value;
    final mode = ref.watch(themeModeProvider);
    final p = context.palette;

    // The profile document is the source; fall back to the login account.
    final name = (profile?.name ?? '').isNotEmpty
        ? profile!.name
        : (user?.displayName ?? '');
    final email = profile?.email ?? user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 32.w),
        children: [
          _ProfileHeader(name: name, email: email),
          SizedBox(height: 24.w),
          _MenuTile(
            icon: Icons.person_outline,
            label: 'Edit profile',
            onTap: () => context.push(AppRoutes.editProfile),
          ),
          SizedBox(height: 10.w),
          _MenuTile(
            icon: Icons.receipt_long_outlined,
            label: 'My orders',
            onTap: () => context.push(AppRoutes.orders),
          ),
          SizedBox(height: 10.w),
          _MenuTile(
            icon: Icons.favorite_border,
            label: 'My wishlist',
            onTap: () => context.push(AppRoutes.wishlist),
          ),
          SizedBox(height: 10.w),
          _MenuTile(
            icon: Icons.location_on_outlined,
            label: 'My addresses',
            onTap: () => context.push(AppRoutes.addresses),
          ),
          SizedBox(height: 24.w),
          Text(
            'Appearance',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.w),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {mode},
              onSelectionChanged: (selection) =>
                  ref.read(themeModeProvider.notifier).set(selection.first),
            ),
          ),
          SizedBox(height: 24.w),
          OutlinedButton(
            onPressed: () => _confirmLogOut(context, ref),
            child: const Text('Log out'),
          ),

          // Developer tools only exist in debug builds.
          if (kDebugMode) ...[
            SizedBox(height: 32.w),
            Text(
              'Developer tools (debug builds only)',
              style: TextStyle(color: p.muted, fontSize: 13.sp),
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
        ],
      ),
    );
  }
}

/// Initial in a lime circle, then the name and email.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final initial = name.isNotEmpty
        ? name.substring(0, 1).toUpperCase()
        : (email.isNotEmpty ? email.substring(0, 1).toUpperCase() : '?');

    return Row(
      children: [
        Container(
          width: 64.w,
          height: 64.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: p.onAccent,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (name.isNotEmpty)
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.sp, color: p.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: p.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
          child: Row(
            children: [
              Icon(icon, size: 22.w),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 22.w, color: p.muted),
            ],
          ),
        ),
      ),
    );
  }
}
