class BondCurveMasterFormData {
  const BondCurveMasterFormData({
    this.id,
    this.curveCode = '',
    this.name = '',
    this.currencyId = '',
    this.currencyCode = '',
    this.curveType = '',
    this.curvePurpose = '',
    this.rateRepresentation = '',
    this.active = true,
    this.validFrom,
    this.validTo,
    this.description = '',
    this.issuerId = '',
    this.issuerName = '',
    this.onTheRunOnly = false,
    this.minRemainingYears,
    this.minOutstandingAmount,
    this.outputIncludesYtm = true,
    this.outputIncludesZero = true,
    this.outputIncludesDf = true,
  });

  final String? id;
  final String curveCode;
  final String name;
  final String currencyId;
  final String currencyCode;
  final String curveType;
  final String curvePurpose;
  final String rateRepresentation;
  final bool active;
  final DateTime? validFrom;
  final DateTime? validTo;
  final String description;
  final String issuerId;
  final String issuerName;
  final bool onTheRunOnly;
  final double? minRemainingYears;
  final double? minOutstandingAmount;
  final bool outputIncludesYtm;
  final bool outputIncludesZero;
  final bool outputIncludesDf;

  BondCurveMasterFormData copyWith({
    String? id,
    String? curveCode,
    String? name,
    String? currencyId,
    String? currencyCode,
    String? curveType,
    String? curvePurpose,
    String? rateRepresentation,
    bool? active,
    DateTime? validFrom,
    DateTime? validTo,
    String? description,
    String? issuerId,
    String? issuerName,
    bool? onTheRunOnly,
    double? minRemainingYears,
    double? minOutstandingAmount,
    bool? outputIncludesYtm,
    bool? outputIncludesZero,
    bool? outputIncludesDf,
  }) {
    return BondCurveMasterFormData(
      id: id ?? this.id,
      curveCode: curveCode ?? this.curveCode,
      name: name ?? this.name,
      currencyId: currencyId ?? this.currencyId,
      currencyCode: currencyCode ?? this.currencyCode,
      curveType: curveType ?? this.curveType,
      curvePurpose: curvePurpose ?? this.curvePurpose,
      rateRepresentation: rateRepresentation ?? this.rateRepresentation,
      active: active ?? this.active,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      description: description ?? this.description,
      issuerId: issuerId ?? this.issuerId,
      issuerName: issuerName ?? this.issuerName,
      onTheRunOnly: onTheRunOnly ?? this.onTheRunOnly,
      minRemainingYears: minRemainingYears ?? this.minRemainingYears,
      minOutstandingAmount: minOutstandingAmount ?? this.minOutstandingAmount,
      outputIncludesYtm: outputIncludesYtm ?? this.outputIncludesYtm,
      outputIncludesZero: outputIncludesZero ?? this.outputIncludesZero,
      outputIncludesDf: outputIncludesDf ?? this.outputIncludesDf,
    );
  }
}
