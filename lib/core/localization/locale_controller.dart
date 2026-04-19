import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  LocaleController._();

  static const String _prefsKey = 'app_locale';

  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  /// Call once at startup (after [WidgetsFlutterBinding.ensureInitialized]).
  static Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null && (code == 'ar' || code == 'en')) {
        locale.value = Locale(code);
      }
    } on MissingPluginException {
      // Plugin not ready yet (usually after hot restart).
    }
  }

  static Future<void> _persist(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, languageCode);
    } on MissingPluginException {
      // Ignore — locale still updates in-memory for this session.
    }
  }

  static void setEnglish() {
    locale.value = const Locale('en');
    _persist('en');
  }

  static void setArabic() {
    locale.value = const Locale('ar');
    _persist('ar');
  }
}
