import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/calendar_enums.dart';
import '../models/calendar_exception_form_data.dart';
import '../models/calendar_form_data.dart';
import '../models/calendar_set_form_data.dart';
import '../models/calendar_set_member_form_data.dart';
import '../models/calendar_weekend_form_data.dart';
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

  String get _normalizedBaseUrl => baseUrl.replaceAll(RegExp(r'/+$'), '');
  String get _calendarUrl => '$_normalizedBaseUrl/api/v1/calendars';
  String _calendarByIdUrl(String id) => '$_calendarUrl/$id';

  @override
  Future<List<CalendarFormData>> getCalendarList({bool? active}) async {
    final uri = Uri.parse(
      _calendarUrl,
    ).replace(queryParameters: {if (active != null) 'active': '$active'});
    _debug('GET', uri.toString());
    final response = await http.get(uri).timeout(timeout);
    _debugStatus(response.statusCode);
    if (response.statusCode == 404 || response.statusCode == 405) {
      return _fallback.getCalendarList(active: active);
    }
    _checkResponse(response);

    if (response.body.trim().isEmpty) return const [];
    final decoded = jsonDecode(response.body);
    final items = _parseList(decoded);
    _syncFallbackCalendars(items);
    return items;
  }

  @override
  Future<CalendarFormData?> getCalendarById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;
    final url = _calendarByIdUrl(normalizedId);
    _debug('GET', url);
    final response = await http.get(Uri.parse(url)).timeout(timeout);
    _debugStatus(response.statusCode);
    if (response.statusCode == 404) return null;
    _checkResponse(response);

    if (response.body.trim().isEmpty) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final item = _fromJson(_unwrap(decoded));
      _syncFallbackUpsert(item);
      return item;
    }
    return null;
  }

  @override
  Future<CalendarFormData> createCalendar(CalendarFormData data) async {
    _debug('POST', _calendarUrl);
    final response = await http
        .post(
          Uri.parse(_calendarUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_toJson(data)),
        )
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);

    if (response.body.trim().isEmpty) {
      _syncFallbackUpsert(data);
      return data;
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final parsed = _fromJson(_unwrap(decoded));
      _syncFallbackUpsert(parsed);
      return parsed;
    }
    return data;
  }

  @override
  Future<CalendarFormData> patchCalendar(CalendarFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError(
        'Calendar id is empty. PATCH requires /api/v1/calendars/{id}.',
      );
    }

    final uri = Uri.parse(_calendarByIdUrl(id));
    final body = jsonEncode(_toJson(data));

    _debug('PATCH', uri.toString());
    final response = await http
        .patch(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);

    if (response.body.trim().isEmpty) {
      _syncFallbackUpsert(data);
      return data;
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final parsed = _fromJson(_unwrap(decoded));
      _syncFallbackUpsert(parsed);
      return parsed;
    }
    return data;
  }

  @override
  Future<CalendarFormData> putCalendar(CalendarFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError(
        'Calendar id is empty. PUT requires /api/v1/calendars/{id}.',
      );
    }

    final uri = Uri.parse(_calendarByIdUrl(id));
    final body = jsonEncode(_toJson(data));

    _debug('PUT', uri.toString());
    final response = await http
        .put(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);

    if (response.body.trim().isEmpty) {
      _syncFallbackUpsert(data);
      return data;
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final parsed = _fromJson(_unwrap(decoded));
      _syncFallbackUpsert(parsed);
      return parsed;
    }
    return data;
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
    final url = _calendarByIdUrl(normalizedId);
    _debug('DELETE', url);
    final response = await http.delete(Uri.parse(url)).timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);
    _cachedCalendars.removeWhere((item) => item.id == normalizedId);
    _fallback.replaceCalendars(_cachedCalendars);
  }

  @override
  Future<List<CalendarWeekendFormData>> getCalendarWeekendList() {
    return _fallback.getCalendarWeekendList();
  }

  @override
  Future<CalendarWeekendFormData?> getCalendarWeekendById(String id) {
    return _fallback.getCalendarWeekendById(id);
  }

  @override
  Future<CalendarWeekendFormData> createCalendarWeekend(
    CalendarWeekendFormData data,
  ) {
    return _fallback.createCalendarWeekend(data);
  }

  @override
  Future<CalendarWeekendFormData> updateCalendarWeekend(
    CalendarWeekendFormData data,
  ) {
    return _fallback.updateCalendarWeekend(data);
  }

  @override
  Future<void> deleteCalendarWeekend(String id) {
    return _fallback.deleteCalendarWeekend(id);
  }

  @override
  Future<List<CalendarExceptionFormData>> getCalendarExceptionList() {
    return _fallback.getCalendarExceptionList();
  }

  @override
  Future<CalendarExceptionFormData?> getCalendarExceptionById(String id) {
    return _fallback.getCalendarExceptionById(id);
  }

  @override
  Future<CalendarExceptionFormData> createCalendarException(
    CalendarExceptionFormData data,
  ) {
    return _fallback.createCalendarException(data);
  }

  @override
  Future<CalendarExceptionFormData> updateCalendarException(
    CalendarExceptionFormData data,
  ) {
    return _fallback.updateCalendarException(data);
  }

  @override
  Future<void> deleteCalendarException(String id) {
    return _fallback.deleteCalendarException(id);
  }

  @override
  Future<List<CalendarSetFormData>> getCalendarSetList() {
    return _fallback.getCalendarSetList();
  }

  @override
  Future<CalendarSetFormData?> getCalendarSetById(String id) {
    return _fallback.getCalendarSetById(id);
  }

  @override
  Future<CalendarSetFormData> createCalendarSet(CalendarSetFormData data) {
    return _fallback.createCalendarSet(data);
  }

  @override
  Future<CalendarSetFormData> updateCalendarSet(CalendarSetFormData data) {
    return _fallback.updateCalendarSet(data);
  }

  @override
  Future<void> deleteCalendarSet(String id) {
    return _fallback.deleteCalendarSet(id);
  }

  @override
  Future<List<CalendarSetMemberFormData>> getCalendarSetMemberList() {
    return _fallback.getCalendarSetMemberList();
  }

  @override
  Future<CalendarSetMemberFormData?> getCalendarSetMemberById(String id) {
    return _fallback.getCalendarSetMemberById(id);
  }

  @override
  Future<CalendarSetMemberFormData> createCalendarSetMember(
    CalendarSetMemberFormData data,
  ) {
    return _fallback.createCalendarSetMember(data);
  }

  @override
  Future<CalendarSetMemberFormData> updateCalendarSetMember(
    CalendarSetMemberFormData data,
  ) {
    return _fallback.updateCalendarSetMember(data);
  }

  @override
  Future<void> deleteCalendarSetMember(String id) {
    return _fallback.deleteCalendarSetMember(id);
  }

  CalendarFormData _fromJson(Map<String, dynamic> json) {
    final countryJson = _readMap(json, const ['country', 'Country']);
    final typeText = _firstNonEmpty([
      _readString(json, const ['type', 'Type']),
      _readString(json, const ['calendarType', 'CalendarType']),
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
          _readString(countryJson, const [
            'countryIso2',
            'country_iso2',
            'iso2',
          ]),
      ]),
      countryIso3: _firstNonEmpty([
        _readString(json, const ['countryIso3', 'CountryIso3']),
        if (countryJson != null)
          _readString(countryJson, const [
            'countryIso3',
            'country_iso3',
            'iso3',
          ]),
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

  Map<String, dynamic> _toJson(CalendarFormData data) {
    final countryId = data.countryId.trim();
    return {
      'calendarCode': data.calendarCode.trim(),
      'name': data.name.trim(),
      'calendarName': data.name.trim(),
      'type': data.type.apiValue,
      'calendarType': data.type.apiValue,
      if (countryId.isNotEmpty) 'countryId': _serializeId(countryId),
      'regionCode': data.regionCode.trim(),
      'timezone': data.timezone.trim(),
      'active': data.active,
    };
  }

  List<CalendarFormData> _parseList(dynamic decoded) {
    if (decoded is List<dynamic>) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_fromJson)
          .toList(growable: false);
    }
    if (decoded is Map<String, dynamic>) {
      final items = decoded['items'];
      if (items is List<dynamic>) {
        return items
            .whereType<Map<String, dynamic>>()
            .map(_fromJson)
            .toList(growable: false);
      }
      final data = decoded['data'];
      if (data is List<dynamic>) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(_fromJson)
            .toList(growable: false);
      }
      if (data is Map<String, dynamic>) {
        final nestedItems = data['items'];
        if (nestedItems is List<dynamic>) {
          return nestedItems
              .whereType<Map<String, dynamic>>()
              .map(_fromJson)
              .toList(growable: false);
        }
      }
      if (_looksLikeCalendarPayload(decoded)) {
        return [_fromJson(decoded)];
      }
    }
    return const [];
  }

  void _syncFallbackUpsert(CalendarFormData item) {
    final id = (item.id ?? '').trim();
    if (id.isEmpty) return;
    _cachedCalendars.removeWhere((existing) => existing.id == id);
    _cachedCalendars.add(item);
    _fallback.replaceCalendars(_cachedCalendars);
  }

  void _syncFallbackCalendars(Iterable<CalendarFormData> items) {
    _cachedCalendars
      ..clear()
      ..addAll(items);
    _fallback.replaceCalendars(_cachedCalendars);
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    return json;
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

  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  static bool _looksLikeCalendarPayload(Map<String, dynamic> json) {
    return json.containsKey('calendarCode') ||
        json.containsKey('CalendarCode') ||
        json.containsKey('name') ||
        json.containsKey('calendarName');
  }

  static dynamic _serializeId(String value) {
    return int.tryParse(value) ?? value;
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
}

class CalendarApiException implements Exception {
  CalendarApiException({required this.statusCode, this.body});

  final int statusCode;
  final String? body;

  @override
  String toString() => 'CalendarApiException: $statusCode ${body ?? ''}';
}
