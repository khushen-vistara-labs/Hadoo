import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingCompletedNotifier extends Notifier<bool> {
  /// Persisted flag; kept so existing users never see onboarding again.
  static const prefKey = 'onboarding_completed';
  bool _initialized = false;
  int _revision = 0;

  @override
  bool build() {
    if (!_initialized) {
      _initialized = true;
      final revision = _revision;
      Future<void>.microtask(() => _loadPreference(revision));
    }
    return false;
  }

  Future<void> _loadPreference(int revision) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(prefKey) ?? false;
    if (!ref.mounted || revision != _revision) return;
    state = value;
  }

  Future<void> complete() async {
    if (state) return;
    _revision++;
    state = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, true);
  }

  Future<void> reset() async {
    _revision++;
    state = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, false);
  }
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool>(
      OnboardingCompletedNotifier.new,
    );
