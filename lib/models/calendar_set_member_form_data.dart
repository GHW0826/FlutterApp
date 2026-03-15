class CalendarSetMemberFormData {
  const CalendarSetMemberFormData({
    this.id,
    this.calendarSetId = '',
    this.calendarSetCode = '',
    this.calendarId = '',
    this.calendarCode = '',
    this.calendarName = '',
    this.seqNo = 1,
  });

  final String? id;
  final String calendarSetId;
  final String calendarSetCode;
  final String calendarId;
  final String calendarCode;
  final String calendarName;
  final int seqNo;

  String get effectiveId {
    final direct = (id ?? '').trim();
    if (direct.isNotEmpty) return direct;
    final setId = calendarSetId.trim();
    final itemId = calendarId.trim();
    if (setId.isNotEmpty && itemId.isNotEmpty) {
      return '$setId|$itemId';
    }
    return '';
  }

  CalendarSetMemberFormData copyWith({
    String? id,
    String? calendarSetId,
    String? calendarSetCode,
    String? calendarId,
    String? calendarCode,
    String? calendarName,
    int? seqNo,
  }) {
    return CalendarSetMemberFormData(
      id: id ?? this.id,
      calendarSetId: calendarSetId ?? this.calendarSetId,
      calendarSetCode: calendarSetCode ?? this.calendarSetCode,
      calendarId: calendarId ?? this.calendarId,
      calendarCode: calendarCode ?? this.calendarCode,
      calendarName: calendarName ?? this.calendarName,
      seqNo: seqNo ?? this.seqNo,
    );
  }
}
