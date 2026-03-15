import 'package:flutter/material.dart';

enum AppLanguage { en, ko }

extension AppLanguageLocale on AppLanguage {
  Locale get locale => Locale(name);
}

extension AppTextContext on BuildContext {
  bool get isKorean => Localizations.localeOf(this).languageCode == 'ko';

  String tr({required String en, required String ko}) {
    return isKorean ? ko : en;
  }
}
