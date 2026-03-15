enum CurvePurpose {
  benchmark('BENCHMARK'),
  discounting('DISCOUNTING'),
  spread('SPREAD');

  const CurvePurpose(this.label);
  final String label;
}

enum BondCurveIssuerType {
  govt('GOVT'),
  agency('AGENCY'),
  corp('CORP');

  const BondCurveIssuerType(this.label);
  final String label;
}

enum CurveFittingMethod {
  bootstrap('BOOTSTRAP'),
  splineFit('SPLINE_FIT'),
  nelsonSiegel('NELSON_SIEGEL'),
  svensson('SVENSSON');

  const CurveFittingMethod(this.label);
  final String label;
}

enum CurveInterpolationMethod {
  logLinearDf('LOGLINEAR_DF'),
  linearZero('LINEAR_ZERO'),
  linearDf('LINEAR_DF');

  const CurveInterpolationMethod(this.label);
  final String label;
}

enum ExtrapolationMethod {
  flatFwd('FLAT_FWD'),
  flatZero('FLAT_ZERO');

  const ExtrapolationMethod(this.label);
  final String label;
}

enum DayCountConvention {
  act365f('ACT/365F'),
  act360('ACT/360'),
  thirty360('30/360');

  const DayCountConvention(this.label);
  final String label;
}

enum CurveCompoundingType {
  compounded('COMPOUNDED'),
  continuous('CONTINUOUS'),
  simple('SIMPLE');

  const CurveCompoundingType(this.label);
  final String label;
}

enum CompoundingFrequency {
  annual('ANNUAL'),
  semiAnnual('SEMI_ANNUAL'),
  quarterly('QUARTERLY'),
  monthly('MONTHLY');

  const CompoundingFrequency(this.label);
  final String label;
}

enum BusinessDayConvention {
  following('FOLLOWING'),
  modifiedFollowing('MODIFIED_FOLLOWING'),
  preceding('PRECEDING'),
  unadjusted('UNADJUSTED');

  const BusinessDayConvention(this.label);
  final String label;
}
