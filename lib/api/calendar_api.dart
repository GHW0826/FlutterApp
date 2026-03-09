import '../models/calendar_exception_form_data.dart';
import '../models/calendar_form_data.dart';
import '../models/calendar_set_form_data.dart';
import '../models/calendar_set_member_form_data.dart';
import '../models/calendar_weekend_form_data.dart';

abstract class CalendarApi {
  Future<List<CalendarFormData>> getCalendarList({bool? active});
  Future<CalendarFormData?> getCalendarById(String id);
  Future<CalendarFormData> createCalendar(CalendarFormData data);
  Future<CalendarFormData> patchCalendar(CalendarFormData data);
  Future<CalendarFormData> putCalendar(CalendarFormData data);
  Future<CalendarFormData> updateCalendar(CalendarFormData data) =>
      patchCalendar(data);
  Future<void> deleteCalendar(String id);

  Future<List<CalendarWeekendFormData>> getCalendarWeekendList();
  Future<CalendarWeekendFormData?> getCalendarWeekendById(String id);
  Future<CalendarWeekendFormData> createCalendarWeekend(
    CalendarWeekendFormData data,
  );
  Future<CalendarWeekendFormData> updateCalendarWeekend(
    CalendarWeekendFormData data,
  );
  Future<void> deleteCalendarWeekend(String id);

  Future<List<CalendarExceptionFormData>> getCalendarExceptionList();
  Future<CalendarExceptionFormData?> getCalendarExceptionById(String id);
  Future<CalendarExceptionFormData> createCalendarException(
    CalendarExceptionFormData data,
  );
  Future<CalendarExceptionFormData> updateCalendarException(
    CalendarExceptionFormData data,
  );
  Future<void> deleteCalendarException(String id);

  Future<List<CalendarSetFormData>> getCalendarSetList();
  Future<CalendarSetFormData?> getCalendarSetById(String id);
  Future<CalendarSetFormData> createCalendarSet(CalendarSetFormData data);
  Future<CalendarSetFormData> updateCalendarSet(CalendarSetFormData data);
  Future<void> deleteCalendarSet(String id);

  Future<List<CalendarSetMemberFormData>> getCalendarSetMemberList();
  Future<CalendarSetMemberFormData?> getCalendarSetMemberById(String id);
  Future<CalendarSetMemberFormData> createCalendarSetMember(
    CalendarSetMemberFormData data,
  );
  Future<CalendarSetMemberFormData> updateCalendarSetMember(
    CalendarSetMemberFormData data,
  );
  Future<void> deleteCalendarSetMember(String id);
}
