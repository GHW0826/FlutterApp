import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/reference_master_form_data.dart';
import 'vendor_api.dart';

class RemoteVendorApi implements VendorApi {
  RemoteVendorApi({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 5),
    this.authToken = '',
  });

  final String baseUrl;
  final Duration timeout;
  final String authToken;

  String get _normalizedBaseUrl => baseUrl.replaceAll(RegExp(r'/+$'), '');
  String get _vendorUrl => '$_normalizedBaseUrl/api/v1/vendors';
  String _vendorByIdUrl(String id) => '$_vendorUrl/$id';

  @override
  Future<List<ReferenceMasterFormData>> getList({
    bool? active,
    VendorStatus? status,
    int page = 0,
    int size = 20,
  }) async {
    final uri = Uri.parse(
      _vendorUrl,
    ).replace(queryParameters: {if (active != null) 'active': '$active'});
    _debug('GET', uri.toString());
    final response = await http.get(uri, headers: _headers()).timeout(timeout);
    _debugStatus(response.statusCode);
    if (response.statusCode == 404 || response.statusCode == 405) {
      return [];
    }
    _checkResponse(response);
    if (response.body.trim().isEmpty) return [];
    return _parseList(jsonDecode(response.body));
  }

  @override
  Future<ReferenceMasterFormData?> findById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;
    final url = _vendorByIdUrl(normalizedId);
    _debug('GET', url);
    final response = await http
        .get(Uri.parse(url), headers: _headers())
        .timeout(timeout);
    _debugStatus(response.statusCode);
    if (response.statusCode == 404) return null;
    _checkResponse(response);
    if (response.body.trim().isEmpty) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    return _fromJson(_unwrapMap(decoded));
  }

  @override
  Future<ReferenceMasterFormData> create(ReferenceMasterFormData data) async {
    _debug('POST', _vendorUrl);
    final response = await http
        .post(
          Uri.parse(_vendorUrl),
          headers: _headers(contentTypeJson: true),
          body: jsonEncode(_toJson(data)),
        )
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);
    if (response.body.trim().isEmpty) return data;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return data;
    return _fromJson(_unwrapMap(decoded));
  }

  @override
  Future<ReferenceMasterFormData> patch(ReferenceMasterFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError(
        'Vendor id is empty. PATCH requires /api/v1/vendors/{id}.',
      );
    }
    final url = _vendorByIdUrl(id);
    _debug('PATCH', url);
    final response = await http
        .patch(
          Uri.parse(url),
          headers: _headers(contentTypeJson: true),
          body: jsonEncode(_toJson(data)),
        )
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);
    if (response.body.trim().isEmpty) return data;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return data;
    return _fromJson(_unwrapMap(decoded));
  }

  @override
  Future<ReferenceMasterFormData> put(ReferenceMasterFormData data) async {
    final id = (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError(
        'Vendor id is empty. PUT requires /api/v1/vendors/{id}.',
      );
    }
    final url = _vendorByIdUrl(id);
    _debug('PUT', url);
    final response = await http
        .put(
          Uri.parse(url),
          headers: _headers(contentTypeJson: true),
          body: jsonEncode(_toJson(data)),
        )
        .timeout(timeout);
    _debugStatus(response.statusCode);
    _checkResponse(response);
    if (response.body.trim().isEmpty) return data;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return data;
    return _fromJson(_unwrapMap(decoded));
  }

  @override
  Future<ReferenceMasterFormData> update(ReferenceMasterFormData data) {
    return patch(data);
  }

  @override
  Future<void> delete({required String id}) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw StateError(
        'Vendor id is empty. DELETE requires /api/v1/vendors/{id}.',
      );
    }
    final url = _vendorByIdUrl(normalizedId);
    _debug('DELETE', url);
    final response = await http
        .delete(Uri.parse(url), headers: _headers())
        .timeout(timeout);
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
    if (decoded is! Map<String, dynamic>) return const [];
    final items = decoded['items'];
    if (items is List<dynamic>) {
      return items
          .whereType<Map<String, dynamic>>()
          .map(_fromJson)
          .toList(growable: false);
    }
    final content = decoded['content'];
    if (content is List<dynamic>) {
      return content
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
      if (_looksLikeVendorPayload(data)) {
        return [_fromJson(data)];
      }
    }
    if (_looksLikeVendorPayload(decoded)) {
      return [_fromJson(decoded)];
    }
    return const [];
  }

  ReferenceMasterFormData _fromJson(Map<String, dynamic> json) {
    final active = _readBool(json, const ['active', 'isActive'], fallback: true);
    return ReferenceMasterFormData(
      id: _readString(json, const ['vendorId', 'id', 'vendor_id']),
      code: _readString(json, const ['vendorCode', 'VendorCode', 'code']),
      name: _readString(json, const ['name', 'vendorName', 'VendorName']),
      shortName: _readString(json, const ['shortName', 'ShortName']),
      homepageUrl: _readString(json, const ['homepageUrl', 'HomepageUrl']),
      vendorStatus: active ? VendorStatus.active : VendorStatus.inactive,
      active: active,
      description: _readString(json, const ['description', 'Description']),
    );
  }

  Map<String, dynamic> _toJson(ReferenceMasterFormData data) {
    final active =
        data.active ??
        (data.vendorStatus == null
            ? true
            : data.vendorStatus == VendorStatus.active);
    return {
      'vendorCode': data.code.trim(),
      'name': data.name.trim(),
      'shortName': data.shortName.trim(),
      'homepageUrl': data.homepageUrl.trim(),
      'active': active,
      'description': data.description.trim(),
    };
  }

  static Map<String, dynamic> _unwrapMap(Map<String, dynamic> json) {
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

  static bool _looksLikeVendorPayload(Map<String, dynamic> json) {
    return json.containsKey('vendorCode') ||
        json.containsKey('VendorCode') ||
        json.containsKey('name') ||
        json.containsKey('vendorId');
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

  Map<String, String> _headers({bool contentTypeJson = false}) {
    final headers = <String, String>{};
    if (contentTypeJson) {
      headers['Content-Type'] = 'application/json';
    }
    final token = authToken.trim();
    if (token.isNotEmpty) {
      headers['Authorization'] = token.startsWith('Bearer ')
          ? token
          : 'Bearer $token';
    }
    return headers;
  }

  void _debug(String method, String url) {
    debugPrint('[VendorApi] $method $url');
  }

  void _debugStatus(int statusCode) {
    debugPrint('[VendorApi] <-- $statusCode');
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw VendorApiException(
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}

class VendorApiException implements Exception {
  VendorApiException({required this.statusCode, this.body});

  final int statusCode;
  final String? body;

  @override
  String toString() => 'VendorApiException: $statusCode ${body ?? ''}';
}
