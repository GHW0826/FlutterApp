import '../models/calendar_exception_form_data.dart';
import '../models/calendar_form_data.dart';
import '../models/calendar_set_form_data.dart';
import '../models/calendar_set_member_form_data.dart';
import '../models/calendar_weekend_form_data.dart';
import '../models/weekend_profile_day_form_data.dart';
import '../models/weekend_profile_form_data.dart';

abstract class CalendarApi {
  Future<List<CalendarFormData>> getCalendarList({bool? active});
  Future<CalendarFormData?> getCalendarById(String id);
  Future<CalendarFormData> createCalendar(CalendarFormData data);
  Future<CalendarFormData> patchCalendar(CalendarFormData data);
  Future<CalendarFormData> putCalendar(CalendarFormData data);
  Future<CalendarFormData> updateCalendar(CalendarFormData data) =>
      patchCalendar(data);
  Future<void> deleteCalendar(String id);

  Future<List<CalendarWeekendFormData>> getCalendarWeekendList({
    required String calendarId,
  });
  Future<CalendarWeekendFormData?> getCalendarWeekendById(String id);
  Future<CalendarWeekendFormData> createCalendarWeekend(
    CalendarWeekendFormData data,
  );
  Future<CalendarWeekendFormData> patchCalendarWeekend(
    CalendarWeekendFormData data,
  );
  Future<CalendarWeekendFormData> putCalendarWeekend(
    CalendarWeekendFormData data,
  );
  Future<CalendarWeekendFormData> updateCalendarWeekend(
    CalendarWeekendFormData data,
  ) => patchCalendarWeekend(data);
  Future<void> deleteCalendarWeekend(String id);

  Future<List<CalendarExceptionFormData>> getCalendarExceptionList({
    required String calendarId,
  });
  Future<CalendarExceptionFormData?> getCalendarExceptionById(String id);
  Future<CalendarExceptionFormData> createCalendarException(
    CalendarExceptionFormData data,
  );
  Future<CalendarExceptionFormData> patchCalendarException(
    CalendarExceptionFormData data,
  );
  Future<CalendarExceptionFormData> putCalendarException(
    CalendarExceptionFormData data,
  );
  Future<CalendarExceptionFormData> updateCalendarException(
    CalendarExceptionFormData data,
  ) => patchCalendarException(data);
  Future<void> deleteCalendarException(String id);

  Future<List<CalendarSetFormData>> getCalendarSetList();
  Future<CalendarSetFormData?> getCalendarSetById(String id);
  Future<CalendarSetFormData> createCalendarSet(CalendarSetFormData data);
  Future<CalendarSetFormData> patchCalendarSet(CalendarSetFormData data);
  Future<CalendarSetFormData> putCalendarSet(CalendarSetFormData data);
  Future<CalendarSetFormData> updateCalendarSet(CalendarSetFormData data) =>
      patchCalendarSet(data);
  Future<void> deleteCalendarSet(String id);

  Future<List<CalendarSetMemberFormData>> getCalendarSetMemberList({
    required String calendarSetId,
  });
  Future<CalendarSetMemberFormData?> getCalendarSetMemberById(String id);
  Future<CalendarSetMemberFormData> createCalendarSetMember(
    CalendarSetMemberFormData data,
  );
  Future<CalendarSetMemberFormData> patchCalendarSetMember(
    CalendarSetMemberFormData data,
  );
  Future<CalendarSetMemberFormData> putCalendarSetMember(
    CalendarSetMemberFormData data,
  );
  Future<CalendarSetMemberFormData> updateCalendarSetMember(
    CalendarSetMemberFormData data,
  ) => patchCalendarSetMember(data);
  Future<void> deleteCalendarSetMember(String id);

  Future<List<WeekendProfileFormData>> getWeekendProfileList();
  Future<WeekendProfileFormData?> getWeekendProfileById(String id);
  Future<WeekendProfileFormData> createWeekendProfile(
    WeekendProfileFormData data,
  );
  Future<WeekendProfileFormData> patchWeekendProfile(
    WeekendProfileFormData data,
  );
  Future<WeekendProfileFormData> putWeekendProfile(WeekendProfileFormData data);
  Future<WeekendProfileFormData> updateWeekendProfile(
    WeekendProfileFormData data,
  ) => patchWeekendProfile(data);
  Future<void> deleteWeekendProfile(String id);

  Future<List<WeekendProfileDayFormData>> getWeekendProfileDayList({
    required String weekendProfileId,
  });
  Future<WeekendProfileDayFormData?> getWeekendProfileDayById(String id);
  Future<WeekendProfileDayFormData> createWeekendProfileDay(
    WeekendProfileDayFormData data,
  );
  Future<WeekendProfileDayFormData> patchWeekendProfileDay(
    WeekendProfileDayFormData data,
  );
  Future<WeekendProfileDayFormData> putWeekendProfileDay(
    WeekendProfileDayFormData data,
  );
  Future<WeekendProfileDayFormData> updateWeekendProfileDay(
    WeekendProfileDayFormData data,
  ) => patchWeekendProfileDay(data);
  Future<void> deleteWeekendProfileDay(String id);
}
