import 'package:flutter/material.dart';

/// TEMPORARY: lets us flip light/dark while testing the theme.
/// Replaced by a real setting (saved with shared_preferences) in Phase 4.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.system);