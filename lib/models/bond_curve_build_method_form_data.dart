class BondCurveBuildMethodFormData {
  const BondCurveBuildMethodFormData({
    this.id,
    this.buildMethodCode = '',
    this.name = '',
    this.fittingMethod = '',
    this.interpolationMethod = '',
    this.extrapolationMethod = '',
    this.dayCountConvention = '',
    this.compoundingType = '',
    this.compoundingFrequency = '',
    this.businessDayConvention = '',
    this.calendarId = '',
    this.calendarCode = '',
    this.settlementDays,
    this.active = true,
    this.description = '',
  });

  final String? id;
  final String buildMethodCode;
  final String name;
  final String fittingMethod;
  final String interpolationMethod;
  final String extrapolationMethod;
  final String dayCountConvention;
  final String compoundingType;
  final String compoundingFrequency;
  final String businessDayConvention;
  final String calendarId;
  final String calendarCode;
  final int? settlementDays;
  final bool active;
  final String description;

  BondCurveBuildMethodFormData copyWith({
    String? id,
    String? buildMethodCode,
    String? name,
    String? fittingMethod,
    String? interpolationMethod,
    String? extrapolationMethod,
    String? dayCountConvention,
    String? compoundingType,
    String? compoundingFrequency,
    String? businessDayConvention,
    String? calendarId,
    String? calendarCode,
    int? settlementDays,
    bool? active,
    String? description,
  }) {
    return BondCurveBuildMethodFormData(
      id: id ?? this.id,
      buildMethodCode: buildMethodCode ?? this.buildMethodCode,
      name: name ?? this.name,
      fittingMethod: fittingMethod ?? this.fittingMethod,
      interpolationMethod: interpolationMethod ?? this.interpolationMethod,
      extrapolationMethod: extrapolationMethod ?? this.extrapolationMethod,
      dayCountConvention: dayCountConvention ?? this.dayCountConvention,
      compoundingType: compoundingType ?? this.compoundingType,
      compoundingFrequency: compoundingFrequency ?? this.compoundingFrequency,
      businessDayConvention:
          businessDayConvention ?? this.businessDayConvention,
      calendarId: calendarId ?? this.calendarId,
      calendarCode: calendarCode ?? this.calendarCode,
      settlementDays: settlementDays ?? this.settlementDays,
      active: active ?? this.active,
      description: description ?? this.description,
    );
  }
}
