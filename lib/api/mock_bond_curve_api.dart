import 'dart:async';

import '../models/bond_curve_build_method_form_data.dart';
import '../models/bond_curve_master_form_data.dart';
import '../models/list_item_model.dart';
import 'bond_curve_api.dart';

class MockBondCurveApi implements BondCurveApi {
  MockBondCurveApi() {
    _masters.addAll(_seedMasters);
    _buildMethods.addAll(_seedBuildMethods);
  }

  final List<BondCurveMasterFormData> _masters = [];
  final List<BondCurveBuildMethodFormData> _buildMethods = [];

  static List<BondCurveMasterFormData> get _seedMasters => [
    BondCurveMasterFormData(
      id: 'KRW_GOVT_ZERO',
      curveCode: 'KRW_GOVT_ZERO',
      name: 'KRW Government Zero Curve',
      currencyId: '1',
      currencyCode: 'KRW',
      curveType: 'Government',
      curvePurpose: 'Benchmark',
      rateRepresentation: 'ZeroRate',
      active: true,
      validFrom: DateTime(2026, 1, 1),
      description: 'Seed curve',
      issuerId: '1',
      issuerName: 'Korea Government',
      onTheRunOnly: true,
      minRemainingYears: 0.25,
      minOutstandingAmount: 10000000000,
      outputIncludesYtm: true,
      outputIncludesZero: true,
      outputIncludesDf: true,
    ),
    BondCurveMasterFormData(
      id: 'USD_CORP_SPREAD',
      curveCode: 'USD_CORP_SPREAD',
      name: 'USD Corporate Spread Curve',
      currencyId: '2',
      currencyCode: 'USD',
      curveType: 'Corporate',
      curvePurpose: 'Spread',
      rateRepresentation: 'Spread',
      active: true,
      description: 'Seed curve',
      issuerId: '2',
      issuerName: 'US Government',
      onTheRunOnly: false,
      outputIncludesYtm: true,
      outputIncludesZero: false,
      outputIncludesDf: false,
    ),
  ];

  static List<BondCurveBuildMethodFormData> get _seedBuildMethods => [
    BondCurveBuildMethodFormData(
      id: 'KRW_BOOTSTRAP',
      buildMethodCode: 'KRW_BOOTSTRAP',
      name: 'KRW Bootstrap',
      fittingMethod: 'Bootstrap',
      interpolationMethod: 'LoglinearDF',
      extrapolationMethod: 'FlatFwd',
      dayCountConvention: 'ACT365F',
      compoundingType: 'Compounded',
      compoundingFrequency: 'SemiAnnual',
      businessDayConvention: 'Following',
      calendarId: 'cal_1',
      calendarCode: 'KR_BANK',
      settlementDays: 1,
      active: true,
      description: 'Seed build method',
    ),
    BondCurveBuildMethodFormData(
      id: 'USD_SPLINE',
      buildMethodCode: 'USD_SPLINE',
      name: 'USD Spline',
      fittingMethod: 'SplineFit',
      interpolationMethod: 'LinearZero',
      extrapolationMethod: 'FlatZero',
      dayCountConvention: 'ACT360',
      compoundingType: 'Continuous',
      businessDayConvention: 'ModifiedFollowing',
      calendarId: 'cal_2',
      calendarCode: 'USNY',
      settlementDays: 2,
      active: true,
      description: 'Seed build method',
    ),
  ];

  @override
  Future<List<ListItemModel>> getMasterList() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _masters
        .map(
          (item) => ListItemModel(
            id: item.id ?? item.curveCode,
            title: item.name,
            subtitle: item.curveCode,
          ),
        )
        .toList();
  }

  @override
  Future<BondCurveMasterFormData?> getMasterById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    for (final item in _masters) {
      if ((item.id ?? item.curveCode) == id) return item;
    }
    return null;
  }

  @override
  Future<BondCurveMasterFormData> createMaster(
    BondCurveMasterFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final created = data.copyWith(id: data.curveCode);
    _masters.insert(0, created);
    return created;
  }

  @override
  Future<BondCurveMasterFormData> updateMaster(
    BondCurveMasterFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final id = (data.id ?? data.curveCode).trim();
    final index = _masters.indexWhere(
      (item) => (item.id ?? item.curveCode) == id,
    );
    if (index < 0) {
      throw StateError('BondCurveMaster not found: $id');
    }
    _masters[index] = data.copyWith(id: _masters[index].id ?? id);
    return _masters[index];
  }

  @override
  Future<void> deleteMaster(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _masters.removeWhere((item) => (item.id ?? item.curveCode) == id);
  }

  @override
  Future<List<ListItemModel>> getBuildMethodList() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _buildMethods
        .map(
          (item) => ListItemModel(
            id: item.id ?? item.buildMethodCode,
            title: item.name,
            subtitle: item.buildMethodCode,
          ),
        )
        .toList();
  }

  @override
  Future<BondCurveBuildMethodFormData?> getBuildMethodById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    for (final item in _buildMethods) {
      if ((item.id ?? item.buildMethodCode) == id) return item;
    }
    return null;
  }

  @override
  Future<BondCurveBuildMethodFormData> createBuildMethod(
    BondCurveBuildMethodFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final created = data.copyWith(id: data.buildMethodCode);
    _buildMethods.insert(0, created);
    return created;
  }

  @override
  Future<BondCurveBuildMethodFormData> updateBuildMethod(
    BondCurveBuildMethodFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final id = (data.id ?? data.buildMethodCode).trim();
    final index = _buildMethods.indexWhere(
      (item) => (item.id ?? item.buildMethodCode) == id,
    );
    if (index < 0) {
      throw StateError('BondCurveBuildMethod not found: $id');
    }
    _buildMethods[index] = data.copyWith(id: _buildMethods[index].id ?? id);
    return _buildMethods[index];
  }

  @override
  Future<void> deleteBuildMethod(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _buildMethods.removeWhere(
      (item) => (item.id ?? item.buildMethodCode) == id,
    );
  }
}
