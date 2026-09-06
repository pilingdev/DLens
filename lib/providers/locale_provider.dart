import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  static const String _boxName = 'settingsBox';
  static const String _localeKey = 'locale';

  Future<void> _loadLocale() async {
    final box = await Hive.openBox(_boxName);
    final savedLocale = box.get(_localeKey) as String?;
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    state = locale;
    final box = await Hive.openBox(_boxName);
    await box.put(_localeKey, locale.languageCode);
  }

  Future<void> toggleLocale() async {
    if (state.languageCode == 'en') {
      await setLocale(const Locale('tl'));
    } else {
      await setLocale(const Locale('en'));
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
