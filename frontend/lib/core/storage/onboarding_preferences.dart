import 'package:shared_preferences/shared_preferences.dart';

/// Manages first-launch onboarding persistence across Web, Android, and iOS.
class OnboardingPreferences {
  static const String _onboardingKey = 'has_completed_onboarding_v2';

  final SharedPreferences? _prefs;

  OnboardingPreferences([this._prefs]);

  /// Checks if the user has already completed onboarding.
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (_) {
      // Fallback gracefully if platform storage fails
      return false;
    }
  }

  /// Sets the onboarding completion flag.
  Future<void> setOnboardingCompleted({bool completed = true}) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, completed);
    } catch (_) {
      // Silently ignore storage error
    }
  }

  /// Resets the flag (useful for testing or debugging).
  Future<void> reset() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove(_onboardingKey);
    } catch (_) {}
  }
}
