enum CalendarType {
  countryPublic('COUNTRY_PUBLIC', 'CountryPublic'),
  bank('BANK', 'Bank'),
  exchange('EXCHANGE', 'Exchange'),
  region('REGION', 'Region'),
  custom('CUSTOM', 'Custom');

  const CalendarType(this.apiValue, this.uiLabel);
  final String apiValue;
  final String uiLabel;

  static CalendarType? fromApiValue(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    if (normalized.isEmpty) return null;
    for (final item in CalendarType.values) {
      if (item.apiValue == normalized ||
          item.name.toUpperCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}

enum CalendarExceptionType {
  holiday('HOLIDAY', 'Holiday'),
  specialClosure('SPECIAL_CLOSURE', 'SpecialClosure'),
  workingDay('WORKING_DAY', 'WorkingDay'),
  other('OTHER', 'Other');

  const CalendarExceptionType(this.apiValue, this.uiLabel);
  final String apiValue;
  final String uiLabel;

  static CalendarExceptionType? fromApiValue(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    if (normalized.isEmpty) return null;
    for (final item in CalendarExceptionType.values) {
      if (item.apiValue == normalized ||
          item.name.toUpperCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}

enum CalendarJoinRule {
  joinHolidays('JOIN_HOLIDAYS', 'JoinHolidays'),
  joinBusinessDays('JOIN_BUSINESS_DAYS', 'JoinBusinessDays');

  const CalendarJoinRule(this.apiValue, this.uiLabel);
  final String apiValue;
  final String uiLabel;

  static CalendarJoinRule? fromApiValue(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    if (normalized.isEmpty) return null;
    for (final item in CalendarJoinRule.values) {
      if (item.apiValue == normalized ||
          item.name.toUpperCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}
