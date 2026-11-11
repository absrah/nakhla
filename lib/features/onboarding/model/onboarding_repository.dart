import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/preferences_provider.dart';

/// Remembers on this device whether the intro was already shown.
class OnboardingRepository {
  OnboardingRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'onboarding_seen';

  bool get isSeen => _prefs.getBool(_key) ?? false;

  Future<void> markSeen() => _prefs.setBool(_key, true);

  /// For testing only: show the intro again.
  Future<void> clear() => _prefs.remove(_key);
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(ref.watch(sharedPreferencesProvider));
});
