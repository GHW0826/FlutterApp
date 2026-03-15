import 'package:flutter/material.dart';

import '../l10n/app_text.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController({
    ThemeMode initialThemeMode = ThemeMode.light,
    Locale? initialLocale,
  }) : _themeMode = initialThemeMode,
       _locale = _resolveLocale(initialLocale);

  ThemeMode _themeMode;
  Locale _locale;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isKorean => _locale.languageCode == AppLanguage.ko.name;

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = isKorean ? AppLanguage.en.locale : AppLanguage.ko.locale;
    notifyListeners();
  }

  static Locale _resolveLocale(Locale? locale) {
    if (locale?.languageCode == AppLanguage.ko.name) {
      return AppLanguage.ko.locale;
    }
    return AppLanguage.en.locale;
  }
}

class AppThemeScope extends InheritedNotifier<AppSettingsController> {
  const AppThemeScope({
    super.key,
    required this.controller,
    required super.child,
  }) : super(notifier: controller);

  final AppSettingsController controller;

  static AppSettingsController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope is missing in the widget tree.');
    return scope!.controller;
  }
}
