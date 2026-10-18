import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/view/account_screen.dart';
import '../../features/auth/view/forgot_password_screen.dart';
import '../../features/auth/view/log_in_screen.dart';
import '../../features/auth/view/sign_up_screen.dart';
import '../../features/auth/view_model/session_provider.dart';
import '../../features/cart/view/cart_screen.dart';
import '../../features/catalog/view/categories_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/onboarding/view/onboarding_screen.dart';
import '../../features/onboarding/view_model/onboarding_view_model.dart';
import '../../features/splash/view/splash_screen.dart';
import '../../features/wishlist/view/wishlist_screen.dart';
import '../widgets/main_shell.dart';
import 'app_routes.dart';

/// Screens that only make sense when you are NOT logged in.
const _authPages = {
  AppRoutes.login,
  AppRoutes.signUp,
  AppRoutes.forgotPassword,
};

/// Screens that need a logged-in user. Guests are sent to log in first and
/// come back afterwards. Grows as we add orders, checkout...
const _needsLogin = {
  AppRoutes.cart,
  AppRoutes.wishlist,
  AppRoutes.account,
};

/// Where to go after logging in: the screen the guest was trying to open.
String? _returnTo(GoRouterState state) {
  final from = state.uri.queryParameters['from'];
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  if (from == AppRoutes.splash || _authPages.contains(from)) return null;
  return from;
}

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

      if (loggedIn) {
        // No reason to see log in / sign up while logged in.
        if (_authPages.contains(location)) {
          return _returnTo(state) ?? AppRoutes.home;
        }
        return location == AppRoutes.splash ? AppRoutes.home : null;
      }

      // Guest.
      if (location == AppRoutes.splash) {
        final seen = ref.read(onboardingSeenProvider);
        return seen ? AppRoutes.home : AppRoutes.onboarding;
      }
      if (_needsLogin.contains(location)) {
        return '${AppRoutes.login}?from=${Uri.encodeComponent(location)}';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
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

      // The five tabs. Each tab keeps its own screen and scroll position
      // while you look at another tab.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.categories,
              builder: (context, state) => const CategoriesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.cart,
              builder: (context, state) => const CartScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.wishlist,
              builder: (context, state) => const WishlistScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.account,
              builder: (context, state) => const AccountScreen(),
            ),
          ]),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});