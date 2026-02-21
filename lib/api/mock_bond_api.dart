import 'dart:async';
import '../models/list_item_model.dart';
import '../models/bond_form_data.dart';
import '../models/bond_enums.dart';
import 'bond_api.dart';

/// Mock implementation of Bond API (in-memory storage).
class MockBondApi implements BondApi {
  MockBondApi() {
    _storage.addAll(_seedData);
  }

  final List<BondFormData> _storage = [];

  static List<BondFormData> get _seedData => [
        BondFormData(
          id: 'bd1',
          marketCode: 'KR3YT',
          name: 'Korean Treasury 3Y',
          ccy: Ccy.krw,
          intPayMethod: IntPayMethod.couponBond,
          liquiditySect: LiquiditySect.high,
          subordSect: SubordSect.senior,
          issueDate: DateTime(2020, 1, 1),
          maturityDate: DateTime(2023, 1, 1),
          source: 'Korea',
          originSource: OriginSource.domestic,
          originCode: 'KR3',
          entityOriginSource: 'KR',
          entityOriginCode: EntityOriginCode.kr,
          issueKind: IssueKind.government,
          issuePurpose: IssuePurpose.refinancing,
          description: 'Korean Treasury 3Y',
        ),
        BondFormData(
          id: 'bd2',
          marketCode: 'KR10YT',
          name: 'Korean Treasury 10Y',
          ccy: Ccy.krw,
          intPayMethod: IntPayMethod.couponBond,
          liquiditySect: LiquiditySect.high,
          subordSect: SubordSect.senior,
          issueDate: DateTime(2019, 6, 1),
          maturityDate: DateTime(2029, 6, 1),
          source: 'Korea',
          originSource: OriginSource.domestic,
          originCode: 'KR10',
          entityOriginSource: 'KR',
          entityOriginCode: EntityOriginCode.kr,
          issueKind: IssueKind.government,
          issuePurpose: IssuePurpose.capital,
          description: 'Korean Treasury 10Y',
        ),
        BondFormData(
          id: 'bd3',
          marketCode: 'US10YT',
          name: 'US Treasury 10Y',
          ccy: Ccy.usd,
          intPayMethod: IntPayMethod.couponBond,
          liquiditySect: LiquiditySect.high,
          subordSect: SubordSect.senior,
          issueDate: DateTime(2015, 1, 1),
          maturityDate: DateTime(2025, 1, 1),
          source: 'US',
          originSource: OriginSource.international,
          originCode: 'US10',
          entityOriginSource: 'US',
          entityOriginCode: EntityOriginCode.us,
          issueKind: IssueKind.government,
          issuePurpose: IssuePurpose.refinancing,
          description: 'US Treasury 10Y',
        ),
      ];

  @override
  Future<List<ListItemModel>> getList() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _storage
        .map((b) => ListItemModel(
              id: b.id ?? '',
              title: b.name,
              subtitle: b.marketCode,
            ))
        .toList();
  }

  @override
  Future<BondFormData?> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return _storage.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BondFormData> create(BondFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final id = 'bond_${DateTime.now().millisecondsSinceEpoch}';
    final created = BondFormData(
      id: id,
      marketCode: data.marketCode,
      name: data.name,
      ccy: data.ccy,
      intPayMethod: data.intPayMethod,
      liquiditySect: data.liquiditySect,
      subordSect: data.subordSect,
      issueDate: data.issueDate,
      maturityDate: data.maturityDate,
      source: data.source,
      originSource: data.originSource,
      originCode: data.originCode,
      entityOriginSource: data.entityOriginSource,
      entityOriginCode: data.entityOriginCode,
      issueKind: data.issueKind,
      issuePurpose: data.issuePurpose,
      description: data.description,
    );
    _storage.insert(0, created);
    return created;
  }

  @override
  Future<BondFormData> update(BondFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final id = data.id;
    if (id == null) throw StateError('Bond id is null');
    final idx = _storage.indexWhere((e) => e.id == id);
    if (idx < 0) throw StateError('Bond not found: $id');
    _storage[idx] = data;
    return data;
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _storage.removeWhere((e) => e.id == id);
  }
}
