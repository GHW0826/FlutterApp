import 'bond_enums.dart';

/// Bond create/edit form payload.
class BondFormData {
  BondFormData({
    this.id,
    this.marketCode = '',
    this.isin = '',
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
    this.exchange = '',
    this.tradingStatus,
    this.settlementDays,
    this.tradingCalendar,
    this.tickSize,
    this.lotSize,
    this.minOrderSize,
    this.maxOrderSize,
    this.clearingHouse = '',
    this.settlementCurrency = '',
    this.failHandlingRule,
    this.valuationDate,
    this.vendor = '',
    this.priceType,
    this.discountCurve = '',
    this.creditCurve = '',
    this.fundingCurve = '',
    this.oisCurve = '',
    this.interpolationMethod,
    this.compoundingConvention,
    this.accruedHandling,
    this.snapshotEnabled = false,
    this.marketFrozen = false,
    this.regulatoryTag = '',
    this.curveVersion = '',
    this.description = '',
  });

  final String? id;
  final String marketCode;
  final String isin;
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
  final String exchange;
  final TradingStatus? tradingStatus;
  final int? settlementDays;
  final TradingCalendar? tradingCalendar;
  final double? tickSize;
  final double? lotSize;
  final double? minOrderSize;
  final double? maxOrderSize;
  final String clearingHouse;
  final String settlementCurrency;
  final FailHandlingRule? failHandlingRule;
  final DateTime? valuationDate;
  final String vendor;
  final PriceType? priceType;
  final String discountCurve;
  final String creditCurve;
  final String fundingCurve;
  final String oisCurve;
  final InterpolationMethod? interpolationMethod;
  final CompoundingConvention? compoundingConvention;
  final AccruedHandling? accruedHandling;
  final bool snapshotEnabled;
  final bool marketFrozen;
  final String regulatoryTag;
  final String curveVersion;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'marketCode': marketCode,
      'isin': isin,
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
        'assetSecuritizationClassification':
            assetSecuritizationClassification!.name,
      'exchange': exchange,
      if (tradingStatus != null) 'tradingStatus': tradingStatus!.name,
      if (settlementDays != null) 'settlementDays': settlementDays,
      if (tradingCalendar != null) 'tradingCalendar': tradingCalendar!.name,
      if (tickSize != null) 'tickSize': tickSize,
      if (lotSize != null) 'lotSize': lotSize,
      if (minOrderSize != null) 'minOrderSize': minOrderSize,
      if (maxOrderSize != null) 'maxOrderSize': maxOrderSize,
      'clearingHouse': clearingHouse,
      'settlementCurrency': settlementCurrency,
      if (failHandlingRule != null) 'failHandlingRule': failHandlingRule!.name,
      if (valuationDate != null)
        'valuationDate': valuationDate!.toIso8601String(),
      'vendor': vendor,
      if (priceType != null) 'priceType': priceType!.name,
      'discountCurve': discountCurve,
      'creditCurve': creditCurve,
      'fundingCurve': fundingCurve,
      'oisCurve': oisCurve,
      if (interpolationMethod != null)
        'interpolationMethod': interpolationMethod!.name,
      if (compoundingConvention != null)
        'compoundingConvention': compoundingConvention!.name,
      if (accruedHandling != null) 'accruedHandling': accruedHandling!.name,
      'snapshotEnabled': snapshotEnabled,
      'marketFrozen': marketFrozen,
      'regulatoryTag': regulatoryTag,
      'curveVersion': curveVersion,
      'description': description,
    };
  }

  static BondFormData fromJson(Map<String, dynamic> json) {
    return BondFormData(
      id: json['id'] as String?,
      marketCode: _firstString(json, const [
        'marketCode',
        'MarketDataCode',
        'mdCd',
      ]),
      isin: _firstString(json, const [
        'isin',
        'ISINCode',
        'entityOriginSource',
      ]),
      name: _firstString(json, const ['name', 'Name']),
      ccy: json['ccy'] != null
          ? _enumByName(Ccy.values, json['ccy'] as String)
          : null,
      intPayMethod: json['intPayMethod'] != null
          ? _enumByName(IntPayMethod.values, json['intPayMethod'] as String)
          : null,
      liquiditySect: json['liquiditySect'] != null
          ? _enumByName(LiquiditySect.values, json['liquiditySect'] as String)
          : null,
      subordSect: json['subordSect'] != null
          ? _enumByName(SubordSect.values, json['subordSect'] as String)
          : null,
      issueDate: json['issueDate'] != null
          ? DateTime.tryParse(json['issueDate'] as String)
          : null,
      maturityDate: json['maturityDate'] != null
          ? DateTime.tryParse(json['maturityDate'] as String)
          : null,
      source: (json['source'] as String?) ?? '',
      sourceCode: json['sourceCode'] != null
          ? _enumByName(SourceCode.values, json['sourceCode'] as String)
          : null,
      originSource: json['originSource'] != null
          ? _enumByName(OriginSource.values, json['originSource'] as String)
          : null,
      originCode: (json['originCode'] as String?) ?? '',
      entityOriginSource: (json['entityOriginSource'] as String?) ?? '',
      entityOriginCode: json['entityOriginCode'] != null
          ? _enumByName(
              EntityOriginCode.values,
              json['entityOriginCode'] as String,
            )
          : null,
      issueKind: json['issueKind'] != null
          ? _enumByName(IssueKind.values, json['issueKind'] as String)
          : null,
      issuePurpose: json['issuePurpose'] != null
          ? _enumByName(IssuePurpose.values, json['issuePurpose'] as String)
          : null,
      listingSection: json['listingSection'] != null
          ? _enumByName(ListingSection.values, json['listingSection'] as String)
          : null,
      assetSecuritizationClassification:
          json['assetSecuritizationClassification'] != null
          ? _enumByName(
              AssetSecuritizationClassification.values,
              json['assetSecuritizationClassification'] as String,
            )
          : null,
      exchange: _firstString(json, const ['exchange', 'Exchange', 'source']),
      tradingStatus: json['tradingStatus'] != null
          ? _enumByName(TradingStatus.values, json['tradingStatus'] as String)
          : TradingStatus.fromApi(_asString(json['TradingStatus'])),
      settlementDays: _asInt(json['settlementDays'] ?? json['SettlementDays']),
      tradingCalendar: json['tradingCalendar'] != null
          ? _enumByName(
              TradingCalendar.values,
              json['tradingCalendar'] as String,
            )
          : TradingCalendar.fromApi(_asString(json['TradingCalendar'])),
      tickSize: _asDouble(json['tickSize'] ?? json['TickSize']),
      lotSize: _asDouble(json['lotSize'] ?? json['LotSize']),
      minOrderSize: _asDouble(json['minOrderSize'] ?? json['MinOrderSize']),
      maxOrderSize: _asDouble(json['maxOrderSize'] ?? json['MaxOrderSize']),
      clearingHouse: _firstString(json, const [
        'clearingHouse',
        'ClearingHouse',
      ]),
      settlementCurrency: _firstString(json, const [
        'settlementCurrency',
        'SettlementCurrency',
      ]),
      failHandlingRule: json['failHandlingRule'] != null
          ? _enumByName(
              FailHandlingRule.values,
              json['failHandlingRule'] as String,
            )
          : FailHandlingRule.fromApi(_asString(json['FailHandlingRule'])),
      valuationDate: json['valuationDate'] != null
          ? DateTime.tryParse(json['valuationDate'] as String)
          : DateTime.tryParse(_asString(json['ValuationDate'])),
      vendor: _firstString(json, const ['vendor', 'Vendor']),
      priceType: json['priceType'] != null
          ? _enumByName(PriceType.values, json['priceType'] as String)
          : PriceType.fromApi(_asString(json['PriceType'])),
      discountCurve: _firstString(json, const [
        'discountCurve',
        'DiscountCurve',
      ]),
      creditCurve: _firstString(json, const ['creditCurve', 'CreditCurve']),
      fundingCurve: _firstString(json, const ['fundingCurve', 'FundingCurve']),
      oisCurve: _firstString(json, const ['oisCurve', 'OISCurve']),
      interpolationMethod: json['interpolationMethod'] != null
          ? _enumByName(
              InterpolationMethod.values,
              json['interpolationMethod'] as String,
            )
          : InterpolationMethod.fromApi(_asString(json['InterpolationMethod'])),
      compoundingConvention: json['compoundingConvention'] != null
          ? _enumByName(
              CompoundingConvention.values,
              json['compoundingConvention'] as String,
            )
          : CompoundingConvention.fromApi(
              _asString(json['CompoundingConvention']),
            ),
      accruedHandling: json['accruedHandling'] != null
          ? _enumByName(
              AccruedHandling.values,
              json['accruedHandling'] as String,
            )
          : AccruedHandling.fromApi(_asString(json['AccruedHandling'])),
      snapshotEnabled: _asBool(
        json['snapshotEnabled'] ?? json['SnapshotEnabled'],
      ),
      marketFrozen: _asBool(json['marketFrozen'] ?? json['MarketFrozen']),
      regulatoryTag: _firstString(json, const [
        'regulatoryTag',
        'RegulatoryTag',
      ]),
      curveVersion: _firstString(json, const ['curveVersion', 'CurveVersion']),
      description: _firstString(json, const ['description', 'Description']),
    );
  }

  static T? _enumByName<T>(List<T> values, String name) {
    try {
      return values.firstWhere((e) => (e as dynamic).name == name);
    } catch (_) {
      return null;
    }
  }

  static String _asString(Object? value) {
    if (value == null) return '';
    return value.toString();
  }

  static String _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  static int? _asInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      return lower == 'true' || lower == 'y' || lower == 'yes' || lower == '1';
    }
    return false;
  }

  BondFormData copyWith({
    String? id,
    String? marketCode,
    String? isin,
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
    String? exchange,
    TradingStatus? tradingStatus,
    int? settlementDays,
    TradingCalendar? tradingCalendar,
    double? tickSize,
    double? lotSize,
    double? minOrderSize,
    double? maxOrderSize,
    String? clearingHouse,
    String? settlementCurrency,
    FailHandlingRule? failHandlingRule,
    DateTime? valuationDate,
    String? vendor,
    PriceType? priceType,
    String? discountCurve,
    String? creditCurve,
    String? fundingCurve,
    String? oisCurve,
    InterpolationMethod? interpolationMethod,
    CompoundingConvention? compoundingConvention,
    AccruedHandling? accruedHandling,
    bool? snapshotEnabled,
    bool? marketFrozen,
    String? regulatoryTag,
    String? curveVersion,
    String? description,
  }) {
    return BondFormData(
      id: id ?? this.id,
      marketCode: marketCode ?? this.marketCode,
      isin: isin ?? this.isin,
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
          assetSecuritizationClassification ??
          this.assetSecuritizationClassification,
      exchange: exchange ?? this.exchange,
      tradingStatus: tradingStatus ?? this.tradingStatus,
      settlementDays: settlementDays ?? this.settlementDays,
      tradingCalendar: tradingCalendar ?? this.tradingCalendar,
      tickSize: tickSize ?? this.tickSize,
      lotSize: lotSize ?? this.lotSize,
      minOrderSize: minOrderSize ?? this.minOrderSize,
      maxOrderSize: maxOrderSize ?? this.maxOrderSize,
      clearingHouse: clearingHouse ?? this.clearingHouse,
      settlementCurrency: settlementCurrency ?? this.settlementCurrency,
      failHandlingRule: failHandlingRule ?? this.failHandlingRule,
      valuationDate: valuationDate ?? this.valuationDate,
      vendor: vendor ?? this.vendor,
      priceType: priceType ?? this.priceType,
      discountCurve: discountCurve ?? this.discountCurve,
      creditCurve: creditCurve ?? this.creditCurve,
      fundingCurve: fundingCurve ?? this.fundingCurve,
      oisCurve: oisCurve ?? this.oisCurve,
      interpolationMethod: interpolationMethod ?? this.interpolationMethod,
      compoundingConvention:
          compoundingConvention ?? this.compoundingConvention,
      accruedHandling: accruedHandling ?? this.accruedHandling,
      snapshotEnabled: snapshotEnabled ?? this.snapshotEnabled,
      marketFrozen: marketFrozen ?? this.marketFrozen,
      regulatoryTag: regulatoryTag ?? this.regulatoryTag,
      curveVersion: curveVersion ?? this.curveVersion,
      description: description ?? this.description,
    );
  }
}
