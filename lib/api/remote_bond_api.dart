import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/list_item_model.dart';
import '../models/bond_form_data.dart';
import '../models/bond_enums.dart';
import 'bond_api.dart';

/// Remote server implementation of Bond API (HTTP).
class RemoteBondApi implements BondApi {
  RemoteBondApi({required this.baseUrl, this.timeout = const Duration(seconds: 5)});

  final String baseUrl;
  final Duration timeout;

  String get _normalizedBaseUrl => baseUrl.replaceAll(RegExp(r'/+$'), '');
  String get _bondUrl => '$_normalizedBaseUrl/api/v1/market/bond';
  String _bondDetailUrl(String mdCd) => '$_bondUrl/$mdCd';

  @override
  Future<List<ListItemModel>> getList() async {
    final response = await http.get(Uri.parse(_bondUrl)).timeout(timeout);
    if (response.statusCode == 404 || response.statusCode == 405) return [];
    if (response.statusCode == 500 && response.body.contains("Request method 'GET' is not supported")) {
      return [];
    }
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    if (decoded is List<dynamic>) {
      return decoded.map((e) => _itemFromJson(e as Map<String, dynamic>)).toList();
    }
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List<dynamic>) {
        return data.map((e) => _itemFromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  @override
  Future<BondFormData?> getById(String id) async {
    final response = await http.get(Uri.parse(_bondDetailUrl(id))).timeout(timeout);
    if (response.statusCode == 404) return null;
    _checkResponse(response);
    final map = jsonDecode(response.body) as Map<String, dynamic>?;
    return map != null ? _fromApiJson(map) : null;
  }

  @override
  Future<BondFormData> create(BondFormData data) async {
    final body = jsonEncode(_toApiJson(data));
    final response = await http
        .post(
          Uri.parse(_bondUrl),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(timeout);
    _checkResponse(response);
    final map = jsonDecode(response.body) as Map<String, dynamic>?;
    if (map == null) return data;
    return _fromApiJson(map);
  }

  @override
  Future<BondFormData> update(BondFormData data) async {
    final id = data.id ?? data.marketCode;
    if (id.trim().isEmpty) throw StateError('Bond id/marketCode is empty');

    final body = jsonEncode(_toApiJson(data));
    final response = await http
        .put(
          Uri.parse(_bondDetailUrl(id)),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(timeout);
    _checkResponse(response);
    final map = jsonDecode(response.body) as Map<String, dynamic>?;
    if (map == null) return data;
    return _fromApiJson(map);
  }

  @override
  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse(_bondDetailUrl(id))).timeout(timeout);
    _checkResponse(response);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw BondApiException(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  ListItemModel _itemFromJson(Map<String, dynamic> json) {
    final id = _readString(json, const ['MarketDataCode', 'marketCode', 'mdCd', 'id']);
    final name = _readString(json, const ['Name', 'name']);
    return ListItemModel(
      id: id,
      title: name,
      subtitle: id,
    );
  }

  BondFormData _fromApiJson(Map<String, dynamic> json) {
    return BondFormData(
      id: _readString(json, const ['MarketDataCode', 'marketCode', 'mdCd', 'id']),
      marketCode: _readString(json, const ['MarketDataCode', 'marketCode', 'mdCd']),
      name: _readString(json, const ['Name', 'name']),
      ccy: Ccy.fromApi(_readString(json, const ['Ccy', 'ccy'])),
      intPayMethod: IntPayMethod.fromApi(_readString(json, const ['InterestPayMethod', 'intPayMethod'])),
      subordSect: SubordSect.fromApi(_readString(json, const ['SubordinationClassification', 'subordSect'])),
      issueDate: _parseDate(_readString(json, const ['IssueDate', 'issueDate'])),
      maturityDate: _parseDate(_readString(json, const ['MaturityDate', 'maturityDate'])),
      source: _readString(json, const ['IssuerCode', 'source']),
      sourceCode: SourceCode.fromApi(_readString(json, const ['OriginSourceCode', 'sourceCode'])),
      originSource: OriginSource.fromApi(_readString(json, const ['OriginSourceCode', 'originSource'])),
      originCode: _readString(json, const ['OriginSourceCode', 'originCode']),
      entityOriginSource: _readString(json, const ['ISINCode', 'entityOriginSource']),
      entityOriginCode: EntityOriginCode.fromApi(_readString(json, const ['entityOriginCode'])),
      issueKind: IssueKind.fromApi(_readString(json, const ['IssueKind', 'issueKind'])),
      issuePurpose: IssuePurpose.fromApi(_readString(json, const ['IssuePurpose', 'issuePurpose'])),
      listingSection: ListingSection.fromApi(_readString(json, const ['ListingSection', 'listingSection'])),
      assetSecuritizationClassification: AssetSecuritizationClassification.fromApi(
        _readString(
          json,
          const [
            'AssetSecuritizationClassification',
            'assetSecuritizationClassification',
          ],
        ),
      ),
      description: _readString(json, const ['Description', 'description']),
    );
  }

  Map<String, dynamic> _toApiJson(BondFormData data) {
    return {
      'MarketDataCode': data.marketCode,
      'Name': data.name,
      'IssuerCode': data.source,
      'ISINCode': data.entityOriginSource,
      'ListingSection': (data.listingSection ?? ListingSection.listed).apiValue,
      'assetGroup': 'FI',
      'InterestPayMethod': data.intPayMethod?.apiValue,
      'AssetSecuritizationClassification':
          (data.assetSecuritizationClassification ?? AssetSecuritizationClassification.none).apiValue,
      'SubordinationClassification': data.subordSect?.apiValue,
      'IssueDate': _formatDate(data.issueDate),
      'MaturityDate': _formatDate(data.maturityDate),
      'Ccy': data.ccy?.apiValue,
      'OriginSourceCode': (data.sourceCode?.apiValue ?? data.originSource?.apiValue ?? SourceCode.none.apiValue),
      'IssueKind': data.issueKind?.apiValue,
      'IssuePurpose': data.issuePurpose?.apiValue,
      'Description': data.description,
    }..removeWhere((_, value) => value == null);
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return '';
  }

  static DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static String? _formatDate(DateTime? value) {
    if (value == null) return null;
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class BondApiException implements Exception {
  BondApiException({required this.statusCode, this.body});
  final int statusCode;
  final String? body;
  @override
  String toString() => 'BondApiException: $statusCode ${body ?? ''}';
}
