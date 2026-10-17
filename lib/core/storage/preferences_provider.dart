import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The device's small key-value storage. It is opened once in main() and
/// handed to the app there, so reading it later needs no waiting.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Set in main() with ProviderScope overrides.');
});