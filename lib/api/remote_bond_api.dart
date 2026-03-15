import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/bond_form_data.dart';
import '../models/list_item_model.dart';
import 'bond_api.dart';

class RemoteBondApi implements BondApi {
  RemoteBondApi({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 5),
  });

  final String baseUrl;
  final Duration timeout;

  String get _normalizedBaseUrl => baseUrl.replaceAll(RegExp(r'/+$'), '');
  String get _bondCollectionUrl => '$_normalizedBaseUrl/api/v1/market/bond/';
  String get _bondDetailBaseUrl => '$_normalizedBaseUrl/api/v1/market/bond';
  String _bondDetailUrl(String mdCd) => '$_bondDetailBaseUrl/$mdCd';

  @override
  Future<List<ListItemModel>> getList() async {
    final response = await http
        .get(Uri.parse(_bondCollectionUrl))
        .timeout(timeout);
    if (response.statusCode == 404 || response.statusCode == 405) return [];
    if (response.statusCode == 500 &&
        response.body.contains("Request method 'GET' is not supported")) {
      return [];
    }
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    if (decoded is List<dynamic>) {
      return decoded
          .map((e) => _itemFromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (decoded is Map<String, dynamic> && decoded['data'] is List<dynamic>) {
      return (decoded['data'] as List<dynamic>)
          .map((e) => _itemFromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<BondFormData?> getById(String id) async {
    final response = await http
        .get(Uri.parse(_bondDetailUrl(id)))
        .timeout(timeout);
    if (response.statusCode == 404) return null;
    _checkResponse(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>?;
    return body == null ? null : _fromApiJson(body);
  }

  @override
  Future<BondFormData> create(BondFormData data) async {
    final response = await http
        .post(
          Uri.parse(_bondCollectionUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_toApiJson(data)),
        )
        .timeout(timeout);
    _checkResponse(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>?;
    return body == null ? data : _fromApiJson(body);
  }

  @override
  Future<BondFormData> update(BondFormData data) async {
    final id = data.marketCode.trim().isNotEmpty
        ? data.marketCode.trim()
        : (data.id ?? '').trim();
    if (id.isEmpty) {
      throw StateError('Bond id/marketCode is empty.');
    }

    final response = await http
        .put(
          Uri.parse(_bondDetailUrl(id)),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_toApiJson(data)),
        )
        .timeout(timeout);
    _checkResponse(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>?;
    return body == null ? data : _fromApiJson(body);
  }

  @override
  Future<void> delete(String id) async {
    final response = await http
        .delete(Uri.parse(_bondDetailUrl(id)))
        .timeout(timeout);
    _checkResponse(response);
  }

  ListItemModel _itemFromJson(Map<String, dynamic> json) {
    final marketCode = _readString(json, const ['marketCode', 'mdCd', 'id']);
    final name = _readString(json, const ['name']);
    return ListItemModel(id: marketCode, title: name, subtitle: marketCode);
  }

  BondFormData _fromApiJson(Map<String, dynamic> json) {
    final marketCode = _readString(json, const ['marketCode', 'mdCd']);
    return BondFormData(
      id: marketCode,
      marketCode: marketCode,
      vendorId: _readString(json, const ['vendorId']),
      name: _readString(json, const ['name']),
      currencyId: _readString(json, const ['currencyId']),
      defaultTradingContextId: _readString(json, const [
        'defaultTradingContextId',
      ]),
      defaultValuationContextId: _readString(json, const [
        'defaultValuationContextId',
      ]),
      description: _readString(json, const ['description']),
      isin: _readString(json, const ['isin']),
      issuerId: _readString(json, const ['issuerId']),
      issueDate: _parseDate(_readString(json, const ['issueDate'])),
      maturityDate: _parseDate(_readString(json, const ['maturityDate'])),
      couponType: _readString(json, const ['couponType']),
      couponRate: _readDouble(json, const ['couponRate']),
      couponFrequency: _readString(json, const ['couponFrequency']),
      dayCountConvention: _readString(json, const ['dayCountConvention']),
      faceValue: _readDouble(json, const ['faceValue']),
      redemption: _readDouble(json, const ['redemption']),
    );
  }

  Map<String, dynamic> _toApiJson(BondFormData data) {
    return {
      'marketCode': data.marketCode,
      'vendorId': _parseInt(data.vendorId),
      'name': data.name,
      'currencyId': _parseInt(data.currencyId),
      'defaultTradingContextId': _parseNullableInt(
        data.defaultTradingContextId,
      ),
      'defaultValuationContextId': _parseNullableInt(
        data.defaultValuationContextId,
      ),
      'description': data.description,
      'isin': data.isin,
      'issuerId': _parseNullableInt(data.issuerId),
      'issueDate': _formatDate(data.issueDate),
      'maturityDate': _formatDate(data.maturityDate),
      'couponType': _emptyToNull(data.couponType),
      'couponRate': data.couponRate,
      'couponFrequency': _emptyToNull(data.couponFrequency),
      'dayCountConvention': _emptyToNull(data.dayCountConvention),
      'faceValue': data.faceValue,
      'redemption': data.redemption,
    }..removeWhere((_, value) => value == null);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw BondApiException(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static double? _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toDouble();
      if (value != null) {
        final parsed = double.tryParse(value.toString().trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static DateTime? _parseDate(String text) {
    if (text.trim().isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static String? _formatDate(DateTime? value) {
    if (value == null) return null;
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static int _parseInt(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      throw StateError('Invalid numeric id: $value');
    }
    return parsed;
  }

  static int? _parseNullableInt(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  static String? _emptyToNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}

class BondApiException implements Exception {
  BondApiException({required this.statusCode, this.body});

  final int statusCode;
  final String? body;

  @override
  String toString() => 'BondApiException: $statusCode ${body ?? ''}';
}
