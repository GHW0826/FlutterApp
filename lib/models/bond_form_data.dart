class BondFormData {
  const BondFormData({
    this.id,
    this.marketCode = '',
    this.vendorId = '',
    this.vendorName = '',
    this.name = '',
    this.currencyId = '',
    this.currencyCode = '',
    this.defaultTradingContextId = '',
    this.defaultValuationContextId = '',
    this.description = '',
    this.isin = '',
    this.issuerId = '',
    this.issuerName = '',
    this.issueDate,
    this.maturityDate,
    this.couponType = '',
    this.couponRate,
    this.couponFrequency = '',
    this.dayCountConvention = '',
    this.faceValue,
    this.redemption,
  });

  final String? id;
  final String marketCode;
  final String vendorId;
  final String vendorName;
  final String name;
  final String currencyId;
  final String currencyCode;
  final String defaultTradingContextId;
  final String defaultValuationContextId;
  final String description;
  final String isin;
  final String issuerId;
  final String issuerName;
  final DateTime? issueDate;
  final DateTime? maturityDate;
  final String couponType;
  final double? couponRate;
  final String couponFrequency;
  final String dayCountConvention;
  final double? faceValue;
  final double? redemption;

  BondFormData copyWith({
    String? id,
    String? marketCode,
    String? vendorId,
    String? vendorName,
    String? name,
    String? currencyId,
    String? currencyCode,
    String? defaultTradingContextId,
    String? defaultValuationContextId,
    String? description,
    String? isin,
    String? issuerId,
    String? issuerName,
    DateTime? issueDate,
    DateTime? maturityDate,
    String? couponType,
    double? couponRate,
    String? couponFrequency,
    String? dayCountConvention,
    double? faceValue,
    double? redemption,
  }) {
    return BondFormData(
      id: id ?? this.id,
      marketCode: marketCode ?? this.marketCode,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      name: name ?? this.name,
      currencyId: currencyId ?? this.currencyId,
      currencyCode: currencyCode ?? this.currencyCode,
      defaultTradingContextId:
          defaultTradingContextId ?? this.defaultTradingContextId,
      defaultValuationContextId:
          defaultValuationContextId ?? this.defaultValuationContextId,
      description: description ?? this.description,
      isin: isin ?? this.isin,
      issuerId: issuerId ?? this.issuerId,
      issuerName: issuerName ?? this.issuerName,
      issueDate: issueDate ?? this.issueDate,
      maturityDate: maturityDate ?? this.maturityDate,
      couponType: couponType ?? this.couponType,
      couponRate: couponRate ?? this.couponRate,
      couponFrequency: couponFrequency ?? this.couponFrequency,
      dayCountConvention: dayCountConvention ?? this.dayCountConvention,
      faceValue: faceValue ?? this.faceValue,
      redemption: redemption ?? this.redemption,
    );
  }
}
