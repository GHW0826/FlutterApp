import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/issuer_form_data.dart';
import 'issuer_api.dart';

class RemoteIssuerApi implements IssuerApi {
  RemoteIssuerApi({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 5),
  });

  final String baseUrl;
  final Duration timeout;

  String get _normalizedBaseUrl => baseUrl.replaceAll(RegExp(r'/+$'), '');
  String get _issuerUrl => '$_normalizedBaseUrl/api/v1/issuers';
  String _issuerByIdUrl(String id) => '$_issuerUrl/$id';

  @override
  Future<List<IssuerFormData>> getList({bool? active}) async {
    final uri = Uri.parse(
      _issuerUrl,
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
  Future<IssuerFormData?> getById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;
    final url = _issuerByIdUrl(normalizedId);
    _debug('GET', url);
    final response = await http.get(Uri.parse(url)).timeout(timeout);
    _debugStatus(response.statusCode);
    if (response.statusCode == 404) return null;
    _checkResponse(response);

    if (response.body.trim().isEmpty) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return _fromJson(_unwrap(decoded));
    }
    return null;
  }

  @override
  Future<IssuerFormData?> findByIssuerCode(String issuerCode) async {
    final code = issuerCode.trim();
    if (code.isEmpty) return null;
    final items = await getList();
    try {
      return items.firstWhere(
        (item) => item.issuerCode.trim().toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<IssuerFormData> create(IssuerFormData data) async {
    _debug('POST', _issuerUrl);
    final response = await http
        .post(
          Uri.parse(_issuerUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_toJson(data)),
        )
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);

    if (response.body.trim().isEmpty) return data;
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return _fromJson(_unwrap(decoded));
    }
    return data;
  }

  @override
  Future<IssuerFormData> patch(IssuerFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError(
        'Issuer id is empty. PATCH requires /api/v1/issuers/{id}.',
      );
    }
    final uri = Uri.parse(_issuerByIdUrl(id));
    _debug('PATCH', uri.toString());
    final response = await http
        .patch(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_toJson(data)),
        )
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);

    if (response.body.trim().isEmpty) return data;
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return _fromJson(_unwrap(decoded));
    }
    return data;
  }

  @override
  Future<IssuerFormData> put(IssuerFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError(
        'Issuer id is empty. PUT requires /api/v1/issuers/{id}.',
      );
    }
    final uri = Uri.parse(_issuerByIdUrl(id));
    _debug('PUT', uri.toString());
    final response = await http
        .put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_toJson(data)),
        )
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);

    if (response.body.trim().isEmpty) return data;
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return _fromJson(_unwrap(decoded));
    }
    return data;
  }

  @override
  Future<IssuerFormData> update(IssuerFormData data) => patch(data);

  @override
  Future<void> delete({required String id}) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw StateError(
        'Issuer id is empty. DELETE requires /api/v1/issuers/{id}.',
      );
    }
    final url = _issuerByIdUrl(normalizedId);
    _debug('DELETE', url);
    final response = await http.delete(Uri.parse(url)).timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);
  }

  List<IssuerFormData> _parseList(dynamic decoded) {
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
        if (_looksLikeIssuerPayload(data)) {
          return [_fromJson(data)];
        }
      }
      if (_looksLikeIssuerPayload(decoded)) {
        return [_fromJson(decoded)];
      }
    }
    return const [];
  }

  IssuerFormData _fromJson(Map<String, dynamic> json) {
    return IssuerFormData(
      id: _readString(json, const ['id', 'issuerId', 'issuer_id']),
      issuerCode: _readString(json, const [
        'issuerCode',
        'issuer_code',
        'code',
      ]),
      code: _readString(json, const ['code', 'issuerCode', 'issuer_code']),
      name: _readString(json, const ['name', 'issuerName', 'issuer_name']),
      shortName: _readString(json, const ['shortName', 'short_name']),
      countryIso2: _readString(json, const [
        'countryIso2',
        'country_iso2',
        'iso2',
      ]),
      lei: _readString(json, const ['lei']),
      parentIssuerCode: _readString(json, const [
        'parentIssuerCode',
        'parent_issuer_code',
      ]),
      activeFlag: _readBool(json, const [
        'active',
        'activeFlag',
      ], fallback: true),
      description: _readString(json, const ['description']),
    );
  }

  Map<String, dynamic> _toJson(IssuerFormData data) {
    return {
      'issuerCode': data.issuerCode.trim(),
      'code': data.code.trim(),
      'name': data.name.trim(),
      'shortName': data.shortName.trim(),
      'countryIso2': data.countryIso2.trim().toUpperCase(),
      'lei': data.lei.trim(),
      'parentIssuerCode': data.parentIssuerCode.trim(),
      'active': data.activeFlag,
      'description': data.description.trim(),
    }..removeWhere((_, value) => value == null);
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    return json;
  }

  static bool _looksLikeIssuerPayload(Map<String, dynamic> json) {
    return json.containsKey('issuerCode') ||
        json.containsKey('issuer_code') ||
        json.containsKey('issuerName') ||
        json.containsKey('name');
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
    debugPrint('[IssuerApi] $method $url');
  }

  void _debugStatus(int statusCode) {
    debugPrint('[IssuerApi] <-- $statusCode');
  }

  static void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw IssuerApiException(
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}

class IssuerApiException implements Exception {
  IssuerApiException({required this.statusCode, this.body});

  final int statusCode;
  final String? body;

  @override
  String toString() => 'IssuerApiException: $statusCode ${body ?? ''}';
}
