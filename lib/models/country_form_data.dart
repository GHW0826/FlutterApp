class CountryFormData {
  const CountryFormData({
    this.id,
    this.countryIso2 = '',
    this.countryIso3 = '',
    this.numericCode = '',
    this.name = '',
    this.timezone = 'Asia/Seoul',
    this.active = true,
    this.description = '',
  });

  final String? id;
  final String countryIso2;
  final String countryIso3;
  final String numericCode;
  final String name;
  final String timezone;
  final bool active;
  final String description;

  String get displayCode => countryIso3.isNotEmpty ? countryIso3 : countryIso2;

  CountryFormData copyWith({
    String? id,
    String? countryIso2,
    String? countryIso3,
    String? numericCode,
    String? name,
    String? timezone,
    bool? active,
    String? description,
  }) {
    return CountryFormData(
      id: id ?? this.id,
      countryIso2: countryIso2 ?? this.countryIso2,
      countryIso3: countryIso3 ?? this.countryIso3,
      numericCode: numericCode ?? this.numericCode,
      name: name ?? this.name,
      timezone: timezone ?? this.timezone,
      active: active ?? this.active,
      description: description ?? this.description,
    );
  }
}
