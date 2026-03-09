class IssuerFormData {
  const IssuerFormData({
    this.id,
    this.issuerCode = '',
    this.code = '',
    this.name = '',
    this.shortName = '',
    this.countryIso2 = '',
    this.lei = '',
    this.parentIssuerCode = '',
    this.activeFlag = true,
    this.description = '',
  });

  final String? id;
  final String issuerCode;
  final String code;
  final String name;
  final String shortName;
  final String countryIso2;
  final String lei;
  final String parentIssuerCode;
  final bool activeFlag;
  final String description;

  IssuerFormData copyWith({
    String? id,
    String? issuerCode,
    String? code,
    String? name,
    String? shortName,
    String? countryIso2,
    String? lei,
    String? parentIssuerCode,
    bool? activeFlag,
    String? description,
  }) {
    return IssuerFormData(
      id: id ?? this.id,
      issuerCode: issuerCode ?? this.issuerCode,
      code: code ?? this.code,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      countryIso2: countryIso2 ?? this.countryIso2,
      lei: lei ?? this.lei,
      parentIssuerCode: parentIssuerCode ?? this.parentIssuerCode,
      activeFlag: activeFlag ?? this.activeFlag,
      description: description ?? this.description,
    );
  }
}
