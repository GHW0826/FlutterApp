import 'bond_curve_enums.dart';

class BondCurveBuildMethodFormData {
  BondCurveBuildMethodFormData({
    this.id,
    this.name = '',
    this.fittingMethod = CurveFittingMethod.bootstrap,
    this.interpolationMethod = CurveInterpolationMethod.logLinearDf,
    this.extrapolationMethod = ExtrapolationMethod.flatFwd,
    this.dayCount = DayCountConvention.act365f,
    this.compoundingType = CurveCompoundingType.compounded,
    this.compoundingFrequency,
    this.businessDayConvention = BusinessDayConvention.following,
    this.calendarId = '',
    this.settlementDays,
    this.description = '',
  });

  final String? id;
  final String name;
  final CurveFittingMethod fittingMethod;
  final CurveInterpolationMethod interpolationMethod;
  final ExtrapolationMethod extrapolationMethod;
  final DayCountConvention dayCount;
  final CurveCompoundingType compoundingType;
  final CompoundingFrequency? compoundingFrequency;
  final BusinessDayConvention businessDayConvention;
  final String calendarId;
  final int? settlementDays;
  final String description;

  BondCurveBuildMethodFormData copyWith({
    String? id,
    String? name,
    CurveFittingMethod? fittingMethod,
    CurveInterpolationMethod? interpolationMethod,
    ExtrapolationMethod? extrapolationMethod,
    DayCountConvention? dayCount,
    CurveCompoundingType? compoundingType,
    CompoundingFrequency? compoundingFrequency,
    BusinessDayConvention? businessDayConvention,
    String? calendarId,
    int? settlementDays,
    String? description,
  }) {
    return BondCurveBuildMethodFormData(
      id: id ?? this.id,
      name: name ?? this.name,
      fittingMethod: fittingMethod ?? this.fittingMethod,
      interpolationMethod: interpolationMethod ?? this.interpolationMethod,
      extrapolationMethod: extrapolationMethod ?? this.extrapolationMethod,
      dayCount: dayCount ?? this.dayCount,
      compoundingType: compoundingType ?? this.compoundingType,
      compoundingFrequency: compoundingFrequency ?? this.compoundingFrequency,
      businessDayConvention:
          businessDayConvention ?? this.businessDayConvention,
      calendarId: calendarId ?? this.calendarId,
      settlementDays: settlementDays ?? this.settlementDays,
      description: description ?? this.description,
    );
  }
}
