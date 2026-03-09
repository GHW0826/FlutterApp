import 'calendar_enums.dart';

class CalendarFormData {
  const CalendarFormData({
    this.id,
    this.calendarCode = '',
    this.name = '',
    this.type = CalendarType.countryPublic,
    this.countryId = '',
    this.countryIso2 = '',
    this.countryIso3 = '',
    this.countryName = '',
    this.regionCode = '',
    this.timezone = 'Asia/Seoul',
    this.active = true,
  });

  final String? id;
  final String calendarCode;
  final String name;
  final CalendarType type;
  final String countryId;
  final String countryIso2;
  final String countryIso3;
  final String countryName;
  final String regionCode;
  final String timezone;
  final bool active;

  String get countryDisplayCode =>
      countryIso3.isNotEmpty ? countryIso3 : countryIso2;

  CalendarFormData copyWith({
    String? id,
    String? calendarCode,
    String? name,
    CalendarType? type,
    String? countryId,
    String? countryIso2,
    String? countryIso3,
    String? countryName,
    String? regionCode,
    String? timezone,
    bool? active,
  }) {
    return CalendarFormData(
      id: id ?? this.id,
      calendarCode: calendarCode ?? this.calendarCode,
      name: name ?? this.name,
      type: type ?? this.type,
      countryId: countryId ?? this.countryId,
      countryIso2: countryIso2 ?? this.countryIso2,
      countryIso3: countryIso3 ?? this.countryIso3,
      countryName: countryName ?? this.countryName,
      regionCode: regionCode ?? this.regionCode,
      timezone: timezone ?? this.timezone,
      active: active ?? this.active,
    );
  }
}
