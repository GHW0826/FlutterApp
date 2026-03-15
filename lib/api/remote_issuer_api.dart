import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/country_form_data.dart';
import '../models/issuer_form_data.dart';
import 'country_api_client.dart';
import 'issuer_api.dart';

class RemoteIssuerApi implements IssuerApi {
  RemoteIssuerApi({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 5),
  });

  final String baseUrl;
  final Duration timeout;
  final List<IssuerFormData> _cachedItems = [];

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
    final rawItems = _parseList(jsonDecode(response.body));
    final enriched = await _enrichIssuers(rawItems);
    _replaceCache(enriched);
    return enriched;
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
    if (decoded is! Map<String, dynamic>) return null;
    final raw = _fromJson(_unwrap(decoded));
    final enriched = await _enrichIssuer(raw);
    _syncIssuer(enriched);
    return enriched;
  }

  @override
  Future<IssuerFormData?> findByIssuerCode(String issuerCode) async {
    final code = issuerCode.trim();
    if (code.isEmpty) return null;
    final items = _cachedItems.isEmpty ? await getList() : _cachedItems;
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
    final response = await http
        .post(
          Uri.parse(_issuerUrl),
          headers: _jsonHeaders,
          body: jsonEncode(await _createJson(data)),
        )
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);
    if (response.body.trim().isEmpty) return data;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return data;
    final enriched = await _enrichIssuer(_fromJson(_unwrap(decoded)));
    _syncIssuer(enriched);
    return enriched;
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
          headers: _jsonHeaders,
          body: jsonEncode(await _updateJson(data, id: id)),
        )
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);
    if (response.body.trim().isEmpty) return data;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return data;
    final enriched = await _enrichIssuer(_fromJson(_unwrap(decoded)));
    _syncIssuer(enriched);
    return enriched;
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
          headers: _jsonHeaders,
          body: jsonEncode(await _updateJson(data, id: id)),
        )
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);
    if (response.body.trim().isEmpty) return data;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return data;
    final enriched = await _enrichIssuer(_fromJson(_unwrap(decoded)));
    _syncIssuer(enriched);
    return enriched;
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
    _cachedItems.removeWhere((item) => item.id == normalizedId);
  }

  List<IssuerFormData> _parseList(dynamic decoded) {
    if (decoded is List<dynamic>) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_fromJson)
          .toList(growable: false);
    }
    if (decoded is! Map<String, dynamic>) return const [];
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
    return const [];
  }

  IssuerFormData _fromJson(Map<String, dynamic> json) {
    return IssuerFormData(
      id: _readString(json, const ['issuerId', 'id', 'issuer_id']),
      issuerCode: _readString(json, const ['issuerCode', 'issuer_code', 'code']),
      code: _readString(json, const ['issuerCode', 'issuer_code', 'code']),
      name: _readString(json, const ['name', 'issuerName', 'issuer_name']),
      countryId: _readString(json, const ['countryId', 'country_id']),
      lei: _readString(json, const ['lei']),
      parentIssuerId: _readString(json, const ['parentIssuerId', 'parent_issuer_id']),
      groupFlag: _readBool(json, const ['groupFlag', 'group_flag'], fallback: false),
      activeFlag: _readBool(json, const ['active', 'activeFlag'], fallback: true),
      description: _readString(json, const ['description']),
    );
  }

  Future<IssuerFormData> _enrichIssuer(IssuerFormData item) async {
    final countries = await _loadCountries();
    final peers = _cachedItems.isEmpty ? [item] : [..._cachedItems, item];
    return _applyLookups(item, countries: countries, peers: peers);
  }

  Future<List<IssuerFormData>> _enrichIssuers(List<IssuerFormData> items) async {
    final countries = await _loadCountries();
    final peers = items.isEmpty ? _cachedItems : items;
    return items
        .map((item) => _applyLookups(item, countries: countries, peers: peers))
        .toList(growable: false);
  }

  IssuerFormData _applyLookups(
    IssuerFormData item, {
    required List<CountryFormData> countries,
    required List<IssuerFormData> peers,
  }) {
    final countryId = item.countryId.trim();
    final country = countries
        .where((candidate) => (candidate.id ?? '') == countryId)
        .firstOrNull;
    final parentIssuerId = item.parentIssuerId.trim();
    final parent = peers
        .where((candidate) => (candidate.id ?? '') == parentIssuerId)
        .firstOrNull;
    return item.copyWith(
      code: item.issuerCode,
      countryIso2: country?.countryIso2 ?? '',
      parentIssuerCode: parent?.issuerCode ?? '',
    );
  }

  Future<Map<String, dynamic>> _createJson(IssuerFormData data) async {
    final countryId = await _resolveCountryId(data.countryId, data.countryIso2);
    final parentIssuerId = await _resolveParentIssuerId(
      data.parentIssuerId,
      data.parentIssuerCode,
    );
    return {
      'issuerCode': data.issuerCode.trim(),
      'name': data.name.trim(),
      if (countryId != null) 'countryId': countryId,
      'lei': data.lei.trim(),
      if (parentIssuerId != null) 'parentIssuerId': parentIssuerId,
      'groupFlag': data.groupFlag,
      'active': data.activeFlag,
      'description': data.description.trim(),
    };
  }

  Future<Map<String, dynamic>> _updateJson(
    IssuerFormData data, {
    required String id,
  }) async {
    final countryId = await _resolveCountryId(data.countryId, data.countryIso2);
    final parentIssuerId = await _resolveParentIssuerId(
      data.parentIssuerId,
      data.parentIssuerCode,
    );
    return {
      'issuerId': int.tryParse(id) ?? id,
      'issuerCode': data.issuerCode.trim(),
      'name': data.name.trim(),
      if (countryId != null) 'countryId': countryId,
      'lei': data.lei.trim(),
      if (parentIssuerId != null) 'parentIssuerId': parentIssuerId,
      'active': data.activeFlag,
      'description': data.description.trim(),
    };
  }

  Future<int?> _resolveCountryId(String countryId, String countryIso2) async {
    final direct = int.tryParse(countryId.trim());
    if (direct != null) return direct;
    final normalizedIso2 = countryIso2.trim().toUpperCase();
    if (normalizedIso2.isEmpty) return null;
    final countries = await _loadCountries();
    final country = countries
        .where((candidate) => candidate.countryIso2.toUpperCase() == normalizedIso2)
        .firstOrNull;
    return int.tryParse(country?.id ?? '');
  }

  Future<int?> _resolveParentIssuerId(
    String parentIssuerId,
    String parentIssuerCode,
  ) async {
    final direct = int.tryParse(parentIssuerId.trim());
    if (direct != null) return direct;
    final normalizedCode = parentIssuerCode.trim().toUpperCase();
    if (normalizedCode.isEmpty) return null;
    final items = _cachedItems.isEmpty ? await getList() : _cachedItems;
    final parent = items
        .where((candidate) => candidate.issuerCode.trim().toUpperCase() == normalizedCode)
        .firstOrNull;
    return int.tryParse(parent?.id ?? '');
  }

  Future<List<CountryFormData>> _loadCountries() async {
    try {
      return await countryApi.getList();
    } catch (_) {
      return const [];
    }
  }

  void _replaceCache(List<IssuerFormData> items) {
    _cachedItems
      ..clear()
      ..addAll(items);
  }

  void _syncIssuer(IssuerFormData item) {
    final id = (item.id ?? '').trim();
    if (id.isEmpty) return;
    _cachedItems.removeWhere((candidate) => candidate.id == id);
    _cachedItems.add(item);
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    return json;
  }

  static bool _looksLikeIssuerPayload(Map<String, dynamic> json) {
    return json.containsKey('issuerId') ||
        json.containsKey('issuerCode') ||
        json.containsKey('issuer_code') ||
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

  static const _jsonHeaders = {'Content-Type': 'application/json'};
}

class IssuerApiException implements Exception {
  IssuerApiException({required this.statusCode, this.body});

  final int statusCode;
  final String? body;

  @override
  String toString() => 'IssuerApiException: $statusCode ${body ?? ''}';
}
