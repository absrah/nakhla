import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/model/auth_repository.dart';
import 'features/auth/view/sign_in_screen.dart';
import 'features/auth/view_model/session_provider.dart';

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
          home: const _TempGate(),
        ),
      ),
    );
  }
}

/// TEMPORARY: picks the screen from the session. Replaced by the router.
class _TempGate extends ConsumerWidget {
  const _TempGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    return auth.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (user) => user == null
          ? const SignInScreen()
          : _SignedInPlaceholder(
              name: user.displayName ?? '',
              email: user.email ?? '',
              uid: user.uid,
            ),
    );
  }
}

/// TEMPORARY: proves the session works. Replaced by the real home screen.
class _SignedInPlaceholder extends ConsumerWidget {
  const _SignedInPlaceholder({
    required this.name,
    required this.email,
    required this.uid,
  });

  final String name;
  final String email;
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signed in'),
        actions: [
          IconButton(
            tooltip: 'Switch light / dark',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () =>
                _themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (name.isNotEmpty)
              Text(name, style: Theme.of(context).textTheme.titleLarge),
            Text(email),
            SizedBox(height: 4.h),
            Text(uid, style: TextStyle(color: p.muted, fontSize: 12.sp)),
            const Spacer(),
            OutlinedButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}