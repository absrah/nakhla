import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_palette.dart';

/// The two themes of the app. Both use the Midnight Palm colors.
abstract final class AppTheme {
  static ThemeData get light => _build(
    scheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.forest,
      onPrimary: AppColors.fog,
      secondary: AppColors.lime,
      onSecondary: AppColors.forest,
      tertiary: AppColors.flame,
      onTertiary: AppColors.ink,
      error: AppColors.flameDeep,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.ink,
      outline: AppColors.border,
    ),
    palette: AppPalette.light,
    background: AppColors.fog,
    strong: AppColors.forest, // headings, selected labels
    field: Colors.white, // text field fill
    bar: Colors.white, // bottom bar
  );

  static ThemeData get dark => _build(
    scheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.lime,
      onPrimary: AppColors.forest,
      secondary: AppColors.lime,
      onSecondary: AppColors.forest,
      tertiary: AppColors.flame,
      onTertiary: AppColors.ink,
      error: AppColors.flameSoft,
      onError: AppColors.ink,
      surface: AppColors.forest,
      onSurface: AppColors.fog,
      outline: AppColors.darkBorder,
    ),
    palette: AppPalette.dark,
    background: AppColors.forestDeep,
    strong: AppColors.fog,
    field: AppColors.forest,
    bar: AppColors.forest,
  );

  static ThemeData _build({
    required ColorScheme scheme,
    required AppPalette palette,
    required Color background,
    required Color strong,
    required Color field,
    required Color bar,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
    );

    final text = GoogleFonts.rubikTextTheme(
      base.textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    final buttonText = text.labelLarge?.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w700,
    );

    return base.copyWith(
      textTheme: text,
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: strong,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: strong,
        ),
      ),
      // Main action: lime with dark text, in both modes.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: AppColors.forest,
          disabledBackgroundColor: palette.border,
          disabledForegroundColor: palette.muted,
          minimumSize: const Size.fromHeight(56),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      // Second action: outlined.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: strong,
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: strong, width: 1.5),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.link,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: border(palette.border),
        enabledBorder: border(palette.border),
        focusedBorder: border(strong, 2),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 2),
        errorStyle: TextStyle(color: scheme.error),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bar,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.lime,
        height: 72,
        // The selected icon sits on the lime pill, so it is always dark.
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.forest
                : palette.muted,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? strong : palette.muted,
          );
        }),
      ),
      dividerTheme: DividerThemeData(color: palette.border, space: 1),
    );
  }
}
