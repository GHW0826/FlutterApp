import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/country_form_data.dart';
import 'country_api.dart';

class RemoteCountryApi implements CountryApi {
  RemoteCountryApi({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 5),
  });

  final String baseUrl;
  final Duration timeout;

  String get _normalizedBaseUrl => baseUrl.replaceAll(RegExp(r'/+$'), '');
  String get _countryUrl => '$_normalizedBaseUrl/api/v1/countries';
  String _countryByIdUrl(String id) => '$_countryUrl/$id';

  @override
  Future<List<CountryFormData>> getList({bool? active}) async {
    final uri = Uri.parse(
      _countryUrl,
    ).replace(queryParameters: {if (active != null) 'active': '$active'});
    _debug('GET', uri.toString());
    final response = await http.get(uri).timeout(timeout);
    _debugStatus(response.statusCode);
    if (response.statusCode == 404 || response.statusCode == 405) {
      return [];
    }
    _checkResponse(response);

    if (response.body.trim().isEmpty) return [];
    final decoded = jsonDecode(response.body);
    return _parseList(decoded);
  }

  @override
  Future<CountryFormData?> getById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;
    final url = _countryByIdUrl(normalizedId);
    _debug('GET', url);
    final response = await http.get(Uri.parse(url)).timeout(timeout);
    _debugStatus(response.statusCode);
    if (response.statusCode == 404) return null;
    _checkResponse(response);

    if (response.body.trim().isEmpty) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return _fromJson(_unwrapMap(decoded));
    }
    return null;
  }

  @override
  Future<CountryFormData> create(CountryFormData data) async {
    _debug('POST', _countryUrl);
    final response = await http
        .post(
          Uri.parse(_countryUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_toJson(data)),
        )
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);

    if (response.body.trim().isEmpty) return data;
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return _fromJson(_unwrapMap(decoded));
    }
    return data;
  }

  @override
  Future<CountryFormData> patch(CountryFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('Country id is empty.');
    }

    final uri = Uri.parse(_countryByIdUrl(id));
    final body = jsonEncode(_toJson(data));

    _debug('PATCH', uri.toString());
    final response = await http
        .patch(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);

    if (response.body.trim().isEmpty) return data;
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return _fromJson(_unwrapMap(decoded));
    }
    return data;
  }

  @override
  Future<CountryFormData> put(CountryFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('Country id is empty.');
    }

    final uri = Uri.parse(_countryByIdUrl(id));
    final body = jsonEncode(_toJson(data));

    _debug('PUT', uri.toString());
    final response = await http
        .put(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);

    if (response.body.trim().isEmpty) return data;
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return _fromJson(_unwrapMap(decoded));
    }
    return data;
  }

  @override
  Future<CountryFormData> update(CountryFormData data) {
    return patch(data);
  }

  @override
  Future<void> delete(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw StateError('Country id is empty.');
    }
    final url = _countryByIdUrl(normalizedId);
    _debug('DELETE', url);
    final response = await http.delete(Uri.parse(url)).timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);
  }

  List<CountryFormData> _parseList(dynamic decoded) {
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
        if (_looksLikeCountryPayload(data)) {
          return [_fromJson(data)];
        }
      }
      if (_looksLikeCountryPayload(decoded)) {
        return [_fromJson(decoded)];
      }
    }
    return const [];
  }

  CountryFormData _fromJson(Map<String, dynamic> json) {
    return CountryFormData(
      id: _readString(json, const ['id', 'countryId', 'country_id']),
      countryIso2: _readString(json, const [
        'countryIso2',
        'country_iso2',
        'iso2',
      ]),
      countryIso3: _readString(json, const [
        'countryIso3',
        'country_iso3',
        'iso3',
      ]),
      numericCode: _readString(json, const ['numericCode', 'numeric_code']),
      name: _readString(json, const ['name', 'countryName']),
      timezone: _readString(json, const ['timezone']),
      active: _readBool(json, const ['active'], fallback: true),
      description: _readString(json, const ['description']),
    );
  }

  Map<String, dynamic> _toJson(CountryFormData data) {
    return {
      'countryIso2': data.countryIso2.trim().toUpperCase(),
      'countryIso3': data.countryIso3.trim().toUpperCase(),
      'numericCode': data.numericCode.trim(),
      'name': data.name.trim(),
      'timezone': data.timezone.trim(),
      'active': data.active,
      'description': data.description.trim(),
    };
  }

  static Map<String, dynamic> _unwrapMap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    return json;
  }

  static bool _looksLikeCountryPayload(Map<String, dynamic> json) {
    return json.containsKey('countryIso2') ||
        json.containsKey('country_iso2') ||
        json.containsKey('countryIso3') ||
        json.containsKey('country_iso3');
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is num) return value.toString();
    }
    return '';
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

  void _debug(String method, String url) {
    debugPrint('[CountryApi] $method $url');
  }

  void _debugStatus(int statusCode) {
    debugPrint('[CountryApi] <-- $statusCode');
  }

  static void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw CountryApiException(
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}

class CountryApiException implements Exception {
  CountryApiException({required this.statusCode, this.body});

  final int statusCode;
  final String? body;

  @override
  String toString() => 'CountryApiException: $statusCode ${body ?? ''}';
}
