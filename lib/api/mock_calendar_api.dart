import '../models/calendar_enums.dart';
import '../models/calendar_exception_form_data.dart';
import '../models/calendar_form_data.dart';
import '../models/calendar_set_form_data.dart';
import '../models/calendar_set_member_form_data.dart';
import '../models/calendar_weekend_form_data.dart';
import 'calendar_api.dart';

class MockCalendarApi implements CalendarApi {
  MockCalendarApi() {
    _calendars.addAll(_seedCalendars);
    _weekends.addAll(_seedWeekends);
    _exceptions.addAll(_seedExceptions);
    _sets.addAll(_seedSets);
    _setMembers.addAll(_seedSetMembers);
  }

  final List<CalendarFormData> _calendars = [];
  final List<CalendarWeekendFormData> _weekends = [];
  final List<CalendarExceptionFormData> _exceptions = [];
  final List<CalendarSetFormData> _sets = [];
  final List<CalendarSetMemberFormData> _setMembers = [];

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

  static List<CalendarWeekendFormData> get _seedWeekends => [
    CalendarWeekendFormData(
      id: _weekendKey('KR_BANK', DateTime(2000, 1, 1)),
      calendarCode: 'KR_BANK',
      validFrom: DateTime(2000, 1, 1),
      weekendProfileCode: 'SAT_SUN',
    ),
    CalendarWeekendFormData(
      id: _weekendKey('USNY', DateTime(2000, 1, 1)),
      calendarCode: 'USNY',
      validFrom: DateTime(2000, 1, 1),
      weekendProfileCode: 'SAT_SUN',
    ),
  ];

  static List<CalendarExceptionFormData> get _seedExceptions => [
    CalendarExceptionFormData(
      id: _exceptionKey('KR_BANK', DateTime(2026, 1, 1)),
      calendarCode: 'KR_BANK',
      exceptionDate: DateTime(2026, 1, 1),
      businessDay: false,
      exceptionType: CalendarExceptionType.holiday,
      name: 'New Year',
      source: 'Seed',
      createdAt: DateTime(2026, 1, 1),
    ),
    CalendarExceptionFormData(
      id: _exceptionKey('USNY', DateTime(2026, 7, 4)),
      calendarCode: 'USNY',
      exceptionDate: DateTime(2026, 7, 4),
      businessDay: false,
      exceptionType: CalendarExceptionType.holiday,
      name: 'Independence Day',
      source: 'Seed',
      createdAt: DateTime(2026, 1, 1),
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

  static List<CalendarSetMemberFormData> get _seedSetMembers => const [
    CalendarSetMemberFormData(
      id: 'KR_BANK+USNY|KR_BANK',
      calendarSetCode: 'KR_BANK+USNY',
      calendarCode: 'KR_BANK',
      seqNo: 1,
    ),
    CalendarSetMemberFormData(
      id: 'KR_BANK+USNY|USNY',
      calendarSetCode: 'KR_BANK+USNY',
      calendarCode: 'USNY',
      seqNo: 2,
    ),
  ];

  @override
  Future<List<CalendarFormData>> getCalendarList({bool? active}) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    var items = List<CalendarFormData>.from(_calendars);
    if (active != null) {
      items = items.where((e) => e.active == active).toList();
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
    final duplicate = _calendars.any((e) => e.calendarCode == code);
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
    final idx = _calendars.indexWhere((e) => e.id == id);
    if (idx < 0) {
      throw StateError('Calendar not found: $id');
    }
    final code = data.calendarCode.trim();
    if (code.isEmpty) {
      throw StateError('calendarCode is required.');
    }
    final duplicate = _calendars.any(
      (e) => e.id != id && e.calendarCode == code,
    );
    if (duplicate) {
      throw StateError('Duplicate calendarCode: $code');
    }

    final before = _calendars[idx];
    final oldCode = before.calendarCode;
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
    _calendars[idx] = updated;

    if (oldCode != code) {
      _renameCalendarCode(oldCode: oldCode, newCode: code);
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

    final code = target.calendarCode;
    final usedByWeekend = _weekends.any((e) => e.calendarCode == code);
    final usedByException = _exceptions.any((e) => e.calendarCode == code);
    final usedByMember = _setMembers.any((e) => e.calendarCode == code);
    if (usedByWeekend || usedByException || usedByMember) {
      throw StateError('Calendar is referenced by child table(s).');
    }
    _calendars.removeWhere((e) => e.id == target.id);
  }

  @override
  Future<List<CalendarWeekendFormData>> getCalendarWeekendList() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List<CalendarWeekendFormData>.from(_weekends);
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
    final key = _weekendKey(normalized.calendarCode, normalized.validFrom!);
    final duplicate = _weekends.any((e) => e.id == key);
    if (duplicate) {
      throw StateError('Duplicate CalendarWeekend: $key');
    }
    final created = normalized.copyWith(id: key);
    _weekends.insert(0, created);
    return created;
  }

  @override
  Future<CalendarWeekendFormData> updateCalendarWeekend(
    CalendarWeekendFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final oldId = (data.id ?? '').trim();
    if (oldId.isEmpty) {
      throw StateError('CalendarWeekend id is required.');
    }
    final idx = _weekends.indexWhere((e) => e.id == oldId);
    if (idx < 0) {
      throw StateError('CalendarWeekend not found: $oldId');
    }

    final normalized = _normalizeWeekend(data);
    final newId = _weekendKey(normalized.calendarCode, normalized.validFrom!);
    final duplicate = _weekends.any((e) => e.id != oldId && e.id == newId);
    if (duplicate) {
      throw StateError('Duplicate CalendarWeekend: $newId');
    }
    final updated = normalized.copyWith(id: newId);
    _weekends[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteCalendarWeekend(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _weekends.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<CalendarExceptionFormData>> getCalendarExceptionList() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List<CalendarExceptionFormData>.from(_exceptions);
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
    final key = _exceptionKey(
      normalized.calendarCode,
      normalized.exceptionDate!,
    );
    final duplicate = _exceptions.any((e) => e.id == key);
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
  Future<CalendarExceptionFormData> updateCalendarException(
    CalendarExceptionFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final oldId = (data.id ?? '').trim();
    if (oldId.isEmpty) {
      throw StateError('CalendarException id is required.');
    }
    final idx = _exceptions.indexWhere((e) => e.id == oldId);
    if (idx < 0) {
      throw StateError('CalendarException not found: $oldId');
    }

    final normalized = _normalizeException(data);
    final newId = _exceptionKey(
      normalized.calendarCode,
      normalized.exceptionDate!,
    );
    final duplicate = _exceptions.any((e) => e.id != oldId && e.id == newId);
    if (duplicate) {
      throw StateError('Duplicate CalendarException: $newId');
    }
    final updated = normalized.copyWith(
      id: newId,
      createdAt: _exceptions[idx].createdAt ?? DateTime.now(),
    );
    _exceptions[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteCalendarException(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _exceptions.removeWhere((e) => e.id == id);
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
  Future<CalendarSetFormData> createCalendarSet(
    CalendarSetFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final setCode = data.setCode.trim();
    if (setCode.isEmpty) {
      throw StateError('setCode is required.');
    }
    final duplicate = _sets.any((e) => e.setCode == setCode);
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
  Future<CalendarSetFormData> updateCalendarSet(
    CalendarSetFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('CalendarSet id is required.');
    }
    final idx = _sets.indexWhere((e) => e.id == id);
    if (idx < 0) {
      throw StateError('CalendarSet not found: $id');
    }

    final setCode = data.setCode.trim();
    if (setCode.isEmpty) {
      throw StateError('setCode is required.');
    }
    final duplicate = _sets.any((e) => e.id != id && e.setCode == setCode);
    if (duplicate) {
      throw StateError('Duplicate setCode: $setCode');
    }

    final before = _sets[idx];
    final oldCode = before.setCode;
    final updated = data.copyWith(
      id: id,
      setCode: setCode,
      description: data.description.trim(),
    );
    _sets[idx] = updated;

    if (oldCode != setCode) {
      _renameSetCode(oldCode: oldCode, newCode: setCode);
    }
    return updated;
  }

  @override
  Future<void> deleteCalendarSet(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final target = _findById(_sets, id);
    if (target == null) return;
    final usedByMember = _setMembers.any(
      (e) => e.calendarSetCode == target.setCode,
    );
    if (usedByMember) {
      throw StateError('CalendarSet is referenced by CalendarSetMember.');
    }
    _sets.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<CalendarSetMemberFormData>> getCalendarSetMemberList() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List<CalendarSetMemberFormData>.from(_setMembers);
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
    final key = _setMemberKey(
      normalized.calendarSetCode,
      normalized.calendarCode,
    );
    final duplicate = _setMembers.any((e) => e.id == key);
    if (duplicate) {
      throw StateError('Duplicate CalendarSetMember: $key');
    }
    final created = normalized.copyWith(id: key);
    _setMembers.insert(0, created);
    return created;
  }

  @override
  Future<CalendarSetMemberFormData> updateCalendarSetMember(
    CalendarSetMemberFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final oldId = (data.id ?? '').trim();
    if (oldId.isEmpty) {
      throw StateError('CalendarSetMember id is required.');
    }
    final idx = _setMembers.indexWhere((e) => e.id == oldId);
    if (idx < 0) {
      throw StateError('CalendarSetMember not found: $oldId');
    }

    final normalized = _normalizeSetMember(data);
    final newId = _setMemberKey(
      normalized.calendarSetCode,
      normalized.calendarCode,
    );
    final duplicate = _setMembers.any((e) => e.id != oldId && e.id == newId);
    if (duplicate) {
      throw StateError('Duplicate CalendarSetMember: $newId');
    }
    final updated = normalized.copyWith(id: newId);
    _setMembers[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteCalendarSetMember(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _setMembers.removeWhere((e) => e.id == id);
  }

  CalendarWeekendFormData _normalizeWeekend(CalendarWeekendFormData data) {
    final calendarCode = data.calendarCode.trim();
    if (calendarCode.isEmpty) {
      throw StateError('calendarCode is required.');
    }
    if (!_calendars.any((e) => e.calendarCode == calendarCode)) {
      throw StateError('Calendar not found: $calendarCode');
    }
    final validFrom = data.validFrom;
    if (validFrom == null) {
      throw StateError('validFrom is required.');
    }
    final validTo = data.validTo;
    if (validTo != null && !validTo.isAfter(validFrom)) {
      throw StateError('validTo must be after validFrom.');
    }
    return data.copyWith(
      calendarCode: calendarCode,
      weekendProfileCode: data.weekendProfileCode.trim(),
    );
  }

  CalendarExceptionFormData _normalizeException(
    CalendarExceptionFormData data,
  ) {
    final calendarCode = data.calendarCode.trim();
    if (calendarCode.isEmpty) {
      throw StateError('calendarCode is required.');
    }
    if (!_calendars.any((e) => e.calendarCode == calendarCode)) {
      throw StateError('Calendar not found: $calendarCode');
    }
    final exceptionDate = data.exceptionDate;
    if (exceptionDate == null) {
      throw StateError('exceptionDate is required.');
    }
    return data.copyWith(
      calendarCode: calendarCode,
      name: data.name.trim(),
      source: data.source.trim(),
    );
  }

  CalendarSetMemberFormData _normalizeSetMember(
    CalendarSetMemberFormData data,
  ) {
    final setCode = data.calendarSetCode.trim();
    final calendarCode = data.calendarCode.trim();
    if (setCode.isEmpty || calendarCode.isEmpty) {
      throw StateError('calendarSetCode/calendarCode is required.');
    }
    if (!_sets.any((e) => e.setCode == setCode)) {
      throw StateError('CalendarSet not found: $setCode');
    }
    if (!_calendars.any((e) => e.calendarCode == calendarCode)) {
      throw StateError('Calendar not found: $calendarCode');
    }
    if (data.seqNo <= 0) {
      throw StateError('seqNo must be greater than zero.');
    }
    return data.copyWith(calendarSetCode: setCode, calendarCode: calendarCode);
  }

  void _renameCalendarCode({required String oldCode, required String newCode}) {
    for (var i = 0; i < _weekends.length; i++) {
      final e = _weekends[i];
      if (e.calendarCode != oldCode) continue;
      final updated = e.copyWith(
        calendarCode: newCode,
        id: _weekendKey(newCode, e.validFrom!),
      );
      _weekends[i] = updated;
    }

    for (var i = 0; i < _exceptions.length; i++) {
      final e = _exceptions[i];
      if (e.calendarCode != oldCode) continue;
      final updated = e.copyWith(
        calendarCode: newCode,
        id: _exceptionKey(newCode, e.exceptionDate!),
      );
      _exceptions[i] = updated;
    }

    for (var i = 0; i < _setMembers.length; i++) {
      final e = _setMembers[i];
      if (e.calendarCode != oldCode) continue;
      final updated = e.copyWith(
        calendarCode: newCode,
        id: _setMemberKey(e.calendarSetCode, newCode),
      );
      _setMembers[i] = updated;
    }
  }

  void _renameSetCode({required String oldCode, required String newCode}) {
    for (var i = 0; i < _setMembers.length; i++) {
      final e = _setMembers[i];
      if (e.calendarSetCode != oldCode) continue;
      final updated = e.copyWith(
        calendarSetCode: newCode,
        id: _setMemberKey(newCode, e.calendarCode),
      );
      _setMembers[i] = updated;
    }
  }

  static T? _findById<T>(List<T> list, String id) {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;
    try {
      return list.firstWhere((e) {
        final value = (e as dynamic).id as String?;
        return value == normalized;
      });
    } catch (_) {
      return null;
    }
  }

  static String _weekendKey(String calendarCode, DateTime validFrom) {
    return '$calendarCode|${_formatDate(validFrom)}';
  }

  static String _exceptionKey(String calendarCode, DateTime exceptionDate) {
    return '$calendarCode|${_formatDate(exceptionDate)}';
  }

  static String _setMemberKey(String setCode, String calendarCode) {
    return '$setCode|$calendarCode';
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
