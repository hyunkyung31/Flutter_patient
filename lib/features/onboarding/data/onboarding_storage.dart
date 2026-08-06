import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  static const String _completedKey = 'bomi_onboarding_completed';

  static Future<bool> isCompleted() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences.getBool(_completedKey) ?? false;
  }

  static Future<void> setCompleted() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_completedKey, true);
  }

  static Future<void> reset() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.remove(_completedKey);
  }
}
