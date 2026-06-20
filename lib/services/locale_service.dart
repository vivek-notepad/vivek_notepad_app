import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  static const _prefKey = 'app_locale';

  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null && code.isNotEmpty) {
      _locale = _decodeLocale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _encodeLocale(locale));
  }

  Future<void> clearLocale() async {
    _locale = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  static String _encodeLocale(Locale locale) {
    final country = locale.countryCode;
    if (country != null && country.isNotEmpty) {
      return '${locale.languageCode}_$country';
    }
    return locale.languageCode;
  }

  static Locale _decodeLocale(String stored) {
    final parts = stored.split('_');
    if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  static bool localesMatch(Locale? a, Locale? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.languageCode == b.languageCode && a.countryCode == b.countryCode;
  }
}
