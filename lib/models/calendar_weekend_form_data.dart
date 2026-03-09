class CalendarWeekendFormData {
  const CalendarWeekendFormData({
    this.id,
    this.calendarCode = '',
    this.validFrom,
    this.validTo,
    this.weekendProfileCode = 'SAT_SUN',
  });

  final String? id;
  final String calendarCode;
  final DateTime? validFrom;
  final DateTime? validTo;
  final String weekendProfileCode;

  CalendarWeekendFormData copyWith({
    String? id,
    String? calendarCode,
    DateTime? validFrom,
    DateTime? validTo,
    String? weekendProfileCode,
  }) {
    return CalendarWeekendFormData(
      id: id ?? this.id,
      calendarCode: calendarCode ?? this.calendarCode,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      weekendProfileCode: weekendProfileCode ?? this.weekendProfileCode,
    );
  }
}
