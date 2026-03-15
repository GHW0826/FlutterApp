import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/calendar_enums.dart';
import '../models/calendar_exception_form_data.dart';
import '../models/calendar_form_data.dart';
import '../models/calendar_set_form_data.dart';
import '../models/calendar_set_member_form_data.dart';
import '../models/calendar_weekend_form_data.dart';
import '../models/weekend_profile_day_form_data.dart';
import '../models/weekend_profile_form_data.dart';
import 'calendar_api.dart';
import 'mock_calendar_api.dart';

class RemoteCalendarApi implements CalendarApi {
  RemoteCalendarApi({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 5),
  }) : _fallback = MockCalendarApi();

  final String baseUrl;
  final Duration timeout;
  final MockCalendarApi _fallback;
  final List<CalendarFormData> _cachedCalendars = [];
  final List<CalendarSetFormData> _cachedCalendarSets = [];
  final List<WeekendProfileFormData> _cachedWeekendProfiles = [];

  String get _normalizedBaseUrl => baseUrl.replaceAll(RegExp(r'/+$'), '');
  String get _calendarUrl => '$_normalizedBaseUrl/api/v1/calendars';
  String get _calendarExceptionUrl =>
      '$_normalizedBaseUrl/api/v1/calendar-exceptions';
  String get _calendarSetUrl => '$_normalizedBaseUrl/api/v1/calendar-sets';
  String get _calendarSetMemberUrl =>
      '$_normalizedBaseUrl/api/v1/calendar-set-members';
  String get _calendarWeekendUrl =>
      '$_normalizedBaseUrl/api/v1/calendar-weekends';
  String get _weekendProfileUrl =>
      '$_normalizedBaseUrl/api/v1/weekend-profiles';
  String get _weekendProfileDayUrl =>
      '$_normalizedBaseUrl/api/v1/weekend-profile-days';

  String _calendarByIdUrl(String id) => '$_calendarUrl/$id';
  String _calendarExceptionByKeyUrl(String calendarId, DateTime exceptionDate) {
    return '$_calendarExceptionUrl/$calendarId/${_formatDate(exceptionDate)}';
  }

  String _calendarSetByIdUrl(String id) => '$_calendarSetUrl/$id';
  String _calendarSetMemberByKeyUrl(String calendarSetId, String calendarId) {
    return '$_calendarSetMemberUrl/$calendarSetId/$calendarId';
  }

  String _calendarWeekendByKeyUrl(String calendarId, DateTime validFrom) {
    return '$_calendarWeekendUrl/$calendarId/${_formatDate(validFrom)}';
  }

  String _weekendProfileByIdUrl(String id) => '$_weekendProfileUrl/$id';
  String _weekendProfileDayByKeyUrl(String profileId, int isoWeekday) {
    return '$_weekendProfileDayUrl/$profileId/$isoWeekday';
  }

  @override
  Future<List<CalendarFormData>> getCalendarList({bool? active}) async {
    final uri = Uri.parse(
      _calendarUrl,
    ).replace(queryParameters: {if (active != null) 'active': '$active'});
    final decoded = await _getDecoded(uri.toString(), fallbackStatuses: const {
      404,
      405,
    });
    if (decoded == _fallbackMarker) {
      return _fallback.getCalendarList(active: active);
    }
    final items = _parseCalendarList(decoded);
    _syncCalendars(items);
    return items;
  }

  @override
  Future<CalendarFormData?> getCalendarById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;
    final decoded = await _getDecoded(
      _calendarByIdUrl(normalizedId),
      notFoundAsNull: true,
      fallbackStatuses: const {405},
    );
    if (decoded == null) return null;
    if (decoded == _fallbackMarker) {
      return _fallback.getCalendarById(normalizedId);
    }
    final item = _calendarFromJson(_unwrap(decoded, const ['calendar']));
    _syncCalendar(item);
    return item;
  }

  @override
  Future<CalendarFormData> createCalendar(CalendarFormData data) async {
    final decoded = await _sendDecoded(
      'POST',
      _calendarUrl,
      body: _calendarCreateOrUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.createCalendar(data);
    }
    if (decoded == null) {
      _syncCalendar(data);
      return data;
    }
    final item = _calendarFromJson(_unwrap(decoded, const ['calendar']));
    _syncCalendar(item);
    return item;
  }

  @override
  Future<CalendarFormData> patchCalendar(CalendarFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('Calendar id is empty. PATCH requires /api/v1/calendars/{id}.');
    }
    final decoded = await _sendDecoded(
      'PATCH',
      _calendarByIdUrl(id),
      body: _calendarCreateOrUpdateJson(data),
    );
    if (decoded == null) {
      _syncCalendar(data);
      return data;
    }
    final item = _calendarFromJson(_unwrap(decoded, const ['calendar']));
    _syncCalendar(item);
    return item;
  }

  @override
  Future<CalendarFormData> putCalendar(CalendarFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('Calendar id is empty. PUT requires /api/v1/calendars/{id}.');
    }
    final decoded = await _sendDecoded(
      'PUT',
      _calendarByIdUrl(id),
      body: _calendarCreateOrUpdateJson(data),
    );
    if (decoded == null) {
      _syncCalendar(data);
      return data;
    }
    final item = _calendarFromJson(_unwrap(decoded, const ['calendar']));
    _syncCalendar(item);
    return item;
  }

  @override
  Future<CalendarFormData> updateCalendar(CalendarFormData data) {
    return patchCalendar(data);
  }

  @override
  Future<void> deleteCalendar(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw StateError('Calendar id is empty.');
    }
    await _sendDecoded('DELETE', _calendarByIdUrl(normalizedId));
    _cachedCalendars.removeWhere((item) => item.id == normalizedId);
    _fallback.replaceCalendars(_cachedCalendars);
  }

  @override
  Future<List<CalendarWeekendFormData>> getCalendarWeekendList({
    required String calendarId,
  }) async {
    final normalizedId = calendarId.trim();
    if (normalizedId.isEmpty) {
      throw StateError('calendarId is required.');
    }
    final uri = Uri.parse(
      _calendarWeekendUrl,
    ).replace(queryParameters: {'calendarId': normalizedId});
    final decoded = await _getDecoded(uri.toString(), fallbackStatuses: const {
      404,
      405,
    });
    if (decoded == _fallbackMarker) {
      return _fallback.getCalendarWeekendList(calendarId: normalizedId);
    }
    return _parseCalendarWeekendList(decoded, calendarId: normalizedId);
  }

  @override
  Future<CalendarWeekendFormData?> getCalendarWeekendById(String id) async {
    final key = _parseDateKey(id);
    if (key == null) return null;
    final decoded = await _getDecoded(
      _calendarWeekendByKeyUrl(key.parentId, key.date),
      notFoundAsNull: true,
      fallbackStatuses: const {405},
    );
    if (decoded == null) return null;
    if (decoded == _fallbackMarker) {
      return _fallback.getCalendarWeekendById(id);
    }
    return _calendarWeekendFromJson(_unwrap(decoded, const ['calendarWeekend']));
  }

  @override
  Future<CalendarWeekendFormData> createCalendarWeekend(
    CalendarWeekendFormData data,
  ) async {
    final calendarId = _resolveCalendarId(data.calendarId, data.calendarCode);
    if (calendarId.isEmpty) {
      throw StateError('CalendarWeekend calendarId is required.');
    }
    final decoded = await _sendDecoded(
      'POST',
      _calendarWeekendUrl,
      body: _calendarWeekendCreateJson(data, calendarId),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.createCalendarWeekend(data.copyWith(calendarId: calendarId));
    }
    if (decoded == null) {
      return data.copyWith(
        calendarId: calendarId,
        id: '$calendarId|${_formatDate(data.validFrom!)}',
      );
    }
    return _calendarWeekendFromJson(_unwrap(decoded, const ['calendarWeekend']));
  }

  @override
  Future<CalendarWeekendFormData> patchCalendarWeekend(
    CalendarWeekendFormData data,
  ) async {
    final key = _parseDateKey(data.id ?? '');
    if (key == null) {
      throw StateError(
        'CalendarWeekend id is empty. PATCH requires /api/v1/calendar-weekends/{calendarId}/{validFrom}.',
      );
    }
    final decoded = await _sendDecoded(
      'PATCH',
      _calendarWeekendByKeyUrl(key.parentId, key.date),
      body: _calendarWeekendUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.patchCalendarWeekend(data);
    }
    if (decoded == null) {
      final resolvedCalendarId = _resolveCalendarId(data.calendarId, data.calendarCode);
      return data.copyWith(
        calendarId: resolvedCalendarId,
        id: '$resolvedCalendarId|${_formatDate(data.validFrom!)}',
      );
    }
    return _calendarWeekendFromJson(_unwrap(decoded, const ['calendarWeekend']));
  }

  @override
  Future<CalendarWeekendFormData> putCalendarWeekend(
    CalendarWeekendFormData data,
  ) async {
    final key = _parseDateKey(data.id ?? '');
    if (key == null) {
      throw StateError(
        'CalendarWeekend id is empty. PUT requires /api/v1/calendar-weekends/{calendarId}/{validFrom}.',
      );
    }
    final decoded = await _sendDecoded(
      'PUT',
      _calendarWeekendByKeyUrl(key.parentId, key.date),
      body: _calendarWeekendUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.putCalendarWeekend(data);
    }
    if (decoded == null) {
      final resolvedCalendarId = _resolveCalendarId(data.calendarId, data.calendarCode);
      return data.copyWith(
        calendarId: resolvedCalendarId,
        id: '$resolvedCalendarId|${_formatDate(data.validFrom!)}',
      );
    }
    return _calendarWeekendFromJson(_unwrap(decoded, const ['calendarWeekend']));
  }

  @override
  Future<CalendarWeekendFormData> updateCalendarWeekend(
    CalendarWeekendFormData data,
  ) {
    return patchCalendarWeekend(data);
  }

  @override
  Future<void> deleteCalendarWeekend(String id) async {
    final key = _parseDateKey(id);
    if (key == null) {
      throw StateError('CalendarWeekend id is empty.');
    }
    await _sendDecoded(
      'DELETE',
      _calendarWeekendByKeyUrl(key.parentId, key.date),
      fallbackStatuses: const {404, 405},
    );
  }

  @override
  Future<List<CalendarExceptionFormData>> getCalendarExceptionList({
    required String calendarId,
  }) async {
    final normalizedId = calendarId.trim();
    if (normalizedId.isEmpty) {
      throw StateError('calendarId is required.');
    }
    final uri = Uri.parse(
      _calendarExceptionUrl,
    ).replace(queryParameters: {'calendarId': normalizedId});
    final decoded = await _getDecoded(uri.toString(), fallbackStatuses: const {
      404,
      405,
    });
    if (decoded == _fallbackMarker) {
      return _fallback.getCalendarExceptionList(calendarId: normalizedId);
    }
    return _parseCalendarExceptionList(decoded, calendarId: normalizedId);
  }

  @override
  Future<CalendarExceptionFormData?> getCalendarExceptionById(String id) async {
    final key = _parseDateKey(id);
    if (key == null) return null;
    final decoded = await _getDecoded(
      _calendarExceptionByKeyUrl(key.parentId, key.date),
      notFoundAsNull: true,
      fallbackStatuses: const {405},
    );
    if (decoded == null) return null;
    if (decoded == _fallbackMarker) {
      return _fallback.getCalendarExceptionById(id);
    }
    return _calendarExceptionFromJson(
      _unwrap(decoded, const ['calendarException']),
    );
  }

  @override
  Future<CalendarExceptionFormData> createCalendarException(
    CalendarExceptionFormData data,
  ) async {
    final calendarId = _resolveCalendarId(data.calendarId, data.calendarCode);
    if (calendarId.isEmpty) {
      throw StateError('CalendarException calendarId is required.');
    }
    final decoded = await _sendDecoded(
      'POST',
      _calendarExceptionUrl,
      body: _calendarExceptionCreateJson(data, calendarId),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.createCalendarException(
        data.copyWith(calendarId: calendarId),
      );
    }
    if (decoded == null) {
      return data.copyWith(
        calendarId: calendarId,
        id: '$calendarId|${_formatDate(data.exceptionDate!)}',
      );
    }
    return _calendarExceptionFromJson(
      _unwrap(decoded, const ['calendarException']),
    );
  }

  @override
  Future<CalendarExceptionFormData> patchCalendarException(
    CalendarExceptionFormData data,
  ) async {
    final key = _parseDateKey(data.id ?? '');
    if (key == null) {
      throw StateError(
        'CalendarException id is empty. PATCH requires /api/v1/calendar-exceptions/{calendarId}/{exceptionDate}.',
      );
    }
    final decoded = await _sendDecoded(
      'PATCH',
      _calendarExceptionByKeyUrl(key.parentId, key.date),
      body: _calendarExceptionUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.patchCalendarException(data);
    }
    if (decoded == null) {
      final resolvedCalendarId = _resolveCalendarId(data.calendarId, data.calendarCode);
      return data.copyWith(
        calendarId: resolvedCalendarId,
        id: '$resolvedCalendarId|${_formatDate(data.exceptionDate!)}',
      );
    }
    return _calendarExceptionFromJson(
      _unwrap(decoded, const ['calendarException']),
    );
  }

  @override
  Future<CalendarExceptionFormData> putCalendarException(
    CalendarExceptionFormData data,
  ) async {
    final key = _parseDateKey(data.id ?? '');
    if (key == null) {
      throw StateError(
        'CalendarException id is empty. PUT requires /api/v1/calendar-exceptions/{calendarId}/{exceptionDate}.',
      );
    }
    final decoded = await _sendDecoded(
      'PUT',
      _calendarExceptionByKeyUrl(key.parentId, key.date),
      body: _calendarExceptionUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.putCalendarException(data);
    }
    if (decoded == null) {
      final resolvedCalendarId = _resolveCalendarId(data.calendarId, data.calendarCode);
      return data.copyWith(
        calendarId: resolvedCalendarId,
        id: '$resolvedCalendarId|${_formatDate(data.exceptionDate!)}',
      );
    }
    return _calendarExceptionFromJson(
      _unwrap(decoded, const ['calendarException']),
    );
  }

  @override
  Future<CalendarExceptionFormData> updateCalendarException(
    CalendarExceptionFormData data,
  ) {
    return patchCalendarException(data);
  }

  @override
  Future<void> deleteCalendarException(String id) async {
    final key = _parseDateKey(id);
    if (key == null) {
      throw StateError('CalendarException id is empty.');
    }
    await _sendDecoded(
      'DELETE',
      _calendarExceptionByKeyUrl(key.parentId, key.date),
      fallbackStatuses: const {404, 405},
    );
  }

  @override
  Future<List<CalendarSetFormData>> getCalendarSetList() async {
    final decoded = await _getDecoded(_calendarSetUrl, fallbackStatuses: const {
      404,
      405,
    });
    if (decoded == _fallbackMarker) {
      return _fallback.getCalendarSetList();
    }
    final items = _parseCalendarSetList(decoded);
    _syncCalendarSets(items);
    return items;
  }

  @override
  Future<CalendarSetFormData?> getCalendarSetById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;
    final decoded = await _getDecoded(
      _calendarSetByIdUrl(normalizedId),
      notFoundAsNull: true,
      fallbackStatuses: const {405},
    );
    if (decoded == null) return null;
    if (decoded == _fallbackMarker) {
      return _fallback.getCalendarSetById(normalizedId);
    }
    final item = _calendarSetFromJson(_unwrap(decoded, const ['calendarSet']));
    _syncCalendarSet(item);
    return item;
  }

  @override
  Future<CalendarSetFormData> createCalendarSet(CalendarSetFormData data) async {
    final decoded = await _sendDecoded(
      'POST',
      _calendarSetUrl,
      body: _calendarSetCreateOrUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.createCalendarSet(data);
    }
    if (decoded == null) {
      _syncCalendarSet(data);
      return data;
    }
    final item = _calendarSetFromJson(_unwrap(decoded, const ['calendarSet']));
    _syncCalendarSet(item);
    return item;
  }

  @override
  Future<CalendarSetFormData> patchCalendarSet(CalendarSetFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('CalendarSet id is empty. PATCH requires /api/v1/calendar-sets/{id}.');
    }
    final decoded = await _sendDecoded(
      'PATCH',
      _calendarSetByIdUrl(id),
      body: _calendarSetCreateOrUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.patchCalendarSet(data);
    }
    if (decoded == null) {
      _syncCalendarSet(data);
      return data;
    }
    final item = _calendarSetFromJson(_unwrap(decoded, const ['calendarSet']));
    _syncCalendarSet(item);
    return item;
  }

  @override
  Future<CalendarSetFormData> putCalendarSet(CalendarSetFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('CalendarSet id is empty. PUT requires /api/v1/calendar-sets/{id}.');
    }
    final decoded = await _sendDecoded(
      'PUT',
      _calendarSetByIdUrl(id),
      body: _calendarSetCreateOrUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.putCalendarSet(data);
    }
    if (decoded == null) {
      _syncCalendarSet(data);
      return data;
    }
    final item = _calendarSetFromJson(_unwrap(decoded, const ['calendarSet']));
    _syncCalendarSet(item);
    return item;
  }

  @override
  Future<CalendarSetFormData> updateCalendarSet(CalendarSetFormData data) {
    return patchCalendarSet(data);
  }

  @override
  Future<void> deleteCalendarSet(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw StateError('CalendarSet id is empty.');
    }
    await _sendDecoded(
      'DELETE',
      _calendarSetByIdUrl(normalizedId),
      fallbackStatuses: const {404, 405},
    );
    _cachedCalendarSets.removeWhere((item) => item.id == normalizedId);
  }

  @override
  Future<List<CalendarSetMemberFormData>> getCalendarSetMemberList({
    required String calendarSetId,
  }) async {
    final normalizedId = calendarSetId.trim();
    if (normalizedId.isEmpty) {
      throw StateError('calendarSetId is required.');
    }
    final uri = Uri.parse(
      _calendarSetMemberUrl,
    ).replace(queryParameters: {'calendarSetId': normalizedId});
    final decoded = await _getDecoded(uri.toString(), fallbackStatuses: const {
      404,
      405,
    });
    if (decoded == _fallbackMarker) {
      return _fallback.getCalendarSetMemberList(calendarSetId: normalizedId);
    }
    return _parseCalendarSetMemberList(decoded, calendarSetId: normalizedId);
  }

  @override
  Future<CalendarSetMemberFormData?> getCalendarSetMemberById(String id) async {
    final key = _parseCompositeKey(id);
    if (key == null) return null;
    final decoded = await _getDecoded(
      _calendarSetMemberByKeyUrl(key.left, key.right),
      notFoundAsNull: true,
      fallbackStatuses: const {405},
    );
    if (decoded == null) return null;
    if (decoded == _fallbackMarker) {
      return _fallback.getCalendarSetMemberById(id);
    }
    return _calendarSetMemberFromJson(
      _unwrap(decoded, const ['calendarSetMember']),
    );
  }

  @override
  Future<CalendarSetMemberFormData> createCalendarSetMember(
    CalendarSetMemberFormData data,
  ) async {
    final calendarSetId = _resolveCalendarSetId(
      data.calendarSetId,
      data.calendarSetCode,
    );
    final calendarId = _resolveCalendarId(data.calendarId, data.calendarCode);
    if (calendarSetId.isEmpty || calendarId.isEmpty) {
      throw StateError('CalendarSetMember calendarSetId/calendarId is required.');
    }
    final decoded = await _sendDecoded(
      'POST',
      _calendarSetMemberUrl,
      body: _calendarSetMemberCreateJson(data, calendarSetId, calendarId),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.createCalendarSetMember(
        data.copyWith(calendarSetId: calendarSetId, calendarId: calendarId),
      );
    }
    if (decoded == null) {
      return data.copyWith(
        calendarSetId: calendarSetId,
        calendarId: calendarId,
        id: '$calendarSetId|$calendarId',
      );
    }
    return _calendarSetMemberFromJson(
      _unwrap(decoded, const ['calendarSetMember']),
    );
  }

  @override
  Future<CalendarSetMemberFormData> patchCalendarSetMember(
    CalendarSetMemberFormData data,
  ) async {
    final key = _parseCompositeKey(data.id ?? '');
    if (key == null) {
      throw StateError(
        'CalendarSetMember id is empty. PATCH requires /api/v1/calendar-set-members/{calendarSetId}/{calendarId}.',
      );
    }
    final decoded = await _sendDecoded(
      'PATCH',
      _calendarSetMemberByKeyUrl(key.left, key.right),
      body: _calendarSetMemberUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.patchCalendarSetMember(data);
    }
    if (decoded == null) return data;
    return _calendarSetMemberFromJson(
      _unwrap(decoded, const ['calendarSetMember']),
    );
  }

  @override
  Future<CalendarSetMemberFormData> putCalendarSetMember(
    CalendarSetMemberFormData data,
  ) async {
    final key = _parseCompositeKey(data.id ?? '');
    if (key == null) {
      throw StateError(
        'CalendarSetMember id is empty. PUT requires /api/v1/calendar-set-members/{calendarSetId}/{calendarId}.',
      );
    }
    final decoded = await _sendDecoded(
      'PUT',
      _calendarSetMemberByKeyUrl(key.left, key.right),
      body: _calendarSetMemberUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.putCalendarSetMember(data);
    }
    if (decoded == null) return data;
    return _calendarSetMemberFromJson(
      _unwrap(decoded, const ['calendarSetMember']),
    );
  }

  @override
  Future<CalendarSetMemberFormData> updateCalendarSetMember(
    CalendarSetMemberFormData data,
  ) {
    return patchCalendarSetMember(data);
  }

  @override
  Future<void> deleteCalendarSetMember(String id) async {
    final key = _parseCompositeKey(id);
    if (key == null) {
      throw StateError('CalendarSetMember id is empty.');
    }
    await _sendDecoded(
      'DELETE',
      _calendarSetMemberByKeyUrl(key.left, key.right),
      fallbackStatuses: const {404, 405},
    );
  }

  @override
  Future<List<WeekendProfileFormData>> getWeekendProfileList() async {
    final decoded = await _getDecoded(_weekendProfileUrl, fallbackStatuses: const {
      404,
      405,
    });
    if (decoded == _fallbackMarker) {
      return _fallback.getWeekendProfileList();
    }
    final items = _parseWeekendProfileList(decoded);
    _syncWeekendProfiles(items);
    return items;
  }

  @override
  Future<WeekendProfileFormData?> getWeekendProfileById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;
    final decoded = await _getDecoded(
      _weekendProfileByIdUrl(normalizedId),
      notFoundAsNull: true,
      fallbackStatuses: const {405},
    );
    if (decoded == null) return null;
    if (decoded == _fallbackMarker) {
      return _fallback.getWeekendProfileById(normalizedId);
    }
    final item = _weekendProfileFromJson(
      _unwrap(decoded, const ['weekendProfile']),
    );
    _syncWeekendProfile(item);
    return item;
  }

  @override
  Future<WeekendProfileFormData> createWeekendProfile(
    WeekendProfileFormData data,
  ) async {
    final decoded = await _sendDecoded(
      'POST',
      _weekendProfileUrl,
      body: _weekendProfileCreateOrUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.createWeekendProfile(data);
    }
    if (decoded == null) {
      _syncWeekendProfile(data);
      return data;
    }
    final item = _weekendProfileFromJson(
      _unwrap(decoded, const ['weekendProfile']),
    );
    _syncWeekendProfile(item);
    return item;
  }

  @override
  Future<WeekendProfileFormData> patchWeekendProfile(
    WeekendProfileFormData data,
  ) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError(
        'WeekendProfile id is empty. PATCH requires /api/v1/weekend-profiles/{id}.',
      );
    }
    final decoded = await _sendDecoded(
      'PATCH',
      _weekendProfileByIdUrl(id),
      body: _weekendProfileCreateOrUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.patchWeekendProfile(data);
    }
    if (decoded == null) {
      _syncWeekendProfile(data);
      return data;
    }
    final item = _weekendProfileFromJson(
      _unwrap(decoded, const ['weekendProfile']),
    );
    _syncWeekendProfile(item);
    return item;
  }

  @override
  Future<WeekendProfileFormData> putWeekendProfile(
    WeekendProfileFormData data,
  ) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError(
        'WeekendProfile id is empty. PUT requires /api/v1/weekend-profiles/{id}.',
      );
    }
    final decoded = await _sendDecoded(
      'PUT',
      _weekendProfileByIdUrl(id),
      body: _weekendProfileCreateOrUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.putWeekendProfile(data);
    }
    if (decoded == null) {
      _syncWeekendProfile(data);
      return data;
    }
    final item = _weekendProfileFromJson(
      _unwrap(decoded, const ['weekendProfile']),
    );
    _syncWeekendProfile(item);
    return item;
  }

  @override
  Future<WeekendProfileFormData> updateWeekendProfile(
    WeekendProfileFormData data,
  ) {
    return patchWeekendProfile(data);
  }

  @override
  Future<void> deleteWeekendProfile(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw StateError('WeekendProfile id is empty.');
    }
    await _sendDecoded(
      'DELETE',
      _weekendProfileByIdUrl(normalizedId),
      fallbackStatuses: const {404, 405},
    );
    _cachedWeekendProfiles.removeWhere((item) => item.id == normalizedId);
  }

  @override
  Future<List<WeekendProfileDayFormData>> getWeekendProfileDayList({
    required String weekendProfileId,
  }) async {
    final normalizedId = weekendProfileId.trim();
    if (normalizedId.isEmpty) {
      throw StateError('weekendProfileId is required.');
    }
    final uri = Uri.parse(
      _weekendProfileDayUrl,
    ).replace(queryParameters: {'weekendProfileId': normalizedId});
    final decoded = await _getDecoded(uri.toString(), fallbackStatuses: const {
      404,
      405,
    });
    if (decoded == _fallbackMarker) {
      return _fallback.getWeekendProfileDayList(weekendProfileId: normalizedId);
    }
    return _parseWeekendProfileDayList(decoded, weekendProfileId: normalizedId);
  }

  @override
  Future<WeekendProfileDayFormData?> getWeekendProfileDayById(
    String id,
  ) async {
    final key = _parseCompositeKey(id);
    if (key == null) return null;
    final weekday = int.tryParse(key.right);
    if (weekday == null) return null;
    final decoded = await _getDecoded(
      _weekendProfileDayByKeyUrl(key.left, weekday),
      notFoundAsNull: true,
      fallbackStatuses: const {405},
    );
    if (decoded == null) return null;
    if (decoded == _fallbackMarker) {
      return _fallback.getWeekendProfileDayById(id);
    }
    return _weekendProfileDayFromJson(
      _unwrap(decoded, const ['weekendProfileDay']),
    );
  }

  @override
  Future<WeekendProfileDayFormData> createWeekendProfileDay(
    WeekendProfileDayFormData data,
  ) async {
    final weekendProfileId = _resolveWeekendProfileId(
      data.weekendProfileId,
      data.weekendProfileCode,
    );
    if (weekendProfileId.isEmpty) {
      throw StateError('WeekendProfileDay weekendProfileId is required.');
    }
    final decoded = await _sendDecoded(
      'POST',
      _weekendProfileDayUrl,
      body: _weekendProfileDayCreateJson(data, weekendProfileId),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.createWeekendProfileDay(
        data.copyWith(weekendProfileId: weekendProfileId),
      );
    }
    if (decoded == null) {
      return data.copyWith(
        weekendProfileId: weekendProfileId,
        id: '$weekendProfileId|${data.isoWeekday}',
      );
    }
    return _weekendProfileDayFromJson(
      _unwrap(decoded, const ['weekendProfileDay']),
    );
  }

  @override
  Future<WeekendProfileDayFormData> patchWeekendProfileDay(
    WeekendProfileDayFormData data,
  ) async {
    final key = _parseCompositeKey(data.id ?? '');
    final weekday = key == null ? null : int.tryParse(key.right);
    if (key == null || weekday == null) {
      throw StateError(
        'WeekendProfileDay id is empty. PATCH requires /api/v1/weekend-profile-days/{weekendProfileId}/{isoWeekday}.',
      );
    }
    final decoded = await _sendDecoded(
      'PATCH',
      _weekendProfileDayByKeyUrl(key.left, weekday),
      body: _weekendProfileDayUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.patchWeekendProfileDay(data);
    }
    if (decoded == null) return data;
    return _weekendProfileDayFromJson(
      _unwrap(decoded, const ['weekendProfileDay']),
    );
  }

  @override
  Future<WeekendProfileDayFormData> putWeekendProfileDay(
    WeekendProfileDayFormData data,
  ) async {
    final key = _parseCompositeKey(data.id ?? '');
    final weekday = key == null ? null : int.tryParse(key.right);
    if (key == null || weekday == null) {
      throw StateError(
        'WeekendProfileDay id is empty. PUT requires /api/v1/weekend-profile-days/{weekendProfileId}/{isoWeekday}.',
      );
    }
    final decoded = await _sendDecoded(
      'PUT',
      _weekendProfileDayByKeyUrl(key.left, weekday),
      body: _weekendProfileDayUpdateJson(data),
      fallbackStatuses: const {404, 405},
    );
    if (decoded == _fallbackMarker) {
      return _fallback.putWeekendProfileDay(data);
    }
    if (decoded == null) return data;
    return _weekendProfileDayFromJson(
      _unwrap(decoded, const ['weekendProfileDay']),
    );
  }

  @override
  Future<WeekendProfileDayFormData> updateWeekendProfileDay(
    WeekendProfileDayFormData data,
  ) {
    return patchWeekendProfileDay(data);
  }

  @override
  Future<void> deleteWeekendProfileDay(String id) async {
    final key = _parseCompositeKey(id);
    final weekday = key == null ? null : int.tryParse(key.right);
    if (key == null || weekday == null) {
      throw StateError('WeekendProfileDay id is empty.');
    }
    await _sendDecoded(
      'DELETE',
      _weekendProfileDayByKeyUrl(key.left, weekday),
      fallbackStatuses: const {404, 405},
    );
  }

  CalendarFormData _calendarFromJson(Map<String, dynamic> json) {
    final countryJson = _readMap(json, const ['country', 'Country']);
    final typeText = _firstNonEmpty([
      _readString(json, const ['calendarType', 'CalendarType']),
      _readString(json, const ['type', 'Type']),
    ]);
    return CalendarFormData(
      id: _readString(json, const ['id', 'calendarId', 'CalendarId']),
      calendarCode: _readString(json, const ['calendarCode', 'CalendarCode']),
      name: _firstNonEmpty([
        _readString(json, const ['name', 'Name']),
        _readString(json, const ['calendarName', 'CalendarName']),
      ]),
      type: CalendarType.fromApiValue(typeText) ?? CalendarType.countryPublic,
      countryId: _firstNonEmpty([
        _readString(json, const ['countryId', 'CountryId']),
        if (countryJson != null)
          _readString(countryJson, const ['id', 'countryId', 'country_id']),
      ]),
      countryIso2: _firstNonEmpty([
        _readString(json, const ['countryIso2', 'CountryIso2']),
        if (countryJson != null)
          _readString(countryJson, const ['countryIso2', 'country_iso2', 'iso2']),
      ]),
      countryIso3: _firstNonEmpty([
        _readString(json, const ['countryIso3', 'CountryIso3']),
        if (countryJson != null)
          _readString(countryJson, const ['countryIso3', 'country_iso3', 'iso3']),
      ]),
      countryName: _firstNonEmpty([
        _readString(json, const ['countryName', 'CountryName']),
        if (countryJson != null) _readString(countryJson, const ['name']),
      ]),
      regionCode: _readString(json, const ['regionCode', 'RegionCode']),
      timezone: _firstNonEmpty([
        _readString(json, const ['timezone', 'Timezone']),
        if (countryJson != null) _readString(countryJson, const ['timezone']),
      ]),
      active: _readBool(json, const ['active', 'Active'], fallback: true),
    );
  }

  CalendarWeekendFormData _calendarWeekendFromJson(Map<String, dynamic> json) {
    final calendarJson = _readMap(json, const ['calendar', 'Calendar']);
    final profileJson = _readMap(
      json,
      const ['weekendProfile', 'WeekendProfile'],
    );
    final calendarId = _firstNonEmpty([
      _readString(json, const ['calendarId', 'CalendarId']),
      if (calendarJson != null)
        _readString(calendarJson, const ['id', 'calendarId', 'calendar_id']),
    ]);
    final calendar = _cachedCalendars
        .where((item) => item.id == calendarId)
        .firstOrNull;
    final validFrom = _readDate(json, const ['validFrom', 'ValidFrom']);
    final weekendProfileId = _firstNonEmpty([
      _readString(json, const ['weekendProfileId', 'WeekendProfileId']),
      if (profileJson != null)
        _readString(profileJson, const ['id', 'weekendProfileId']),
    ]);
    final weekendProfile = _cachedWeekendProfiles
        .where((item) => item.id == weekendProfileId)
        .firstOrNull;
    return CalendarWeekendFormData(
      id: _firstNonEmpty([
        _readString(json, const ['id', 'Id']),
        if (calendarId.isNotEmpty && validFrom != null)
          '$calendarId|${_formatDate(validFrom)}',
      ]),
      calendarId: calendarId,
      calendarCode: _firstNonEmpty([
        _readString(json, const ['calendarCode', 'CalendarCode']),
        if (calendarJson != null)
          _readString(calendarJson, const ['calendarCode', 'calendar_code']),
        if (calendar != null) calendar.calendarCode,
      ]),
      calendarName: _firstNonEmpty([
        _readString(json, const ['calendarName', 'CalendarName']),
        if (calendarJson != null)
          _readString(calendarJson, const ['name', 'calendarName', 'calendarName']),
        if (calendar != null) calendar.name,
      ]),
      validFrom: validFrom,
      validTo: _readDate(json, const ['validTo', 'ValidTo']),
      weekendProfileId: weekendProfileId,
      weekendProfileCode: _firstNonEmpty([
        _readString(json, const ['weekendProfileCode', 'WeekendProfileCode']),
        _readString(json, const ['profileCode', 'ProfileCode']),
        if (profileJson != null)
          _readString(profileJson, const ['profileCode', 'weekendProfileCode', 'code']),
        if (weekendProfile != null) weekendProfile.weekendProfileCode,
      ]),
      weekendProfileName: _firstNonEmpty([
        _readString(json, const ['weekendProfileName', 'WeekendProfileName']),
        _readString(json, const ['profileCode', 'ProfileCode']),
        if (profileJson != null)
          _readString(profileJson, const ['name', 'profileCode', 'weekendProfileName']),
        if (weekendProfile != null) weekendProfile.name,
      ]),
    );
  }

  CalendarExceptionFormData _calendarExceptionFromJson(
    Map<String, dynamic> json,
  ) {
    final calendarJson = _readMap(json, const ['calendar', 'Calendar']);
    final calendarId = _firstNonEmpty([
      _readString(json, const ['calendarId', 'CalendarId']),
      if (calendarJson != null)
        _readString(calendarJson, const ['id', 'calendarId', 'calendar_id']),
    ]);
    final calendar = _cachedCalendars
        .where((item) => item.id == calendarId)
        .firstOrNull;
    final exceptionDate = _readDate(
      json,
      const ['exceptionDate', 'ExceptionDate'],
    );
    return CalendarExceptionFormData(
      id: _firstNonEmpty([
        _readString(json, const ['id', 'Id']),
        if (calendarId.isNotEmpty && exceptionDate != null)
          '$calendarId|${_formatDate(exceptionDate)}',
      ]),
      calendarId: calendarId,
      calendarCode: _firstNonEmpty([
        _readString(json, const ['calendarCode', 'CalendarCode']),
        if (calendarJson != null)
          _readString(calendarJson, const ['calendarCode', 'calendar_code']),
        if (calendar != null) calendar.calendarCode,
      ]),
      calendarName: _firstNonEmpty([
        _readString(json, const ['calendarName', 'CalendarName']),
        if (calendarJson != null)
          _readString(calendarJson, const ['name', 'calendarName']),
        if (calendar != null) calendar.name,
      ]),
      exceptionDate: exceptionDate,
      businessDay: _readBool(
        json,
        const ['businessDay', 'BusinessDay'],
        fallback: false,
      ),
      exceptionType:
          CalendarExceptionType.fromApiValue(
            _firstNonEmpty([
              _readString(json, const ['exceptionType', 'ExceptionType']),
              _readString(json, const ['type', 'Type']),
            ]),
          ) ??
          CalendarExceptionType.holiday,
      name: _firstNonEmpty([
        _readString(json, const ['exceptionName', 'ExceptionName']),
        _readString(json, const ['name', 'Name']),
      ]),
      observedOf: _readDate(json, const ['observedOf', 'ObservedOf']),
      source: _readString(json, const ['source', 'Source']),
      createdAt: _readDate(
        json,
        const ['createdAt', 'CreatedAt', 'createDate', 'CreateDate'],
      ),
    );
  }

  CalendarSetFormData _calendarSetFromJson(Map<String, dynamic> json) {
    return CalendarSetFormData(
      id: _readString(json, const ['id', 'calendarSetId', 'CalendarSetId']),
      setCode: _firstNonEmpty([
        _readString(json, const ['setCode', 'SetCode']),
        _readString(json, const ['calendarSetCode', 'CalendarSetCode']),
      ]),
      joinRule:
          CalendarJoinRule.fromApiValue(
            _firstNonEmpty([
              _readString(json, const ['joinRule', 'JoinRule']),
              _readString(json, const ['rule', 'Rule']),
            ]),
          ) ??
          CalendarJoinRule.joinHolidays,
      description: _readString(json, const ['description', 'Description']),
    );
  }

  CalendarSetMemberFormData _calendarSetMemberFromJson(
    Map<String, dynamic> json,
  ) {
    final setJson = _readMap(json, const ['calendarSet', 'CalendarSet']);
    final calendarJson = _readMap(json, const ['calendar', 'Calendar']);
    final setId = _firstNonEmpty([
      _readString(json, const ['calendarSetId', 'CalendarSetId']),
      if (setJson != null)
        _readString(setJson, const ['id', 'calendarSetId', 'calendar_set_id']),
    ]);
    final calendarSet = _cachedCalendarSets
        .where((item) => item.id == setId)
        .firstOrNull;
    final calendarId = _firstNonEmpty([
      _readString(json, const ['calendarId', 'CalendarId']),
      if (calendarJson != null)
        _readString(calendarJson, const ['id', 'calendarId', 'calendar_id']),
    ]);
    final calendar = _cachedCalendars
        .where((item) => item.id == calendarId)
        .firstOrNull;
    return CalendarSetMemberFormData(
      id: _firstNonEmpty([
        _readString(json, const ['id', 'Id']),
        if (setId.isNotEmpty && calendarId.isNotEmpty) '$setId|$calendarId',
      ]),
      calendarSetId: setId,
      calendarSetCode: _firstNonEmpty([
        _readString(json, const ['calendarSetCode', 'CalendarSetCode']),
        if (setJson != null)
          _readString(setJson, const ['setCode', 'calendarSetCode']),
        if (calendarSet != null) calendarSet.setCode,
      ]),
      calendarId: calendarId,
      calendarCode: _firstNonEmpty([
        _readString(json, const ['calendarCode', 'CalendarCode']),
        if (calendarJson != null)
          _readString(calendarJson, const ['calendarCode', 'calendar_code']),
        if (calendar != null) calendar.calendarCode,
      ]),
      calendarName: _firstNonEmpty([
        _readString(json, const ['calendarName', 'CalendarName']),
        if (calendarJson != null)
          _readString(calendarJson, const ['name', 'calendarName']),
        if (calendar != null) calendar.name,
      ]),
      seqNo: _readInt(json, const ['seqNo', 'SeqNo'], fallback: 1),
    );
  }

  WeekendProfileFormData _weekendProfileFromJson(Map<String, dynamic> json) {
    final code = _firstNonEmpty([
      _readString(json, const ['profileCode', 'ProfileCode']),
      _readString(json, const ['weekendProfileCode', 'WeekendProfileCode']),
      _readString(json, const ['code', 'Code']),
    ]);
    return WeekendProfileFormData(
      id: _readString(
        json,
        const ['id', 'weekendProfileId', 'WeekendProfileId'],
      ),
      weekendProfileCode: code,
      name: _firstNonEmpty([
        _readString(json, const ['name', 'Name']),
        code,
      ]),
      description: _readString(json, const ['description', 'Description']),
    );
  }

  WeekendProfileDayFormData _weekendProfileDayFromJson(
    Map<String, dynamic> json,
  ) {
    final profileJson = _readMap(json, const ['weekendProfile', 'WeekendProfile']);
    final profileId = _firstNonEmpty([
      _readString(json, const ['weekendProfileId', 'WeekendProfileId']),
      if (profileJson != null)
        _readString(profileJson, const ['id', 'weekendProfileId']),
    ]);
    final profile = _cachedWeekendProfiles
        .where((item) => item.id == profileId)
        .firstOrNull;
    final isoWeekday = _readInt(
      json,
      const ['isoWeekday', 'IsoWeekday'],
      fallback: 1,
    );
    return WeekendProfileDayFormData(
      id: _firstNonEmpty([
        _readString(json, const ['id', 'Id']),
        if (profileId.isNotEmpty) '$profileId|$isoWeekday',
      ]),
      weekendProfileId: profileId,
      weekendProfileCode: _firstNonEmpty([
        _readString(json, const ['weekendProfileCode', 'WeekendProfileCode']),
        _readString(json, const ['profileCode', 'ProfileCode']),
        if (profileJson != null)
          _readString(profileJson, const ['profileCode', 'weekendProfileCode', 'code']),
        if (profile != null) profile.weekendProfileCode,
      ]),
      isoWeekday: isoWeekday,
      weekend: _readBool(
        json,
        const ['weekend', 'Weekend', 'enabled', 'Enabled', 'active', 'Active'],
        fallback: true,
      ),
    );
  }

  List<CalendarFormData> _parseCalendarList(dynamic decoded) {
    return _parseList(decoded, _calendarFromJson, const [
      'items',
      'calendars',
      'calendarList',
      'content',
      'data',
    ]);
  }

  List<CalendarWeekendFormData> _parseCalendarWeekendList(
    dynamic decoded, {
    required String calendarId,
  }) {
    final calendar = _cachedCalendars
        .where((item) => item.id == calendarId)
        .firstOrNull;
    return _parseList(
      decoded,
      (json) => _calendarWeekendFromJson({
        ...json,
        if (calendar != null && !json.containsKey('calendarId'))
          'calendarId': calendar.id,
        if (calendar != null && !json.containsKey('calendarCode'))
          'calendarCode': calendar.calendarCode,
        if (calendar != null && !json.containsKey('calendarName'))
          'calendarName': calendar.name,
      }),
      const ['items', 'calendarWeekends', 'weekends', 'data', 'content'],
    );
  }

  List<CalendarExceptionFormData> _parseCalendarExceptionList(
    dynamic decoded, {
    required String calendarId,
  }) {
    final calendar = _cachedCalendars
        .where((item) => item.id == calendarId)
        .firstOrNull;
    return _parseList(
      decoded,
      (json) => _calendarExceptionFromJson({
        ...json,
        if (calendar != null && !json.containsKey('calendarId'))
          'calendarId': calendar.id,
        if (calendar != null && !json.containsKey('calendarCode'))
          'calendarCode': calendar.calendarCode,
        if (calendar != null && !json.containsKey('calendarName'))
          'calendarName': calendar.name,
      }),
      const ['items', 'calendarExceptions', 'exceptions', 'data', 'content'],
    );
  }

  List<CalendarSetFormData> _parseCalendarSetList(dynamic decoded) {
    return _parseList(decoded, _calendarSetFromJson, const [
      'items',
      'calendarSets',
      'sets',
      'data',
      'content',
    ]);
  }

  List<CalendarSetMemberFormData> _parseCalendarSetMemberList(
    dynamic decoded, {
    required String calendarSetId,
  }) {
    final calendarSet = _cachedCalendarSets
        .where((item) => item.id == calendarSetId)
        .firstOrNull;
    return _parseList(
      decoded,
      (json) => _calendarSetMemberFromJson({
        ...json,
        if (calendarSet != null && !json.containsKey('calendarSetId'))
          'calendarSetId': calendarSet.id,
        if (calendarSet != null && !json.containsKey('calendarSetCode'))
          'calendarSetCode': calendarSet.setCode,
      }),
      const ['items', 'calendarSetMembers', 'members', 'data', 'content'],
    );
  }

  List<WeekendProfileFormData> _parseWeekendProfileList(dynamic decoded) {
    return _parseList(decoded, _weekendProfileFromJson, const [
      'items',
      'weekendProfiles',
      'profiles',
      'data',
      'content',
    ]);
  }

  List<WeekendProfileDayFormData> _parseWeekendProfileDayList(
    dynamic decoded, {
    required String weekendProfileId,
  }) {
    final profile = _cachedWeekendProfiles
        .where((item) => item.id == weekendProfileId)
        .firstOrNull;
    return _parseList(
      decoded,
      (json) => _weekendProfileDayFromJson({
        ...json,
        if (profile != null && !json.containsKey('weekendProfileId'))
          'weekendProfileId': profile.id,
        if (profile != null && !json.containsKey('weekendProfileCode'))
          'weekendProfileCode': profile.weekendProfileCode,
      }),
      const ['items', 'weekendProfileDays', 'days', 'data', 'content'],
    );
  }

  List<T> _parseList<T>(
    dynamic decoded,
    T Function(Map<String, dynamic>) parser,
    List<String> listKeys,
  ) {
    if (decoded is List<dynamic>) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(parser)
          .toList(growable: false);
    }
    if (decoded is! Map<String, dynamic>) return const [];
    final direct = _extractList(decoded, listKeys);
    if (direct != null) {
      return direct.whereType<Map<String, dynamic>>().map(parser).toList(
        growable: false,
      );
    }
    final nestedData = decoded['data'];
    if (nestedData is Map<String, dynamic>) {
      final nested = _extractList(nestedData, listKeys);
      if (nested != null) {
        return nested
            .whereType<Map<String, dynamic>>()
            .map(parser)
            .toList(growable: false);
      }
    }
    return decoded.isNotEmpty ? [parser(_unwrap(decoded, const []))] : const [];
  }

  static List<dynamic>? _extractList(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is List<dynamic>) return value;
    }
    return null;
  }

  Map<String, dynamic> _calendarCreateOrUpdateJson(CalendarFormData data) {
    final countryId = data.countryId.trim();
    return {
      'calendarCode': data.calendarCode.trim(),
      'calendarName': data.name.trim(),
      'calendarType': data.type.apiValue,
      if (countryId.isNotEmpty) 'countryId': _serializeId(countryId),
      'regionCode': data.regionCode.trim(),
      'timezone': data.timezone.trim(),
      'active': data.active,
    };
  }

  Map<String, dynamic> _calendarWeekendCreateJson(
    CalendarWeekendFormData data,
    String calendarId,
  ) {
    final weekendProfileId = _resolveWeekendProfileId(
      data.weekendProfileId,
      data.weekendProfileCode,
    );
    return {
      'calendarId': _serializeId(calendarId),
      'validFrom': _formatDate(data.validFrom!),
      if (data.validTo != null) 'validTo': _formatDate(data.validTo!),
      if (weekendProfileId.isNotEmpty) 'weekendProfileId': _serializeId(weekendProfileId),
    };
  }

  Map<String, dynamic> _calendarWeekendUpdateJson(CalendarWeekendFormData data) {
    final weekendProfileId = _resolveWeekendProfileId(
      data.weekendProfileId,
      data.weekendProfileCode,
    );
    return {
      'validTo': data.validTo == null ? null : _formatDate(data.validTo!),
      if (weekendProfileId.isNotEmpty) 'weekendProfileId': _serializeId(weekendProfileId),
    };
  }

  Map<String, dynamic> _calendarExceptionCreateJson(
    CalendarExceptionFormData data,
    String calendarId,
  ) {
    return {
      'calendarId': _serializeId(calendarId),
      'exceptionDate': _formatDate(data.exceptionDate!),
      'businessDay': data.businessDay,
      'exceptionType': data.exceptionType.apiValue,
      'exceptionName': data.name.trim(),
      'observedOf': data.observedOf == null ? null : _formatDate(data.observedOf!),
      'source': data.source.trim(),
    };
  }

  Map<String, dynamic> _calendarExceptionUpdateJson(
    CalendarExceptionFormData data,
  ) {
    return {
      'businessDay': data.businessDay,
      'exceptionType': data.exceptionType.apiValue,
      'exceptionName': data.name.trim(),
      'observedOf': data.observedOf == null ? null : _formatDate(data.observedOf!),
      'source': data.source.trim(),
    };
  }

  Map<String, dynamic> _calendarSetCreateOrUpdateJson(CalendarSetFormData data) {
    return {
      'setCode': data.setCode.trim(),
      'joinRule': data.joinRule.apiValue,
      'description': data.description.trim(),
    };
  }

  Map<String, dynamic> _calendarSetMemberCreateJson(
    CalendarSetMemberFormData data,
    String calendarSetId,
    String calendarId,
  ) {
    return {
      'calendarSetId': _serializeId(calendarSetId),
      'calendarId': _serializeId(calendarId),
      'seqNo': data.seqNo,
    };
  }

  Map<String, dynamic> _calendarSetMemberUpdateJson(
    CalendarSetMemberFormData data,
  ) {
    return {'seqNo': data.seqNo};
  }

  Map<String, dynamic> _weekendProfileCreateOrUpdateJson(
    WeekendProfileFormData data,
  ) {
    return {
      'profileCode': data.weekendProfileCode.trim(),
      'description': data.description.trim(),
    };
  }

  Map<String, dynamic> _weekendProfileDayCreateJson(
    WeekendProfileDayFormData data,
    String weekendProfileId,
  ) {
    return {
      'weekendProfileId': _serializeId(weekendProfileId),
      'isoWeekday': data.isoWeekday,
      'weekend': data.weekend,
    };
  }

  Map<String, dynamic> _weekendProfileDayUpdateJson(
    WeekendProfileDayFormData data,
  ) {
    return {'weekend': data.weekend};
  }

  String _resolveCalendarId(String calendarId, String calendarCode) {
    final direct = calendarId.trim();
    if (direct.isNotEmpty) return direct;
    final code = calendarCode.trim();
    if (code.isEmpty) return '';
    return _cachedCalendars
            .where((item) => item.calendarCode == code)
            .firstOrNull
            ?.id ??
        '';
  }

  String _resolveCalendarSetId(String calendarSetId, String calendarSetCode) {
    final direct = calendarSetId.trim();
    if (direct.isNotEmpty) return direct;
    final code = calendarSetCode.trim();
    if (code.isEmpty) return '';
    return _cachedCalendarSets
            .where((item) => item.setCode == code)
            .firstOrNull
            ?.id ??
        '';
  }

  String _resolveWeekendProfileId(
    String weekendProfileId,
    String weekendProfileCode,
  ) {
    final direct = weekendProfileId.trim();
    if (direct.isNotEmpty) return direct;
    final code = weekendProfileCode.trim();
    if (code.isEmpty) return '';
    return _cachedWeekendProfiles
            .where((item) => item.weekendProfileCode == code)
            .firstOrNull
            ?.id ??
        '';
  }

  Future<dynamic> _getDecoded(
    String url, {
    bool notFoundAsNull = false,
    Set<int> fallbackStatuses = const {},
  }) async {
    _debug('GET', url);
    final response = await http.get(Uri.parse(url)).timeout(timeout);
    _debugStatus(response.statusCode);
    if (notFoundAsNull && response.statusCode == 404) return null;
    if (fallbackStatuses.contains(response.statusCode)) return _fallbackMarker;
    _checkResponse(response);
    return _decodeBody(response.body);
  }

  Future<dynamic> _sendDecoded(
    String method,
    String url, {
    Map<String, dynamic>? body,
    Set<int> fallbackStatuses = const {},
  }) async {
    _debug(method, url);
    final requestBody = body == null ? null : jsonEncode(body);
    late final http.Response response;
    final uri = Uri.parse(url);
    switch (method) {
      case 'POST':
        response = await http
            .post(uri, headers: _jsonHeaders, body: requestBody)
            .timeout(timeout);
        break;
      case 'PATCH':
        response = await http
            .patch(uri, headers: _jsonHeaders, body: requestBody)
            .timeout(timeout);
        break;
      case 'PUT':
        response = await http
            .put(uri, headers: _jsonHeaders, body: requestBody)
            .timeout(timeout);
        break;
      case 'DELETE':
        response = await http.delete(uri).timeout(timeout);
        break;
      default:
        throw StateError('Unsupported method: $method');
    }
    _debugStatus(response.statusCode);
    if (fallbackStatuses.contains(response.statusCode)) return _fallbackMarker;
    _checkResponse(response);
    return _decodeBody(response.body);
  }

  static dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) return null;
    return jsonDecode(body);
  }

  void _syncCalendar(CalendarFormData item) {
    final id = (item.id ?? '').trim();
    if (id.isEmpty) return;
    _cachedCalendars.removeWhere((existing) => existing.id == id);
    _cachedCalendars.add(item);
    _fallback.replaceCalendars(_cachedCalendars);
  }

  void _syncCalendars(Iterable<CalendarFormData> items) {
    _cachedCalendars
      ..clear()
      ..addAll(items);
    _fallback.replaceCalendars(_cachedCalendars);
  }

  void _syncCalendarSet(CalendarSetFormData item) {
    final id = (item.id ?? '').trim();
    if (id.isEmpty) return;
    _cachedCalendarSets.removeWhere((existing) => existing.id == id);
    _cachedCalendarSets.add(item);
  }

  void _syncCalendarSets(Iterable<CalendarSetFormData> items) {
    _cachedCalendarSets
      ..clear()
      ..addAll(items);
  }

  void _syncWeekendProfile(WeekendProfileFormData item) {
    final id = (item.id ?? '').trim();
    if (id.isEmpty) return;
    _cachedWeekendProfiles.removeWhere((existing) => existing.id == id);
    _cachedWeekendProfiles.add(item);
  }

  void _syncWeekendProfiles(Iterable<WeekendProfileFormData> items) {
    _cachedWeekendProfiles
      ..clear()
      ..addAll(items);
  }

  static Map<String, dynamic> _unwrap(
    dynamic decoded,
    List<String> preferredKeys,
  ) {
    if (decoded is Map<String, dynamic>) {
      for (final key in preferredKeys) {
        final value = decoded[key];
        if (value is Map<String, dynamic>) return value;
      }
      final data = decoded['data'];
      if (data is Map<String, dynamic>) return data;
      return decoded;
    }
    return <String, dynamic>{};
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is num) return value.toString();
    }
    return '';
  }

  static Map<String, dynamic>? _readMap(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map<String, dynamic>) return value;
    }
    return null;
  }

  static bool _readBool(
    Map<String, dynamic> json,
    List<String> keys, {
    required bool fallback,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1' || normalized == 'y') {
          return true;
        }
        if (normalized == 'false' || normalized == '0' || normalized == 'n') {
          return false;
        }
      }
    }
    return fallback;
  }

  static int _readInt(
    Map<String, dynamic> json,
    List<String> keys, {
    required int fallback,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  static DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
    final raw = _readString(json, keys);
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  static dynamic _serializeId(String value) => int.tryParse(value) ?? value;

  _DateKey? _parseDateKey(String id) {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;
    final parts = normalized.split('|');
    if (parts.length != 2) return null;
    final date = DateTime.tryParse(parts[1]);
    if (date == null) return null;
    return _DateKey(parts[0], date);
  }

  _CompositeKey? _parseCompositeKey(String id) {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;
    final parts = normalized.split('|');
    if (parts.length != 2) return null;
    return _CompositeKey(parts[0], parts[1]);
  }

  void _debug(String method, String url) {
    debugPrint('[CalendarApi] $method $url');
  }

  void _debugStatus(int statusCode) {
    debugPrint('[CalendarApi] <-- $statusCode');
  }

  static void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw CalendarApiException(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  static const _jsonHeaders = {'Content-Type': 'application/json'};
  static const Object _fallbackMarker = Object();

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class CalendarApiException implements Exception {
  CalendarApiException({required this.statusCode, this.body});

  final int statusCode;
  final String? body;

  @override
  String toString() => 'CalendarApiException: $statusCode ${body ?? ''}';
}

class _DateKey {
  const _DateKey(this.parentId, this.date);

  final String parentId;
  final DateTime date;
}

class _CompositeKey {
  const _CompositeKey(this.left, this.right);

  final String left;
  final String right;
}
