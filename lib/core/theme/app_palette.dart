import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Extra colors that Flutter's ColorScheme has no slot for.
/// Read them anywhere with `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.muted,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.sale,
    required this.onSale,
    required this.link,
    required this.tiles,
  });

  final Color muted; // secondary text
  final Color border; // outlines and dividers
  final Color accent; // lime
  final Color onAccent; // text on lime
  final Color sale; // flame
  final Color onSale; // text on flame
  final Color link; // links and small error text
  final List<Color> tiles; // placeholder tints for product images

  static const light = AppPalette(
    muted: AppColors.muted,
    border: AppColors.border,
    accent: AppColors.lime,
    onAccent: AppColors.forest,
    sale: AppColors.flame,
    onSale: AppColors.ink,
    link: AppColors.flameDeep,
    tiles: [
      Color(0xFFD4E7E4),
      Color(0xFFEEF8C4),
      Color(0xFFFFE3DB),
      Color(0xFFDCE8DF),
    ],
  );

  static const dark = AppPalette(
    muted: AppColors.inactive,
    border: AppColors.darkBorder,
    accent: AppColors.lime,
    onAccent: AppColors.forest,
    sale: AppColors.flame,
    onSale: AppColors.ink,
    link: AppColors.flameSoft,
    tiles: [
      Color(0xFF17403A),
      Color(0xFF22463A),
      Color(0xFF2E3F26),
      Color(0xFF3A2A24),
    ],
  );

  /// Same product always gets the same tint.
  Color tileFor(String key) {
    final sum = key.codeUnits.fold<int>(0, (a, b) => a + b);
    return tiles[sum % tiles.length];
  }

  @override
  AppPalette copyWith({
    Color? muted,
    Color? border,
    Color? accent,
    Color? onAccent,
    Color? sale,
    Color? onSale,
    Color? link,
    List<Color>? tiles,
  }) {
    return AppPalette(
      muted: muted ?? this.muted,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      sale: sale ?? this.sale,
      onSale: onSale ?? this.onSale,
      link: link ?? this.link,
      tiles: tiles ?? this.tiles,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      sale: Color.lerp(sale, other.sale, t)!,
      onSale: Color.lerp(onSale, other.onSale, t)!,
      link: Color.lerp(link, other.link, t)!,
      tiles: [
        for (var i = 0; i < tiles.length; i++)
          Color.lerp(tiles[i], other.tiles[i], t)!,
      ],
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}