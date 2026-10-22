import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kFestiveThemePrefKey = 'app_festive_theme';

enum FestiveTheme {
  none,
  diwali,
}

class FestiveThemeNotifier extends StateNotifier<FestiveTheme> {
  FestiveThemeNotifier() : super(FestiveTheme.diwali) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString(_kFestiveThemePrefKey);
      if (val == 'none') {
        state = FestiveTheme.none;
      } else if (val == 'diwali') {
        state = FestiveTheme.diwali;
      } else {
        // Default to Diwali festive theme
        state = FestiveTheme.diwali;
      }
    } catch (_) {}
  }

  Future<void> toggleDiwali() async {
    final next = state == FestiveTheme.diwali ? FestiveTheme.none : FestiveTheme.diwali;
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kFestiveThemePrefKey,
        next == FestiveTheme.diwali ? 'diwali' : 'none',
      );
    } catch (_) {}
  }

  Future<void> setFestiveTheme(FestiveTheme theme) async {
    state = theme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kFestiveThemePrefKey,
        theme == FestiveTheme.diwali ? 'diwali' : 'none',
      );
    } catch (_) {}
  }

  bool get isDiwali => state == FestiveTheme.diwali;
}

final festiveThemeProvider =
    StateNotifierProvider<FestiveThemeNotifier, FestiveTheme>((ref) {
  return FestiveThemeNotifier();
});
