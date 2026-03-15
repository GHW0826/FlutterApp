import 'bond_enums.dart';

enum HolidayCity {
  seoul('Seoul'),
  newYork('New York'),
  london('London'),
  tokyo('Tokyo');

  const HolidayCity(this.label);
  final String label;
}

enum HolidayAdjustmentRule {
  following('Following'),
  preceding('Preceding'),
  modifiedFollowing('Modified Following');

  const HolidayAdjustmentRule(this.label);
  final String label;
}

enum CouponFrequency {
  monthly('Monthly'),
  quarterly('Quarterly'),
  semiAnnual('Semi Annual'),
  annual('Annual');

  const CouponFrequency(this.label);
  final String label;
}

enum PaymentFrequency {
  monthly('Monthly'),
  quarterly('Quarterly'),
  semiAnnual('Semi Annual'),
  annual('Annual');

  const PaymentFrequency(this.label);
  final String label;
}

class CouponPeriodRow {
  const CouponPeriodRow({
    required this.no,
    required this.startDate,
    required this.endDate,
    required this.paymentDate,
  });

  final int no;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime paymentDate;
}

class UnderlyingBondFormData {
  const UnderlyingBondFormData({
    this.id,
    this.name = '',
    this.marketDataCode = '',
    this.marketDataName = '',
    this.ccy,
    this.holidayCity,
    this.holidayRule,
    this.couponFrequency,
    this.paymentFrequency,
    this.couponPeriods = const [],
  });

  final String? id;
  final String name;
  final String marketDataCode;
  final String marketDataName;
  final Ccy? ccy;
  final HolidayCity? holidayCity;
  final HolidayAdjustmentRule? holidayRule;
  final CouponFrequency? couponFrequency;
  final PaymentFrequency? paymentFrequency;
  final List<CouponPeriodRow> couponPeriods;

  UnderlyingBondFormData copyWith({
    String? id,
    String? name,
    String? marketDataCode,
    String? marketDataName,
    Ccy? ccy,
    HolidayCity? holidayCity,
    HolidayAdjustmentRule? holidayRule,
    CouponFrequency? couponFrequency,
    PaymentFrequency? paymentFrequency,
    List<CouponPeriodRow>? couponPeriods,
  }) {
    return UnderlyingBondFormData(
      id: id ?? this.id,
      name: name ?? this.name,
      marketDataCode: marketDataCode ?? this.marketDataCode,
      marketDataName: marketDataName ?? this.marketDataName,
      ccy: ccy ?? this.ccy,
      holidayCity: holidayCity ?? this.holidayCity,
      holidayRule: holidayRule ?? this.holidayRule,
      couponFrequency: couponFrequency ?? this.couponFrequency,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      couponPeriods: couponPeriods ?? this.couponPeriods,
    );
  }
}
