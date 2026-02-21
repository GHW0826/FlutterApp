// Enums used in Bond forms and API payload mapping.

enum Ccy {
  krw('KRW', 'KRW'),
  usd('USD', 'USD'),
  eur('EUR', 'EUR'),
  jpy('JPY', 'JPY'),
  gbp('GBP', 'GBP');

  const Ccy(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static Ccy? fromApi(String? value) {
    if (value == null) return null;
    for (final item in Ccy.values) {
      if (item.apiValue.toLowerCase() == value.toLowerCase()) return item;
    }
    return null;
  }
}

enum IntPayMethod {
  zeroCouponBond('Zero Coupon Bond', 'ZeroCouponBond'),
  compoundInterestBond('Compound Interest Bond', 'CompoundInterestBond'),
  couponBond('Coupon Bond', 'CouponBond'),
  simpleInterestBond('Simple Interest Bond', 'SimpleInterestBond'),
  compoundThenSimple('Compound Then Simple', 'CompoundThenSimple'),
  otherFixedRate('Other Fixed Rate', 'OtherFixedRate'),
  floatingRateCouponBond('Floating Rate Coupon Bond', 'FloatingRateCouponBond'),
  otherFloatingRate('Other Floating Rate', 'OtherFloatingRate');

  const IntPayMethod(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static IntPayMethod? fromApi(String? value) {
    if (value == null) return null;
    for (final item in IntPayMethod.values) {
      if (item.apiValue.toLowerCase() == value.toLowerCase()) return item;
    }
    return null;
  }
}

enum LiquiditySect {
  high('High', 'HIGH'),
  medium('Medium', 'MEDIUM'),
  low('Low', 'LOW');

  const LiquiditySect(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static LiquiditySect? fromApi(String? value) {
    if (value == null) return null;
    for (final item in LiquiditySect.values) {
      if (item.apiValue.toLowerCase() == value.toLowerCase()) return item;
    }
    return null;
  }
}

enum SubordSect {
  none('None', 'NONE'),
  senior('Senior', 'Senior'),
  mezzanine('Mezzanine', 'Mezzanine'),
  subordinated('Subordinated', 'Subordinated'),
  deepSubordinated('Deep Subordinated', 'DeepSubordinated');

  const SubordSect(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static SubordSect? fromApi(String? value) {
    if (value == null) return null;
    for (final item in SubordSect.values) {
      if (item.apiValue.toLowerCase() == value.toLowerCase()) return item;
    }
    return null;
  }
}

enum OriginSource {
  domestic('Domestic', 'Domestic'),
  international('International', 'International'),
  other('Other', 'None');

  const OriginSource(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static OriginSource? fromApi(String? value) {
    if (value == null) return null;
    for (final item in OriginSource.values) {
      if (item.apiValue.toLowerCase() == value.toLowerCase()) return item;
    }
    return null;
  }
}

enum AssetSecuritizationClassification {
  none('None', 'NONE'),
  assetBackedSecurityBondType('ABS Bond Type', 'AssetBackedSecurityBondType'),
  assetBackedSecurityBeneficialCertificateType(
    'ABS Beneficial Certificate Type',
    'AssetBackedSecurityBeneficialCertificateType',
  ),
  assetBackedSecurityNonStandardType('ABS Non-Standard Type', 'AssetBackedSecurityNonStandardType'),
  mortgageBackedSecurityBondType('MBS Bond Type', 'MortgageBackedSecurityBondType'),
  mortgageBackedSecurityBeneficialCertificateType(
    'MBS Beneficial Certificate Type',
    'MortgageBackedSecurityBeneficialCertificateType',
  );

  const AssetSecuritizationClassification(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static AssetSecuritizationClassification? fromApi(String? value) {
    if (value == null) return null;
    for (final item in AssetSecuritizationClassification.values) {
      if (item.apiValue.toLowerCase() == value.toLowerCase()) return item;
    }
    return null;
  }
}

enum ListingSection {
  listed('Listed', 'Listed'),
  nonlisted('Nonlisted', 'Nonlisted'),
  other('Other', 'Other'),
  called('Called', 'Called');

  const ListingSection(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static ListingSection? fromApi(String? value) {
    if (value == null) return null;
    for (final item in ListingSection.values) {
      if (item.apiValue.toLowerCase() == value.toLowerCase()) return item;
    }
    return null;
  }
}

enum SourceCode {
  none('None', 'None'),
  isda('ISDA', 'ISDA'),
  bloomberg('Bloomberg', 'Bloomberg'),
  reuters('Reuters', 'Reuters'),
  isin('ISIN', 'ISIN'),
  iso20022('ISO20022', 'ISO20022'),
  krx('KRX', 'KRX'),
  cusip('CUSIP', 'CUSIP'),
  sedol('SEDOL', 'SEDOL'),
  msci('MSCI', 'MSCI'),
  lei('LEI', 'LEI'),
  isinIssuerCode('ISIN Issuer Code', 'ISINIssuerCode'),
  krxListedCompanyCode('KRX Listed Company Code', 'KRXListedCompanyCode'),
  otc('OTC', 'OTC'),
  iso3166('ISO3166', 'ISO3166'),
  bic('BIC', 'BIC'),
  red6('RED6', 'RED6'),
  red9('RED9', 'RED9'),
  iso3166PlusBic4('ISO3166 + BIC4', 'ISO3166PlusBIC4'),
  others('Others', 'Others'),
  fpml('FpML', 'FpML');

  const SourceCode(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static SourceCode? fromApi(String? value) {
    if (value == null) return null;
    for (final item in SourceCode.values) {
      if (item.apiValue.toLowerCase() == value.toLowerCase()) return item;
    }
    return null;
  }
}

enum EntityOriginCode {
  kr('KR', 'KR'),
  us('US', 'US'),
  eu('EU', 'EU'),
  jp('JP', 'JP'),
  other('Other', 'OTHER');

  const EntityOriginCode(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static EntityOriginCode? fromApi(String? value) {
    if (value == null) return null;
    for (final item in EntityOriginCode.values) {
      if (item.apiValue.toLowerCase() == value.toLowerCase()) return item;
    }
    return null;
  }
}

enum IssueKind {
  government('Government', 'GOV'),
  corporate('Corporate', 'CORP'),
  financial('Financial', 'FIN'),
  other('Other', 'OTHER');

  const IssueKind(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static IssueKind? fromApi(String? value) {
    if (value == null) return null;
    for (final item in IssueKind.values) {
      if (item.apiValue.toLowerCase() == value.toLowerCase()) return item;
    }
    return null;
  }
}

enum IssuePurpose {
  refinancing('Refinancing', 'FUNDING'),
  capital('Capital', 'CAPITAL'),
  project('Project', 'PROJECT'),
  other('Other', 'OTHER');

  const IssuePurpose(this.label, this.apiValue);
  final String label;
  final String apiValue;

  static IssuePurpose? fromApi(String? value) {
    if (value == null) return null;
    for (final item in IssuePurpose.values) {
      if (item.apiValue.toLowerCase() == value.toLowerCase()) return item;
    }
    return null;
  }
}
