import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/view/forgot_password_screen.dart';
import '../../features/auth/view/log_in_screen.dart';
import '../../features/auth/view/sign_up_screen.dart';
import '../../features/auth/view_model/session_provider.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/splash/view/splash_screen.dart';
import 'app_routes.dart';

/// Screens that only make sense when you are NOT logged in.
const _authPages = {
  AppRoutes.login,
  AppRoutes.signUp,
  AppRoutes.forgotPassword,
};

/// Screens that need a logged-in user. Grows as we add cart, orders...
const _needsLogin = {
  AppRoutes.home,
};

final routerProvider = Provider<GoRouter>((ref) {
  // The router re-checks its redirect whenever the session changes.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (previous, next) => refresh.value++);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final location = state.matchedLocation;

      // Firebase is still restoring the session: wait on the splash.
      if (auth.isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final loggedIn = auth.value != null;
      final onSplash = location == AppRoutes.splash;

      if (loggedIn) {
        // No reason to see log in / sign up while logged in.
        return onSplash || _authPages.contains(location)
            ? AppRoutes.home
            : null;
      }

      // Guest.
      return onSplash || _needsLogin.contains(location)
          ? AppRoutes.login
          : null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LogInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});