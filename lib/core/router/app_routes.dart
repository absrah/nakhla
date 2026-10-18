/// All route paths in one place, so a typo cannot hide in a string.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signUp = '/signup';
  static const forgotPassword = '/forgot-password';

  // The five tabs of the bottom navigation bar.
  static const home = '/home';
  static const categories = '/categories';
  static const cart = '/cart';
  static const wishlist = '/wishlist';
  static const account = '/account';

  // Screens opened on top of the tabs (no bottom bar).
  static const search = '/search';
  static const deals = '/deals';
  static const product = '/product/:id';
  static const category = '/category/:id';

  static String productPath(String id) => '/product/$id';

  /// All products of a category, or only one type ("Phones") inside it.
  static String categoryPath(String id, {String? type}) =>
      type == null ? '/category/$id' : '/category/$id?type=$type';
}