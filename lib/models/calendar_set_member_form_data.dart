class CalendarSetMemberFormData {
  const CalendarSetMemberFormData({
    this.id,
    this.calendarSetCode = '',
    this.calendarCode = '',
    this.seqNo = 1,
  });

  final String? id;
  final String calendarSetCode;
  final String calendarCode;
  final int seqNo;

  CalendarSetMemberFormData copyWith({
    String? id,
    String? calendarSetCode,
    String? calendarCode,
    int? seqNo,
  }) {
    return CalendarSetMemberFormData(
      id: id ?? this.id,
      calendarSetCode: calendarSetCode ?? this.calendarSetCode,
      calendarCode: calendarCode ?? this.calendarCode,
      seqNo: seqNo ?? this.seqNo,
    );
  }
}
