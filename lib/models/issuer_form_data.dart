class IssuerFormData {
  const IssuerFormData({
    this.id,
    this.issuerCode = '',
    this.code = '',
    this.name = '',
    this.shortName = '',
    this.countryId = '',
    this.countryIso2 = '',
    this.lei = '',
    this.parentIssuerId = '',
    this.parentIssuerCode = '',
    this.groupFlag = false,
    this.activeFlag = true,
    this.description = '',
  });

  final String? id;
  final String issuerCode;
  final String code;
  final String name;
  final String shortName;
  final String countryId;
  final String countryIso2;
  final String lei;
  final String parentIssuerId;
  final String parentIssuerCode;
  final bool groupFlag;
  final bool activeFlag;
  final String description;

  IssuerFormData copyWith({
    String? id,
    String? issuerCode,
    String? code,
    String? name,
    String? shortName,
    String? countryId,
    String? countryIso2,
    String? lei,
    String? parentIssuerId,
    String? parentIssuerCode,
    bool? groupFlag,
    bool? activeFlag,
    String? description,
  }) {
    return IssuerFormData(
      id: id ?? this.id,
      issuerCode: issuerCode ?? this.issuerCode,
      code: code ?? this.code,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      countryId: countryId ?? this.countryId,
      countryIso2: countryIso2 ?? this.countryIso2,
      lei: lei ?? this.lei,
      parentIssuerId: parentIssuerId ?? this.parentIssuerId,
      parentIssuerCode: parentIssuerCode ?? this.parentIssuerCode,
      groupFlag: groupFlag ?? this.groupFlag,
      activeFlag: activeFlag ?? this.activeFlag,
      description: description ?? this.description,
    );
  }
}
