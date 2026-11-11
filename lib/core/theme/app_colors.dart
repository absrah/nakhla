import 'package:flutter/material.dart';

/// The raw Midnight Palm colors. Screens should not use these directly;
/// they read colors from the theme (see AppPalette) so dark mode works.
abstract final class AppColors {
  // Brand
  static const forest = Color(0xFF0B2B26);
  static const lime = Color(0xFFC6F24E);
  static const flame = Color(0xFFFF5A36);
  static const fog = Color(0xFFF2F5F1);
  static const ink = Color(0xFF0F1A17);

  // Derived
  static const flameDeep = Color(0xFFC23B1A); // links and errors on light
  static const muted = Color(0xFF5B6B66);
  static const border = Color(0xFFD3DCD2);
  static const limePressed = Color(0xFFB2DA38);

  // Dark mode surfaces
  static const forestDeep = Color(0xFF081F1B); // page background
  static const forestRaised = Color(0xFF17403A); // tiles, raised areas
  static const inactive = Color(0xFF8FA29B); // muted text on dark
  static const darkBorder = Color(0xFF24504A);
  static const flameSoft = Color(0xFFFF8566); // errors and links on dark
}
