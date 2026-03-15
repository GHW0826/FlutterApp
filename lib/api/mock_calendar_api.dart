import '../models/calendar_enums.dart';
import '../models/calendar_exception_form_data.dart';
import '../models/calendar_form_data.dart';
import '../models/calendar_set_form_data.dart';
import '../models/calendar_set_member_form_data.dart';
import '../models/calendar_weekend_form_data.dart';
import '../models/weekend_profile_day_form_data.dart';
import '../models/weekend_profile_form_data.dart';
import 'calendar_api.dart';

class MockCalendarApi implements CalendarApi {
  MockCalendarApi() {
    _calendars.addAll(_seedCalendars);
    _sets.addAll(_seedSets);
    _weekendProfiles.addAll(_seedWeekendProfiles);
    _weekendProfileDays.addAll(_seedWeekendProfileDays);
    _weekends.addAll(_seedWeekends);
    _exceptions.addAll(_seedExceptions);
    _setMembers.addAll(_seedSetMembers);
  }

  final List<CalendarFormData> _calendars = [];
  final List<CalendarWeekendFormData> _weekends = [];
  final List<CalendarExceptionFormData> _exceptions = [];
  final List<CalendarSetFormData> _sets = [];
  final List<CalendarSetMemberFormData> _setMembers = [];
  final List<WeekendProfileFormData> _weekendProfiles = [];
  final List<WeekendProfileDayFormData> _weekendProfileDays = [];

  static List<CalendarFormData> get _seedCalendars => const [
    CalendarFormData(
      id: 'cal_1',
      calendarCode: 'KR_BANK',
      name: 'Korea Bank Calendar',
      type: CalendarType.bank,
      countryId: '1',
      countryIso2: 'KR',
      countryIso3: 'KOR',
      countryName: 'Korea',
      timezone: 'Asia/Seoul',
      active: true,
    ),
    CalendarFormData(
      id: 'cal_2',
      calendarCode: 'USNY',
      name: 'US New York Calendar',
      type: CalendarType.exchange,
      countryId: '2',
      countryIso2: 'US',
      countryIso3: 'USA',
      countryName: 'United States',
      timezone: 'America/New_York',
      active: true,
    ),
    CalendarFormData(
      id: 'cal_3',
      calendarCode: 'EUTA',
      name: 'TARGET2',
      type: CalendarType.region,
      timezone: 'Europe/Brussels',
      active: true,
    ),
  ];

  static List<CalendarSetFormData> get _seedSets => const [
    CalendarSetFormData(
      id: 'cset_1',
      setCode: 'KR_BANK+USNY',
      joinRule: CalendarJoinRule.joinHolidays,
      description: 'KR + US settlement',
    ),
  ];

  static List<WeekendProfileFormData> get _seedWeekendProfiles => const [
    WeekendProfileFormData(
      id: 'wkp_1',
      weekendProfileCode: 'SAT_SUN',
      name: 'Saturday/Sunday',
      description: 'Standard weekend profile',
    ),
    WeekendProfileFormData(
      id: 'wkp_2',
      weekendProfileCode: 'FRI_SAT',
      name: 'Friday/Saturday',
      description: 'Middle East weekend profile',
    ),
  ];

  static List<WeekendProfileDayFormData> get _seedWeekendProfileDays => const [
    WeekendProfileDayFormData(
      id: 'wkp_1|6',
      weekendProfileId: 'wkp_1',
      weekendProfileCode: 'SAT_SUN',
      isoWeekday: 6,
      weekend: true,
    ),
    WeekendProfileDayFormData(
      id: 'wkp_1|7',
      weekendProfileId: 'wkp_1',
      weekendProfileCode: 'SAT_SUN',
      isoWeekday: 7,
      weekend: true,
    ),
  ];

  static List<CalendarWeekendFormData> get _seedWeekends => [
    CalendarWeekendFormData(
      id: 'cal_1|2000-01-01',
      calendarId: 'cal_1',
      calendarCode: 'KR_BANK',
      calendarName: 'Korea Bank Calendar',
      validFrom: DateTime(2000, 1, 1),
      weekendProfileId: 'wkp_1',
      weekendProfileCode: 'SAT_SUN',
      weekendProfileName: 'Saturday/Sunday',
    ),
    CalendarWeekendFormData(
      id: 'cal_2|2000-01-01',
      calendarId: 'cal_2',
      calendarCode: 'USNY',
      calendarName: 'US New York Calendar',
      validFrom: DateTime(2000, 1, 1),
      weekendProfileId: 'wkp_1',
      weekendProfileCode: 'SAT_SUN',
      weekendProfileName: 'Saturday/Sunday',
    ),
  ];

  static List<CalendarExceptionFormData> get _seedExceptions => [
    CalendarExceptionFormData(
      id: 'cal_1|2026-01-01',
      calendarId: 'cal_1',
      calendarCode: 'KR_BANK',
      calendarName: 'Korea Bank Calendar',
      exceptionDate: DateTime(2026, 1, 1),
      businessDay: false,
      exceptionType: CalendarExceptionType.holiday,
      name: 'New Year',
      source: 'Seed',
      createdAt: DateTime(2026, 1, 1),
    ),
    CalendarExceptionFormData(
      id: 'cal_2|2026-07-04',
      calendarId: 'cal_2',
      calendarCode: 'USNY',
      calendarName: 'US New York Calendar',
      exceptionDate: DateTime(2026, 7, 4),
      businessDay: false,
      exceptionType: CalendarExceptionType.holiday,
      name: 'Independence Day',
      source: 'Seed',
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  static List<CalendarSetMemberFormData> get _seedSetMembers => const [
    CalendarSetMemberFormData(
      id: 'cset_1|cal_1',
      calendarSetId: 'cset_1',
      calendarSetCode: 'KR_BANK+USNY',
      calendarId: 'cal_1',
      calendarCode: 'KR_BANK',
      calendarName: 'Korea Bank Calendar',
      seqNo: 1,
    ),
    CalendarSetMemberFormData(
      id: 'cset_1|cal_2',
      calendarSetId: 'cset_1',
      calendarSetCode: 'KR_BANK+USNY',
      calendarId: 'cal_2',
      calendarCode: 'USNY',
      calendarName: 'US New York Calendar',
      seqNo: 2,
    ),
  ];

  @override
  Future<List<CalendarFormData>> getCalendarList({bool? active}) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    var items = List<CalendarFormData>.from(_calendars);
    if (active != null) {
      items = items.where((item) => item.active == active).toList();
    }
    return items;
  }

  void replaceCalendars(Iterable<CalendarFormData> items) {
    _calendars
      ..clear()
      ..addAll(items);
  }

  @override
  Future<CalendarFormData?> getCalendarById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _findById(_calendars, id);
  }

  @override
  Future<CalendarFormData> createCalendar(CalendarFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final code = data.calendarCode.trim();
    final name = data.name.trim();
    if (code.isEmpty || name.isEmpty) {
      throw StateError('calendarCode/name is required.');
    }
    final duplicate = _calendars.any((item) => item.calendarCode == code);
    if (duplicate) {
      throw StateError('Duplicate calendarCode: $code');
    }
    final created = data.copyWith(
      id: data.id ?? 'cal_${DateTime.now().millisecondsSinceEpoch}',
      calendarCode: code,
      name: name,
      countryId: data.countryId.trim(),
      countryIso2: data.countryIso2.trim().toUpperCase(),
      countryIso3: data.countryIso3.trim().toUpperCase(),
      countryName: data.countryName.trim(),
      regionCode: data.regionCode.trim(),
      timezone: data.timezone.trim(),
    );
    _calendars.insert(0, created);
    return created;
  }

  @override
  Future<CalendarFormData> patchCalendar(CalendarFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('Calendar id is required.');
    }
    final index = _calendars.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw StateError('Calendar not found: $id');
    }
    final code = data.calendarCode.trim();
    if (code.isEmpty) {
      throw StateError('calendarCode is required.');
    }
    final duplicate = _calendars.any(
      (item) => item.id != id && item.calendarCode == code,
    );
    if (duplicate) {
      throw StateError('Duplicate calendarCode: $code');
    }
    final before = _calendars[index];
    final updated = data.copyWith(
      id: id,
      calendarCode: code,
      name: data.name.trim(),
      countryId: data.countryId.trim(),
      countryIso2: data.countryIso2.trim().toUpperCase(),
      countryIso3: data.countryIso3.trim().toUpperCase(),
      countryName: data.countryName.trim(),
      regionCode: data.regionCode.trim(),
      timezone: data.timezone.trim(),
    );
    _calendars[index] = updated;
    if (before.calendarCode != updated.calendarCode || before.name != updated.name) {
      _syncCalendarChildren(updated);
    }
    return updated;
  }

  @override
  Future<CalendarFormData> putCalendar(CalendarFormData data) {
    return patchCalendar(data);
  }

  @override
  Future<CalendarFormData> updateCalendar(CalendarFormData data) {
    return patchCalendar(data);
  }

  @override
  Future<void> deleteCalendar(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final target = _findById(_calendars, id);
    if (target == null) return;
    final usedByWeekend = _weekends.any((item) => item.calendarId == target.id);
    final usedByException = _exceptions.any(
      (item) => item.calendarId == target.id,
    );
    final usedByMember = _setMembers.any((item) => item.calendarId == target.id);
    if (usedByWeekend || usedByException || usedByMember) {
      throw StateError('Calendar is referenced by child table(s).');
    }
    _calendars.removeWhere((item) => item.id == target.id);
  }

  @override
  Future<List<CalendarWeekendFormData>> getCalendarWeekendList({
    required String calendarId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final normalizedId = calendarId.trim();
    return _weekends
        .where((item) => item.calendarId == normalizedId)
        .toList(growable: false);
  }

  @override
  Future<CalendarWeekendFormData?> getCalendarWeekendById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _findById(_weekends, id);
  }

  @override
  Future<CalendarWeekendFormData> createCalendarWeekend(
    CalendarWeekendFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final normalized = _normalizeWeekend(data);
    final key = _weekendKey(normalized.calendarId, normalized.validFrom!);
    final duplicate = _weekends.any((item) => item.id == key);
    if (duplicate) {
      throw StateError('Duplicate CalendarWeekend: $key');
    }
    final created = normalized.copyWith(id: key);
    _weekends.insert(0, created);
    return created;
  }

  @override
  Future<CalendarWeekendFormData> patchCalendarWeekend(
    CalendarWeekendFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final oldId = (data.id ?? '').trim();
    if (oldId.isEmpty) {
      throw StateError('CalendarWeekend id is required.');
    }
    final index = _weekends.indexWhere((item) => item.id == oldId);
    if (index < 0) {
      throw StateError('CalendarWeekend not found: $oldId');
    }
    final normalized = _normalizeWeekend(data);
    final newId = _weekendKey(normalized.calendarId, normalized.validFrom!);
    final duplicate = _weekends.any(
      (item) => item.id != oldId && item.id == newId,
    );
    if (duplicate) {
      throw StateError('Duplicate CalendarWeekend: $newId');
    }
    final updated = normalized.copyWith(id: newId);
    _weekends[index] = updated;
    return updated;
  }

  @override
  Future<CalendarWeekendFormData> putCalendarWeekend(
    CalendarWeekendFormData data,
  ) {
    return patchCalendarWeekend(data);
  }

  @override
  Future<CalendarWeekendFormData> updateCalendarWeekend(
    CalendarWeekendFormData data,
  ) {
    return patchCalendarWeekend(data);
  }

  @override
  Future<void> deleteCalendarWeekend(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _weekends.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<CalendarExceptionFormData>> getCalendarExceptionList({
    required String calendarId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final normalizedId = calendarId.trim();
    return _exceptions
        .where((item) => item.calendarId == normalizedId)
        .toList(growable: false);
  }

  @override
  Future<CalendarExceptionFormData?> getCalendarExceptionById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _findById(_exceptions, id);
  }

  @override
  Future<CalendarExceptionFormData> createCalendarException(
    CalendarExceptionFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final normalized = _normalizeException(data);
    final key = _exceptionKey(normalized.calendarId, normalized.exceptionDate!);
    final duplicate = _exceptions.any((item) => item.id == key);
    if (duplicate) {
      throw StateError('Duplicate CalendarException: $key');
    }
    final created = normalized.copyWith(
      id: key,
      createdAt: normalized.createdAt ?? DateTime.now(),
    );
    _exceptions.insert(0, created);
    return created;
  }

  @override
  Future<CalendarExceptionFormData> patchCalendarException(
    CalendarExceptionFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final oldId = (data.id ?? '').trim();
    if (oldId.isEmpty) {
      throw StateError('CalendarException id is required.');
    }
    final index = _exceptions.indexWhere((item) => item.id == oldId);
    if (index < 0) {
      throw StateError('CalendarException not found: $oldId');
    }
    final normalized = _normalizeException(data);
    final newId = _exceptionKey(
      normalized.calendarId,
      normalized.exceptionDate!,
    );
    final duplicate = _exceptions.any(
      (item) => item.id != oldId && item.id == newId,
    );
    if (duplicate) {
      throw StateError('Duplicate CalendarException: $newId');
    }
    final updated = normalized.copyWith(
      id: newId,
      createdAt: _exceptions[index].createdAt ?? DateTime.now(),
    );
    _exceptions[index] = updated;
    return updated;
  }

  @override
  Future<CalendarExceptionFormData> putCalendarException(
    CalendarExceptionFormData data,
  ) {
    return patchCalendarException(data);
  }

  @override
  Future<CalendarExceptionFormData> updateCalendarException(
    CalendarExceptionFormData data,
  ) {
    return patchCalendarException(data);
  }

  @override
  Future<void> deleteCalendarException(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _exceptions.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<CalendarSetFormData>> getCalendarSetList() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List<CalendarSetFormData>.from(_sets);
  }

  @override
  Future<CalendarSetFormData?> getCalendarSetById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _findById(_sets, id);
  }

  @override
  Future<CalendarSetFormData> createCalendarSet(CalendarSetFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final setCode = data.setCode.trim();
    if (setCode.isEmpty) {
      throw StateError('setCode is required.');
    }
    final duplicate = _sets.any((item) => item.setCode == setCode);
    if (duplicate) {
      throw StateError('Duplicate setCode: $setCode');
    }
    final created = data.copyWith(
      id: data.id ?? 'cset_${DateTime.now().millisecondsSinceEpoch}',
      setCode: setCode,
      description: data.description.trim(),
    );
    _sets.insert(0, created);
    return created;
  }

  @override
  Future<CalendarSetFormData> patchCalendarSet(CalendarSetFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('CalendarSet id is required.');
    }
    final index = _sets.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw StateError('CalendarSet not found: $id');
    }
    final setCode = data.setCode.trim();
    if (setCode.isEmpty) {
      throw StateError('setCode is required.');
    }
    final duplicate = _sets.any(
      (item) => item.id != id && item.setCode == setCode,
    );
    if (duplicate) {
      throw StateError('Duplicate setCode: $setCode');
    }
    final updated = data.copyWith(
      id: id,
      setCode: setCode,
      description: data.description.trim(),
    );
    _sets[index] = updated;
    _syncSetMembersForSet(updated);
    return updated;
  }

  @override
  Future<CalendarSetFormData> putCalendarSet(CalendarSetFormData data) {
    return patchCalendarSet(data);
  }

  @override
  Future<CalendarSetFormData> updateCalendarSet(CalendarSetFormData data) {
    return patchCalendarSet(data);
  }

  @override
  Future<void> deleteCalendarSet(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final target = _findById(_sets, id);
    if (target == null) return;
    final usedByMember = _setMembers.any((item) => item.calendarSetId == target.id);
    if (usedByMember) {
      throw StateError('CalendarSet is referenced by CalendarSetMember.');
    }
    _sets.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<CalendarSetMemberFormData>> getCalendarSetMemberList({
    required String calendarSetId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final normalizedId = calendarSetId.trim();
    return _setMembers
        .where((item) => item.calendarSetId == normalizedId)
        .toList(growable: false);
  }

  @override
  Future<CalendarSetMemberFormData?> getCalendarSetMemberById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _findById(_setMembers, id);
  }

  @override
  Future<CalendarSetMemberFormData> createCalendarSetMember(
    CalendarSetMemberFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final normalized = _normalizeSetMember(data);
    final key = _setMemberKey(normalized.calendarSetId, normalized.calendarId);
    final duplicate = _setMembers.any((item) => item.id == key);
    if (duplicate) {
      throw StateError('Duplicate CalendarSetMember: $key');
    }
    final created = normalized.copyWith(id: key);
    _setMembers.insert(0, created);
    return created;
  }

  @override
  Future<CalendarSetMemberFormData> patchCalendarSetMember(
    CalendarSetMemberFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final oldId = (data.id ?? '').trim();
    if (oldId.isEmpty) {
      throw StateError('CalendarSetMember id is required.');
    }
    final index = _setMembers.indexWhere((item) => item.id == oldId);
    if (index < 0) {
      throw StateError('CalendarSetMember not found: $oldId');
    }
    final normalized = _normalizeSetMember(data);
    final newId = _setMemberKey(normalized.calendarSetId, normalized.calendarId);
    final duplicate = _setMembers.any(
      (item) => item.id != oldId && item.id == newId,
    );
    if (duplicate) {
      throw StateError('Duplicate CalendarSetMember: $newId');
    }
    final updated = normalized.copyWith(id: newId);
    _setMembers[index] = updated;
    return updated;
  }

  @override
  Future<CalendarSetMemberFormData> putCalendarSetMember(
    CalendarSetMemberFormData data,
  ) {
    return patchCalendarSetMember(data);
  }

  @override
  Future<CalendarSetMemberFormData> updateCalendarSetMember(
    CalendarSetMemberFormData data,
  ) {
    return patchCalendarSetMember(data);
  }

  @override
  Future<void> deleteCalendarSetMember(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _setMembers.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<WeekendProfileFormData>> getWeekendProfileList() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List<WeekendProfileFormData>.from(_weekendProfiles);
  }

  @override
  Future<WeekendProfileFormData?> getWeekendProfileById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _findById(_weekendProfiles, id);
  }

  @override
  Future<WeekendProfileFormData> createWeekendProfile(
    WeekendProfileFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final code = data.weekendProfileCode.trim();
    if (code.isEmpty) {
      throw StateError('weekendProfileCode is required.');
    }
    final duplicate = _weekendProfiles.any(
      (item) => item.weekendProfileCode == code,
    );
    if (duplicate) {
      throw StateError('Duplicate weekendProfileCode: $code');
    }
    final created = data.copyWith(
      id: data.id ?? 'wkp_${DateTime.now().millisecondsSinceEpoch}',
      weekendProfileCode: code,
      name: data.name.trim(),
      description: data.description.trim(),
    );
    _weekendProfiles.insert(0, created);
    return created;
  }

  @override
  Future<WeekendProfileFormData> patchWeekendProfile(
    WeekendProfileFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('WeekendProfile id is required.');
    }
    final index = _weekendProfiles.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw StateError('WeekendProfile not found: $id');
    }
    final code = data.weekendProfileCode.trim();
    if (code.isEmpty) {
      throw StateError('weekendProfileCode is required.');
    }
    final duplicate = _weekendProfiles.any(
      (item) => item.id != id && item.weekendProfileCode == code,
    );
    if (duplicate) {
      throw StateError('Duplicate weekendProfileCode: $code');
    }
    final updated = data.copyWith(
      id: id,
      weekendProfileCode: code,
      name: data.name.trim(),
      description: data.description.trim(),
    );
    _weekendProfiles[index] = updated;
    _syncWeekendProfileDays(updated);
    _syncWeekendsForWeekendProfile(updated);
    return updated;
  }

  @override
  Future<WeekendProfileFormData> putWeekendProfile(WeekendProfileFormData data) {
    return patchWeekendProfile(data);
  }

  @override
  Future<WeekendProfileFormData> updateWeekendProfile(
    WeekendProfileFormData data,
  ) {
    return patchWeekendProfile(data);
  }

  @override
  Future<void> deleteWeekendProfile(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final target = _findById(_weekendProfiles, id);
    if (target == null) return;
    final usedByWeekend = _weekends.any(
      (item) => item.weekendProfileId == target.id,
    );
    if (usedByWeekend) {
      throw StateError('WeekendProfile is referenced by CalendarWeekend.');
    }
    _weekendProfiles.removeWhere((item) => item.id == id);
    _weekendProfileDays.removeWhere((item) => item.weekendProfileId == id);
  }

  @override
  Future<List<WeekendProfileDayFormData>> getWeekendProfileDayList({
    required String weekendProfileId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final normalizedId = weekendProfileId.trim();
    return _weekendProfileDays
        .where((item) => item.weekendProfileId == normalizedId)
        .toList(growable: false);
  }

  @override
  Future<WeekendProfileDayFormData?> getWeekendProfileDayById(
    String id,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _findById(_weekendProfileDays, id);
  }

  @override
  Future<WeekendProfileDayFormData> createWeekendProfileDay(
    WeekendProfileDayFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final normalized = _normalizeWeekendProfileDay(data);
    final key = _weekendProfileDayKey(
      normalized.weekendProfileId,
      normalized.isoWeekday,
    );
    final duplicate = _weekendProfileDays.any((item) => item.id == key);
    if (duplicate) {
      throw StateError('Duplicate WeekendProfileDay: $key');
    }
    final created = normalized.copyWith(id: key);
    _weekendProfileDays.insert(0, created);
    return created;
  }

  @override
  Future<WeekendProfileDayFormData> patchWeekendProfileDay(
    WeekendProfileDayFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final oldId = (data.id ?? '').trim();
    if (oldId.isEmpty) {
      throw StateError('WeekendProfileDay id is required.');
    }
    final index = _weekendProfileDays.indexWhere((item) => item.id == oldId);
    if (index < 0) {
      throw StateError('WeekendProfileDay not found: $oldId');
    }
    final normalized = _normalizeWeekendProfileDay(data);
    final newId = _weekendProfileDayKey(
      normalized.weekendProfileId,
      normalized.isoWeekday,
    );
    final duplicate = _weekendProfileDays.any(
      (item) => item.id != oldId && item.id == newId,
    );
    if (duplicate) {
      throw StateError('Duplicate WeekendProfileDay: $newId');
    }
    final updated = normalized.copyWith(id: newId);
    _weekendProfileDays[index] = updated;
    return updated;
  }

  @override
  Future<WeekendProfileDayFormData> putWeekendProfileDay(
    WeekendProfileDayFormData data,
  ) {
    return patchWeekendProfileDay(data);
  }

  @override
  Future<WeekendProfileDayFormData> updateWeekendProfileDay(
    WeekendProfileDayFormData data,
  ) {
    return patchWeekendProfileDay(data);
  }

  @override
  Future<void> deleteWeekendProfileDay(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _weekendProfileDays.removeWhere((item) => item.id == id);
  }

  CalendarWeekendFormData _normalizeWeekend(CalendarWeekendFormData data) {
    final calendar = _findCalendarByIdOrCode(
      calendarId: data.calendarId,
      calendarCode: data.calendarCode,
    );
    if (calendar == null) {
      throw StateError('Calendar not found.');
    }
    final validFrom = data.validFrom;
    if (validFrom == null) {
      throw StateError('validFrom is required.');
    }
    final validTo = data.validTo;
    if (validTo != null && !validTo.isAfter(validFrom)) {
      throw StateError('validTo must be after validFrom.');
    }
    final weekendProfile = _findWeekendProfileByIdOrCode(
      weekendProfileId: data.weekendProfileId,
      weekendProfileCode: data.weekendProfileCode,
    );
    if (weekendProfile == null) {
      throw StateError('WeekendProfile not found.');
    }
    return data.copyWith(
      calendarId: calendar.id ?? '',
      calendarCode: calendar.calendarCode,
      calendarName: calendar.name,
      weekendProfileId: weekendProfile.id ?? '',
      weekendProfileCode: weekendProfile.weekendProfileCode,
      weekendProfileName: weekendProfile.name,
    );
  }

  CalendarExceptionFormData _normalizeException(CalendarExceptionFormData data) {
    final calendar = _findCalendarByIdOrCode(
      calendarId: data.calendarId,
      calendarCode: data.calendarCode,
    );
    if (calendar == null) {
      throw StateError('Calendar not found.');
    }
    final exceptionDate = data.exceptionDate;
    if (exceptionDate == null) {
      throw StateError('exceptionDate is required.');
    }
    return data.copyWith(
      calendarId: calendar.id ?? '',
      calendarCode: calendar.calendarCode,
      calendarName: calendar.name,
      name: data.name.trim(),
      source: data.source.trim(),
    );
  }

  CalendarSetMemberFormData _normalizeSetMember(
    CalendarSetMemberFormData data,
  ) {
    final set = _findCalendarSetByIdOrCode(
      calendarSetId: data.calendarSetId,
      calendarSetCode: data.calendarSetCode,
    );
    final calendar = _findCalendarByIdOrCode(
      calendarId: data.calendarId,
      calendarCode: data.calendarCode,
    );
    if (set == null || calendar == null) {
      throw StateError('CalendarSet/Calendar not found.');
    }
    if (data.seqNo <= 0) {
      throw StateError('seqNo must be greater than zero.');
    }
    return data.copyWith(
      calendarSetId: set.id ?? '',
      calendarSetCode: set.setCode,
      calendarId: calendar.id ?? '',
      calendarCode: calendar.calendarCode,
      calendarName: calendar.name,
    );
  }

  WeekendProfileDayFormData _normalizeWeekendProfileDay(
    WeekendProfileDayFormData data,
  ) {
    final weekendProfile = _findWeekendProfileByIdOrCode(
      weekendProfileId: data.weekendProfileId,
      weekendProfileCode: data.weekendProfileCode,
    );
    if (weekendProfile == null) {
      throw StateError('WeekendProfile not found.');
    }
    if (data.isoWeekday < 1 || data.isoWeekday > 7) {
      throw StateError('isoWeekday must be between 1 and 7.');
    }
    return data.copyWith(
      weekendProfileId: weekendProfile.id ?? '',
      weekendProfileCode: weekendProfile.weekendProfileCode,
    );
  }

  void _syncCalendarChildren(CalendarFormData calendar) {
    for (var i = 0; i < _weekends.length; i++) {
      final item = _weekends[i];
      if (item.calendarId != calendar.id) continue;
      _weekends[i] = item.copyWith(
        calendarCode: calendar.calendarCode,
        calendarName: calendar.name,
        id: _weekendKey(calendar.id ?? '', item.validFrom!),
      );
    }
    for (var i = 0; i < _exceptions.length; i++) {
      final item = _exceptions[i];
      if (item.calendarId != calendar.id) continue;
      _exceptions[i] = item.copyWith(
        calendarCode: calendar.calendarCode,
        calendarName: calendar.name,
        id: _exceptionKey(calendar.id ?? '', item.exceptionDate!),
      );
    }
    for (var i = 0; i < _setMembers.length; i++) {
      final item = _setMembers[i];
      if (item.calendarId != calendar.id) continue;
      _setMembers[i] = item.copyWith(
        calendarCode: calendar.calendarCode,
        calendarName: calendar.name,
        id: _setMemberKey(item.calendarSetId, calendar.id ?? ''),
      );
    }
  }

  void _syncSetMembersForSet(CalendarSetFormData calendarSet) {
    for (var i = 0; i < _setMembers.length; i++) {
      final item = _setMembers[i];
      if (item.calendarSetId != calendarSet.id) continue;
      _setMembers[i] = item.copyWith(
        calendarSetCode: calendarSet.setCode,
        id: _setMemberKey(calendarSet.id ?? '', item.calendarId),
      );
    }
  }

  void _syncWeekendProfileDays(WeekendProfileFormData weekendProfile) {
    for (var i = 0; i < _weekendProfileDays.length; i++) {
      final item = _weekendProfileDays[i];
      if (item.weekendProfileId != weekendProfile.id) continue;
      _weekendProfileDays[i] = item.copyWith(
        weekendProfileCode: weekendProfile.weekendProfileCode,
        id: _weekendProfileDayKey(weekendProfile.id ?? '', item.isoWeekday),
      );
    }
  }

  void _syncWeekendsForWeekendProfile(WeekendProfileFormData weekendProfile) {
    for (var i = 0; i < _weekends.length; i++) {
      final item = _weekends[i];
      if (item.weekendProfileId != weekendProfile.id) continue;
      _weekends[i] = item.copyWith(
        weekendProfileCode: weekendProfile.weekendProfileCode,
        weekendProfileName: weekendProfile.name,
      );
    }
  }

  CalendarFormData? _findCalendarByIdOrCode({
    required String calendarId,
    required String calendarCode,
  }) {
    final idText = calendarId.trim();
    if (idText.isNotEmpty) {
      final direct = _findById(_calendars, idText);
      if (direct != null) return direct;
    }
    final codeText = calendarCode.trim();
    if (codeText.isEmpty) return null;
    return _firstWhereOrNull(
      _calendars,
      (item) => item.calendarCode == codeText,
    );
  }

  CalendarSetFormData? _findCalendarSetByIdOrCode({
    required String calendarSetId,
    required String calendarSetCode,
  }) {
    final idText = calendarSetId.trim();
    if (idText.isNotEmpty) {
      final direct = _findById(_sets, idText);
      if (direct != null) return direct;
    }
    final codeText = calendarSetCode.trim();
    if (codeText.isEmpty) return null;
    return _firstWhereOrNull(_sets, (item) => item.setCode == codeText);
  }

  WeekendProfileFormData? _findWeekendProfileByIdOrCode({
    required String weekendProfileId,
    required String weekendProfileCode,
  }) {
    final idText = weekendProfileId.trim();
    if (idText.isNotEmpty) {
      final direct = _findById(_weekendProfiles, idText);
      if (direct != null) return direct;
    }
    final codeText = weekendProfileCode.trim();
    if (codeText.isEmpty) return null;
    return _firstWhereOrNull(
      _weekendProfiles,
      (item) => item.weekendProfileCode == codeText,
    );
  }

  static T? _findById<T>(List<T> items, String id) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;
    return _firstWhereOrNull(items, (item) => (item as dynamic).id == normalizedId);
  }

  static T? _firstWhereOrNull<T>(List<T> items, bool Function(T item) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  static String _weekendKey(String calendarId, DateTime validFrom) {
    return '$calendarId|${_formatDate(validFrom)}';
  }

  static String _exceptionKey(String calendarId, DateTime exceptionDate) {
    return '$calendarId|${_formatDate(exceptionDate)}';
  }

  static String _setMemberKey(String calendarSetId, String calendarId) {
    return '$calendarSetId|$calendarId';
  }

  static String _weekendProfileDayKey(String weekendProfileId, int isoWeekday) {
    return '$weekendProfileId|$isoWeekday';
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
