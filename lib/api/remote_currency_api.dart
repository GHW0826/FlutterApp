import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/reference_master_form_data.dart';
import 'currency_api.dart';

class RemoteCurrencyApi implements CurrencyApi {
  RemoteCurrencyApi({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 5),
  });

  final String baseUrl;
  final Duration timeout;

  String get _normalizedBaseUrl => baseUrl.replaceAll(RegExp(r'/+$'), '');
  String get _currencyUrl => '$_normalizedBaseUrl/api/v1/currencies';
  String _currencyByIdUrl(String id) => '$_currencyUrl/$id';

  @override
  Future<List<ReferenceMasterFormData>> getList({bool? active}) async {
    final uri = Uri.parse(
      _currencyUrl,
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
  Future<ReferenceMasterFormData?> getById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;

    final url = _currencyByIdUrl(normalizedId);
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
  Future<ReferenceMasterFormData> create(ReferenceMasterFormData data) async {
    _debug('POST', _currencyUrl);
    final response = await http
        .post(
          Uri.parse(_currencyUrl),
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
  Future<ReferenceMasterFormData> patch(ReferenceMasterFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError(
        'Currency id is empty. PATCH requires /api/v1/currencies/{id}.',
      );
    }

    final uri = Uri.parse(_currencyByIdUrl(id));
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
  Future<ReferenceMasterFormData> put(ReferenceMasterFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError(
        'Currency id is empty. PUT requires /api/v1/currencies/{id}.',
      );
    }

    final uri = Uri.parse(_currencyByIdUrl(id));
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
  Future<ReferenceMasterFormData> update(ReferenceMasterFormData data) {
    return patch(data);
  }

  @override
  Future<void> delete(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw StateError(
        'Currency id is empty. DELETE requires /api/v1/currencies/{id}.',
      );
    }

    final url = _currencyByIdUrl(normalizedId);
    _debug('DELETE', url);
    final response = await http.delete(Uri.parse(url)).timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);
  }

  List<ReferenceMasterFormData> _parseList(dynamic decoded) {
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
        if (_looksLikeCurrencyPayload(data)) {
          return [_fromJson(data)];
        }
      }
      if (_looksLikeCurrencyPayload(decoded)) {
        return [_fromJson(decoded)];
      }
    }
    return const [];
  }

  ReferenceMasterFormData _fromJson(Map<String, dynamic> json) {
    return ReferenceMasterFormData(
      id: _readString(json, const ['id', 'currencyId', 'currency_id']),
      code: _readString(json, const ['currencyCode', 'currency_code', 'code']),
      name: _readString(json, const ['currencyName', 'currency_name', 'name']),
      active: _readBool(json, const ['active', 'isActive'], fallback: true),
      description: _readString(json, const ['description']),
    );
  }

  Map<String, dynamic> _toJson(ReferenceMasterFormData data) {
    return {
      'currencyCode': data.code.trim().toUpperCase(),
      'currencyName': data.name.trim(),
      'active': data.active ?? true,
      'description': data.description.trim(),
    };
  }

  static Map<String, dynamic> _unwrapMap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    return json;
  }

  static bool _looksLikeCurrencyPayload(Map<String, dynamic> json) {
    return json.containsKey('currencyCode') ||
        json.containsKey('currency_code') ||
        json.containsKey('currencyName') ||
        json.containsKey('currency_name');
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
    debugPrint('[CurrencyApi] $method $url');
  }

  void _debugStatus(int statusCode) {
    debugPrint('[CurrencyApi] <-- $statusCode');
  }

  static void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw CurrencyApiException(
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}

class CurrencyApiException implements Exception {
  CurrencyApiException({required this.statusCode, this.body});

  final int statusCode;
  final String? body;

  @override
  String toString() => 'CurrencyApiException: $statusCode ${body ?? ''}';
}
