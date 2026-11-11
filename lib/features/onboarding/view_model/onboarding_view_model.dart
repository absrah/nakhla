import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/onboarding_repository.dart';

/// State = has the intro been seen on this device?
class OnboardingViewModel extends Notifier<bool> {
  @override
  bool build() => ref.read(onboardingRepositoryProvider).isSeen;

  Future<void> complete() async {
    await ref.read(onboardingRepositoryProvider).markSeen();
    state = true;
  }

  /// For testing only.
  Future<void> reset() async {
    await ref.read(onboardingRepositoryProvider).clear();
    state = false;
  }
}

final onboardingSeenProvider = NotifierProvider<OnboardingViewModel, bool>(
  OnboardingViewModel.new,
);
