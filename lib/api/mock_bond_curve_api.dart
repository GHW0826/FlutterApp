import 'dart:async';

import '../models/bond_curve_build_method_form_data.dart';
import '../models/bond_curve_enums.dart';
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
      id: 'bcm_1',
      name: 'KRW_GOVT_BOND',
      currencyId: 'KRW',
      purpose: CurvePurpose.benchmark,
      issuerType: BondCurveIssuerType.govt,
      onTheRunOnly: true,
      minRemainingYears: 0.25,
      minOutstandingAmount: 50000000000,
      outputIncludesYtm: true,
      outputIncludesZero: true,
      outputIncludesDf: true,
      activeFlag: true,
      validFrom: DateTime(2026, 1, 1),
      description: 'KRW sovereign benchmark curve',
    ),
    BondCurveMasterFormData(
      id: 'bcm_2',
      name: 'USD_CORP_DISCOUNT',
      currencyId: 'USD',
      purpose: CurvePurpose.discounting,
      issuerType: BondCurveIssuerType.corp,
      onTheRunOnly: false,
      outputIncludesYtm: true,
      outputIncludesZero: true,
      outputIncludesDf: true,
      activeFlag: true,
      description: 'USD corporate discounting',
    ),
  ];

  static List<BondCurveBuildMethodFormData> get _seedBuildMethods => [
    BondCurveBuildMethodFormData(
      id: 'bcmth_1',
      name: 'KRW_GOVT_SPLINE_LOGLINEAR_DF',
      fittingMethod: CurveFittingMethod.splineFit,
      interpolationMethod: CurveInterpolationMethod.logLinearDf,
      extrapolationMethod: ExtrapolationMethod.flatFwd,
      dayCount: DayCountConvention.act365f,
      compoundingType: CurveCompoundingType.compounded,
      compoundingFrequency: CompoundingFrequency.semiAnnual,
      businessDayConvention: BusinessDayConvention.following,
      calendarId: 'KR',
      settlementDays: 1,
      description: 'Default KRW government curve recipe',
    ),
    BondCurveBuildMethodFormData(
      id: 'bcmth_2',
      name: 'USD_CORP_BOOTSTRAP_FLAT_ZERO',
      fittingMethod: CurveFittingMethod.bootstrap,
      interpolationMethod: CurveInterpolationMethod.linearZero,
      extrapolationMethod: ExtrapolationMethod.flatZero,
      dayCount: DayCountConvention.act360,
      compoundingType: CurveCompoundingType.continuous,
      businessDayConvention: BusinessDayConvention.modifiedFollowing,
      calendarId: 'US',
      settlementDays: 2,
    ),
  ];

  @override
  Future<List<ListItemModel>> getMasterList() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _masters
        .map(
          (e) => ListItemModel(
            id: e.id ?? '',
            title: e.name,
            subtitle:
                '${e.currencyId} | ${e.purpose.label} | ${e.issuerType.label}',
          ),
        )
        .toList();
  }

  @override
  Future<BondCurveMasterFormData?> getMasterById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    try {
      return _masters.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BondCurveMasterFormData> createMaster(
    BondCurveMasterFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final created = data.copyWith(
      id: 'bcm_${DateTime.now().millisecondsSinceEpoch}',
    );
    _masters.insert(0, created);
    return created;
  }

  @override
  Future<BondCurveMasterFormData> updateMaster(
    BondCurveMasterFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final id = data.id;
    if (id == null || id.trim().isEmpty) {
      throw StateError('BondCurveMaster id is empty.');
    }
    final idx = _masters.indexWhere((e) => e.id == id);
    if (idx < 0) {
      throw StateError('BondCurveMaster not found: $id');
    }
    _masters[idx] = data;
    return data;
  }

  @override
  Future<void> deleteMaster(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _masters.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<ListItemModel>> getBuildMethodList() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _buildMethods
        .map(
          (e) => ListItemModel(
            id: e.id ?? '',
            title: e.name,
            subtitle:
                '${e.fittingMethod.label} | ${e.interpolationMethod.label}',
          ),
        )
        .toList();
  }

  @override
  Future<BondCurveBuildMethodFormData?> getBuildMethodById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    try {
      return _buildMethods.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BondCurveBuildMethodFormData> createBuildMethod(
    BondCurveBuildMethodFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final created = data.copyWith(
      id: 'bcmth_${DateTime.now().millisecondsSinceEpoch}',
    );
    _buildMethods.insert(0, created);
    return created;
  }

  @override
  Future<BondCurveBuildMethodFormData> updateBuildMethod(
    BondCurveBuildMethodFormData data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final id = data.id;
    if (id == null || id.trim().isEmpty) {
      throw StateError('BondCurveBuildMethod id is empty.');
    }
    final idx = _buildMethods.indexWhere((e) => e.id == id);
    if (idx < 0) {
      throw StateError('BondCurveBuildMethod not found: $id');
    }
    _buildMethods[idx] = data;
    return data;
  }

  @override
  Future<void> deleteBuildMethod(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _buildMethods.removeWhere((e) => e.id == id);
  }
}
