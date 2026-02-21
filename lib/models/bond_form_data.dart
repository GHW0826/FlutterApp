import 'bond_enums.dart';

/// Bond 신규/수정 폼 데이터
class BondFormData {
  BondFormData({
    this.id,
    this.marketCode = '',
    this.name = '',
    this.ccy,
    this.intPayMethod,
    this.liquiditySect,
    this.subordSect,
    this.issueDate,
    this.maturityDate,
    this.source = '',
    this.sourceCode,
    this.originSource,
    this.originCode = '',
    this.entityOriginSource = '',
    this.entityOriginCode,
    this.issueKind,
    this.issuePurpose,
    this.listingSection,
    this.assetSecuritizationClassification,
    this.description = '',
  });

  final String? id;
  final String marketCode;
  final String name;
  final Ccy? ccy;
  final IntPayMethod? intPayMethod;
  final LiquiditySect? liquiditySect;
  final SubordSect? subordSect;
  final DateTime? issueDate;
  final DateTime? maturityDate;
  final String source;
  final SourceCode? sourceCode;
  final OriginSource? originSource;
  final String originCode;
  final String entityOriginSource;
  final EntityOriginCode? entityOriginCode;
  final IssueKind? issueKind;
  final IssuePurpose? issuePurpose;
  final ListingSection? listingSection;
  final AssetSecuritizationClassification? assetSecuritizationClassification;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'marketCode': marketCode,
      'name': name,
      if (ccy != null) 'ccy': ccy!.name,
      if (intPayMethod != null) 'intPayMethod': intPayMethod!.name,
      if (liquiditySect != null) 'liquiditySect': liquiditySect!.name,
      if (subordSect != null) 'subordSect': subordSect!.name,
      if (issueDate != null) 'issueDate': issueDate!.toIso8601String(),
      if (maturityDate != null) 'maturityDate': maturityDate!.toIso8601String(),
      'source': source,
      if (sourceCode != null) 'sourceCode': sourceCode!.name,
      if (originSource != null) 'originSource': originSource!.name,
      'originCode': originCode,
      'entityOriginSource': entityOriginSource,
      if (entityOriginCode != null) 'entityOriginCode': entityOriginCode!.name,
      if (issueKind != null) 'issueKind': issueKind!.name,
      if (issuePurpose != null) 'issuePurpose': issuePurpose!.name,
      if (listingSection != null) 'listingSection': listingSection!.name,
      if (assetSecuritizationClassification != null)
        'assetSecuritizationClassification': assetSecuritizationClassification!.name,
      'description': description,
    };
  }

  static BondFormData fromJson(Map<String, dynamic> json) {
    return BondFormData(
      id: json['id'] as String?,
      marketCode: (json['marketCode'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      ccy: json['ccy'] != null ? _enumByName(Ccy.values, json['ccy'] as String) : null,
      intPayMethod: json['intPayMethod'] != null ? _enumByName(IntPayMethod.values, json['intPayMethod'] as String) : null,
      liquiditySect: json['liquiditySect'] != null ? _enumByName(LiquiditySect.values, json['liquiditySect'] as String) : null,
      subordSect: json['subordSect'] != null ? _enumByName(SubordSect.values, json['subordSect'] as String) : null,
      issueDate: json['issueDate'] != null ? DateTime.tryParse(json['issueDate'] as String) : null,
      maturityDate: json['maturityDate'] != null ? DateTime.tryParse(json['maturityDate'] as String) : null,
      source: (json['source'] as String?) ?? '',
      sourceCode: json['sourceCode'] != null ? _enumByName(SourceCode.values, json['sourceCode'] as String) : null,
      originSource: json['originSource'] != null ? _enumByName(OriginSource.values, json['originSource'] as String) : null,
      originCode: (json['originCode'] as String?) ?? '',
      entityOriginSource: (json['entityOriginSource'] as String?) ?? '',
      entityOriginCode: json['entityOriginCode'] != null ? _enumByName(EntityOriginCode.values, json['entityOriginCode'] as String) : null,
      issueKind: json['issueKind'] != null ? _enumByName(IssueKind.values, json['issueKind'] as String) : null,
      issuePurpose: json['issuePurpose'] != null ? _enumByName(IssuePurpose.values, json['issuePurpose'] as String) : null,
      listingSection: json['listingSection'] != null ? _enumByName(ListingSection.values, json['listingSection'] as String) : null,
      assetSecuritizationClassification:
          json['assetSecuritizationClassification'] != null
              ? _enumByName(
                  AssetSecuritizationClassification.values,
                  json['assetSecuritizationClassification'] as String,
                )
              : null,
      description: (json['description'] as String?) ?? '',
    );
  }

  static T? _enumByName<T>(List<T> values, String name) {
    try {
      return values.firstWhere((e) => (e as dynamic).name == name);
    } catch (_) {
      return null;
    }
  }

  BondFormData copyWith({
    String? id,
    String? marketCode,
    String? name,
    Ccy? ccy,
    IntPayMethod? intPayMethod,
    LiquiditySect? liquiditySect,
    SubordSect? subordSect,
    DateTime? issueDate,
    DateTime? maturityDate,
    String? source,
    SourceCode? sourceCode,
    OriginSource? originSource,
    String? originCode,
    String? entityOriginSource,
    EntityOriginCode? entityOriginCode,
    IssueKind? issueKind,
    IssuePurpose? issuePurpose,
    ListingSection? listingSection,
    AssetSecuritizationClassification? assetSecuritizationClassification,
    String? description,
  }) {
    return BondFormData(
      id: id ?? this.id,
      marketCode: marketCode ?? this.marketCode,
      name: name ?? this.name,
      ccy: ccy ?? this.ccy,
      intPayMethod: intPayMethod ?? this.intPayMethod,
      liquiditySect: liquiditySect ?? this.liquiditySect,
      subordSect: subordSect ?? this.subordSect,
      issueDate: issueDate ?? this.issueDate,
      maturityDate: maturityDate ?? this.maturityDate,
      source: source ?? this.source,
      sourceCode: sourceCode ?? this.sourceCode,
      originSource: originSource ?? this.originSource,
      originCode: originCode ?? this.originCode,
      entityOriginSource: entityOriginSource ?? this.entityOriginSource,
      entityOriginCode: entityOriginCode ?? this.entityOriginCode,
      issueKind: issueKind ?? this.issueKind,
      issuePurpose: issuePurpose ?? this.issuePurpose,
      listingSection: listingSection ?? this.listingSection,
      assetSecuritizationClassification:
          assetSecuritizationClassification ?? this.assetSecuritizationClassification,
      description: description ?? this.description,
    );
  }
}
