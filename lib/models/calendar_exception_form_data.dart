import 'calendar_enums.dart';

class CalendarExceptionFormData {
  const CalendarExceptionFormData({
    this.id,
    this.calendarCode = '',
    this.exceptionDate,
    this.businessDay = false,
    this.exceptionType = CalendarExceptionType.holiday,
    this.name = '',
    this.observedOf,
    this.source = '',
    this.createdAt,
  });

  final String? id;
  final String calendarCode;
  final DateTime? exceptionDate;
  final bool businessDay;
  final CalendarExceptionType exceptionType;
  final String name;
  final DateTime? observedOf;
  final String source;
  final DateTime? createdAt;

  CalendarExceptionFormData copyWith({
    String? id,
    String? calendarCode,
    DateTime? exceptionDate,
    bool? businessDay,
    CalendarExceptionType? exceptionType,
    String? name,
    DateTime? observedOf,
    String? source,
    DateTime? createdAt,
  }) {
    return CalendarExceptionFormData(
      id: id ?? this.id,
      calendarCode: calendarCode ?? this.calendarCode,
      exceptionDate: exceptionDate ?? this.exceptionDate,
      businessDay: businessDay ?? this.businessDay,
      exceptionType: exceptionType ?? this.exceptionType,
      name: name ?? this.name,
      observedOf: observedOf ?? this.observedOf,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
