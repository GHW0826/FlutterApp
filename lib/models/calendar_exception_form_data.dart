import 'calendar_enums.dart';

class CalendarExceptionFormData {
  const CalendarExceptionFormData({
    this.id,
    this.calendarId = '',
    this.calendarCode = '',
    this.calendarName = '',
    this.exceptionDate,
    this.businessDay = false,
    this.exceptionType = CalendarExceptionType.holiday,
    this.name = '',
    this.observedOf,
    this.source = '',
    this.createdAt,
  });

  final String? id;
  final String calendarId;
  final String calendarCode;
  final String calendarName;
  final DateTime? exceptionDate;
  final bool businessDay;
  final CalendarExceptionType exceptionType;
  final String name;
  final DateTime? observedOf;
  final String source;
  final DateTime? createdAt;

  CalendarExceptionFormData copyWith({
    String? id,
    String? calendarId,
    String? calendarCode,
    String? calendarName,
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
      calendarId: calendarId ?? this.calendarId,
      calendarCode: calendarCode ?? this.calendarCode,
      calendarName: calendarName ?? this.calendarName,
      exceptionDate: exceptionDate ?? this.exceptionDate,
      businessDay: businessDay ?? this.businessDay,
      exceptionType: exceptionType ?? this.exceptionType,
      name: name ?? this.name,
      observedOf: observedOf ?? this.observedOf,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get effectiveId {
    final normalizedId = (id ?? '').trim();
    if (normalizedId.isNotEmpty) {
      return normalizedId;
    }
    final key = calendarId.trim().isNotEmpty
        ? calendarId.trim()
        : calendarCode.trim();
    final date = exceptionDate;
    if (key.isEmpty || date == null) {
      return '';
    }
    return '$key|${_formatDate(date)}';
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
