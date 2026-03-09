import 'bond_curve_enums.dart';

class BondCurveMasterFormData {
  BondCurveMasterFormData({
    this.id,
    this.name = '',
    this.currencyId = '',
    this.purpose = CurvePurpose.benchmark,
    this.issuerType = BondCurveIssuerType.govt,
    this.onTheRunOnly = false,
    this.minRemainingYears,
    this.minOutstandingAmount,
    this.outputIncludesYtm = true,
    this.outputIncludesZero = true,
    this.outputIncludesDf = true,
    this.activeFlag = true,
    this.validFrom,
    this.validTo,
    this.description = '',
  });

  final String? id;
  final String name;
  final String currencyId;
  final CurvePurpose purpose;
  final BondCurveIssuerType issuerType;
  final bool onTheRunOnly;
  final double? minRemainingYears;
  final double? minOutstandingAmount;
  final bool outputIncludesYtm;
  final bool outputIncludesZero;
  final bool outputIncludesDf;
  final bool activeFlag;
  final DateTime? validFrom;
  final DateTime? validTo;
  final String description;

  BondCurveMasterFormData copyWith({
    String? id,
    String? name,
    String? currencyId,
    CurvePurpose? purpose,
    BondCurveIssuerType? issuerType,
    bool? onTheRunOnly,
    double? minRemainingYears,
    double? minOutstandingAmount,
    bool? outputIncludesYtm,
    bool? outputIncludesZero,
    bool? outputIncludesDf,
    bool? activeFlag,
    DateTime? validFrom,
    DateTime? validTo,
    String? description,
  }) {
    return BondCurveMasterFormData(
      id: id ?? this.id,
      name: name ?? this.name,
      currencyId: currencyId ?? this.currencyId,
      purpose: purpose ?? this.purpose,
      issuerType: issuerType ?? this.issuerType,
      onTheRunOnly: onTheRunOnly ?? this.onTheRunOnly,
      minRemainingYears: minRemainingYears ?? this.minRemainingYears,
      minOutstandingAmount: minOutstandingAmount ?? this.minOutstandingAmount,
      outputIncludesYtm: outputIncludesYtm ?? this.outputIncludesYtm,
      outputIncludesZero: outputIncludesZero ?? this.outputIncludesZero,
      outputIncludesDf: outputIncludesDf ?? this.outputIncludesDf,
      activeFlag: activeFlag ?? this.activeFlag,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      description: description ?? this.description,
    );
  }
}
