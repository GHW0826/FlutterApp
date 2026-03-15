class WeekendProfileDayFormData {
  const WeekendProfileDayFormData({
    this.id,
    this.weekendProfileId = '',
    this.weekendProfileCode = '',
    this.isoWeekday = 1,
    this.weekend = true,
  });

  final String? id;
  final String weekendProfileId;
  final String weekendProfileCode;
  final int isoWeekday;
  final bool weekend;

  String get effectiveId {
    final direct = (id ?? '').trim();
    if (direct.isNotEmpty) return direct;
    final profileId = weekendProfileId.trim();
    if (profileId.isEmpty) return '';
    return '$profileId|$isoWeekday';
  }

  WeekendProfileDayFormData copyWith({
    String? id,
    String? weekendProfileId,
    String? weekendProfileCode,
    int? isoWeekday,
    bool? weekend,
  }) {
    return WeekendProfileDayFormData(
      id: id ?? this.id,
      weekendProfileId: weekendProfileId ?? this.weekendProfileId,
      weekendProfileCode: weekendProfileCode ?? this.weekendProfileCode,
      isoWeekday: isoWeekday ?? this.isoWeekday,
      weekend: weekend ?? this.weekend,
    );
  }
}
