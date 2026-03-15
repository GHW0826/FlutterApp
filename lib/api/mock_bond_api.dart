import 'dart:async';

import '../models/bond_form_data.dart';
import '../models/list_item_model.dart';
import 'bond_api.dart';

class MockBondApi implements BondApi {
  MockBondApi() {
    _storage.addAll(_seedData);
  }

  final List<BondFormData> _storage = [];

  static List<BondFormData> get _seedData => [
    BondFormData(
      id: 'KR_GOV_3Y',
      marketCode: 'KR_GOV_3Y',
      vendorId: '1',
      vendorName: 'Bloomberg',
      name: 'Korea Treasury 3Y',
      currencyId: '1',
      currencyCode: 'KRW',
      description: 'Seed market bond',
      isin: 'KR103501GCC0',
      issuerId: '1',
      issuerName: 'Korea Government',
      issueDate: DateTime(2024, 1, 10),
      maturityDate: DateTime(2027, 1, 10),
      couponType: 'Fixed',
      couponRate: 3.25,
      couponFrequency: 'SemiAnnual',
      dayCountConvention: 'ACT365F',
      faceValue: 10000,
      redemption: 10000,
    ),
    BondFormData(
      id: 'US_GOV_10Y',
      marketCode: 'US_GOV_10Y',
      vendorId: '2',
      vendorName: 'Refinitiv',
      name: 'US Treasury 10Y',
      currencyId: '2',
      currencyCode: 'USD',
      description: 'Seed market bond',
      isin: 'US91282CJZ59',
      issuerId: '2',
      issuerName: 'US Government',
      issueDate: DateTime(2023, 11, 15),
      maturityDate: DateTime(2033, 11, 15),
      couponType: 'Fixed',
      couponRate: 4.5,
      couponFrequency: 'SemiAnnual',
      dayCountConvention: 'ACT360',
      faceValue: 100,
      redemption: 100,
    ),
  ];

  @override
  Future<List<ListItemModel>> getList() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _storage
        .map(
          (item) => ListItemModel(
            id: item.id ?? item.marketCode,
            title: item.name,
            subtitle: item.marketCode,
          ),
        )
        .toList();
  }

  @override
  Future<BondFormData?> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    for (final item in _storage) {
      if ((item.id ?? item.marketCode) == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<BondFormData> create(BondFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final created = data.copyWith(id: data.marketCode);
    _storage.insert(0, created);
    return created;
  }

  @override
  Future<BondFormData> update(BondFormData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final id = (data.id ?? data.marketCode).trim();
    final index = _storage.indexWhere(
      (item) => (item.id ?? item.marketCode) == id,
    );
    if (index < 0) {
      throw StateError('Bond not found: $id');
    }
    _storage[index] = data.copyWith(id: _storage[index].id ?? id);
    return _storage[index];
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    _storage.removeWhere((item) => (item.id ?? item.marketCode) == id);
  }
}
