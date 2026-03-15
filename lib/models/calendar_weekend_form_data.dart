class CalendarWeekendFormData {
  const CalendarWeekendFormData({
    this.id,
    this.calendarId = '',
    this.calendarCode = '',
    this.calendarName = '',
    this.validFrom,
    this.validTo,
    this.weekendProfileId = '',
    this.weekendProfileCode = 'SAT_SUN',
    this.weekendProfileName = '',
  });

  final String? id;
  final String calendarId;
  final String calendarCode;
  final String calendarName;
  final DateTime? validFrom;
  final DateTime? validTo;
  final String weekendProfileId;
  final String weekendProfileCode;
  final String weekendProfileName;

  String get effectiveId {
    final direct = (id ?? '').trim();
    if (direct.isNotEmpty) return direct;
    final parentId = calendarId.trim();
    final from = validFrom;
    if (parentId.isEmpty || from == null) return '';
    final y = from.year.toString().padLeft(4, '0');
    final m = from.month.toString().padLeft(2, '0');
    final d = from.day.toString().padLeft(2, '0');
    return '$parentId|$y-$m-$d';
  }

  CalendarWeekendFormData copyWith({
    String? id,
    String? calendarId,
    String? calendarCode,
    String? calendarName,
    DateTime? validFrom,
    DateTime? validTo,
    String? weekendProfileId,
    String? weekendProfileCode,
    String? weekendProfileName,
  }) {
    return CalendarWeekendFormData(
      id: id ?? this.id,
      calendarId: calendarId ?? this.calendarId,
      calendarCode: calendarCode ?? this.calendarCode,
      calendarName: calendarName ?? this.calendarName,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      weekendProfileId: weekendProfileId ?? this.weekendProfileId,
      weekendProfileCode: weekendProfileCode ?? this.weekendProfileCode,
      weekendProfileName: weekendProfileName ?? this.weekendProfileName,
    );
  }
}
