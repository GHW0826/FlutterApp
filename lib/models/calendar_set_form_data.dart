import 'calendar_enums.dart';

class CalendarSetFormData {
  const CalendarSetFormData({
    this.id,
    this.setCode = '',
    this.joinRule = CalendarJoinRule.joinHolidays,
    this.description = '',
  });

  final String? id;
  final String setCode;
  final CalendarJoinRule joinRule;
  final String description;

  CalendarSetFormData copyWith({
    String? id,
    String? setCode,
    CalendarJoinRule? joinRule,
    String? description,
  }) {
    return CalendarSetFormData(
      id: id ?? this.id,
      setCode: setCode ?? this.setCode,
      joinRule: joinRule ?? this.joinRule,
      description: description ?? this.description,
    );
  }
}
