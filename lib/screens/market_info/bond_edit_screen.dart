import 'package:flutter/material.dart';

import '../../models/bond_enums.dart';
import '../../models/bond_form_data.dart';

/// Bond market context create/edit screen.
class BondEditScreen extends StatefulWidget {
  const BondEditScreen({super.key, this.initialData});

  final BondFormData? initialData;

  @override
  State<BondEditScreen> createState() => _BondEditScreenState();
}

class _BondEditScreenState extends State<BondEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _marketCodeController;
  late TextEditingController _isinController;
  late TextEditingController _settlementDaysController;
  late TextEditingController _tickSizeController;
  late TextEditingController _lotSizeController;
  late TextEditingController _minOrderSizeController;
  late TextEditingController _maxOrderSizeController;
  late TextEditingController _regulatoryTagController;
  late TextEditingController _curveVersionController;

  String? _exchange;
  TradingStatus? _tradingStatus;
  TradingCalendar? _tradingCalendar;
  String? _clearingHouse;
  String? _settlementCurrency;
  FailHandlingRule? _failHandlingRule;

  DateTime? _valuationDate;
  String? _vendor;
  PriceType? _priceType;
  String? _discountCurve;
  String? _creditCurve;
  String? _fundingCurve;
  String? _oisCurve;
  InterpolationMethod? _interpolationMethod;
  CompoundingConvention? _compoundingConvention;
  AccruedHandling? _accruedHandling;

  bool _snapshotEnabled = false;
  bool _marketFrozen = false;

  static const List<String> _exchangeOptions = <String>[
    'KRX',
    'KTS',
    'NYSE',
    'NASDAQ',
    'JPX',
    'LSE',
  ];

  static const List<String> _clearingHouseOptions = <String>[
    'KSD',
    'Euroclear',
    'DTCC',
    'Clearstream',
  ];

  static const List<String> _currencyOptions = <String>[
    'KRW',
    'USD',
    'EUR',
    'JPY',
    'GBP',
  ];

  static const List<String> _vendorOptions = <String>[
    'Bloomberg',
    'Refinitiv',
    'KAP',
    'Internal',
  ];

  static const List<String> _curveOptions = <String>[
    'KRW-KTB-001',
    'KRW-KTB-ON',
    'USD-SOFR-001',
    'USD-LIBOR-3M',
    'EUR-ESTR-001',
    'JPY-TONA-001',
    'KRW-CREDIT-AA',
    'USD-CREDIT-IG',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _marketCodeController = TextEditingController(
      text: (d?.marketCode ?? '').isEmpty ? _newBondCode() : d!.marketCode,
    );
    final isin = (d?.isin ?? '').isNotEmpty
        ? d!.isin
        : (d?.entityOriginSource ?? '');
    _isinController = TextEditingController(text: isin);
    _settlementDaysController = TextEditingController(
      text: d?.settlementDays?.toString() ?? '',
    );
    _tickSizeController = TextEditingController(text: _toText(d?.tickSize));
    _lotSizeController = TextEditingController(text: _toText(d?.lotSize));
    _minOrderSizeController = TextEditingController(
      text: _toText(d?.minOrderSize),
    );
    _maxOrderSizeController = TextEditingController(
      text: _toText(d?.maxOrderSize),
    );
    _regulatoryTagController = TextEditingController(
      text: d?.regulatoryTag ?? '',
    );
    _curveVersionController = TextEditingController(
      text: (d?.curveVersion ?? '').isEmpty ? 'CURRENT' : d!.curveVersion,
    );

    _exchange = _chooseDefault(d?.exchange, d?.source, _exchangeOptions);
    _tradingStatus = d?.tradingStatus;
    _tradingCalendar = d?.tradingCalendar;
    _clearingHouse = _chooseDefault(
      d?.clearingHouse,
      null,
      _clearingHouseOptions,
    );
    _settlementCurrency = _chooseDefault(
      d?.settlementCurrency,
      d?.ccy?.apiValue,
      _currencyOptions,
    );
    _failHandlingRule = d?.failHandlingRule;

    _valuationDate = d?.valuationDate;
    _vendor = _chooseDefault(d?.vendor, null, _vendorOptions);
    _priceType = d?.priceType;
    _discountCurve = _chooseDefault(d?.discountCurve, null, _curveOptions);
    _creditCurve = _chooseDefault(d?.creditCurve, null, _curveOptions);
    _fundingCurve = _chooseDefault(d?.fundingCurve, null, _curveOptions);
    _oisCurve = _chooseDefault(d?.oisCurve, null, _curveOptions);
    _interpolationMethod = d?.interpolationMethod;
    _compoundingConvention = d?.compoundingConvention;
    _accruedHandling = d?.accruedHandling;
    _snapshotEnabled = d?.snapshotEnabled ?? false;
    _marketFrozen = d?.marketFrozen ?? false;
  }

  @override
  void dispose() {
    _marketCodeController.dispose();
    _isinController.dispose();
    _settlementDaysController.dispose();
    _tickSizeController.dispose();
    _lotSizeController.dispose();
    _minOrderSizeController.dispose();
    _maxOrderSizeController.dispose();
    _regulatoryTagController.dispose();
    _curveVersionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_buildFormData());
  }

  BondFormData _buildFormData() {
    final base = widget.initialData;
    final marketCode = _marketCodeController.text.trim();
    final isin = _isinController.text.trim();
    return BondFormData(
      id: base?.id,
      marketCode: marketCode,
      isin: isin,
      name: (base?.name ?? '').isNotEmpty ? base!.name : marketCode,
      ccy: _ccyFromText(_settlementCurrency),
      intPayMethod: base?.intPayMethod,
      liquiditySect: base?.liquiditySect,
      subordSect: base?.subordSect,
      issueDate: base?.issueDate,
      maturityDate: base?.maturityDate,
      source: _exchange ?? '',
      sourceCode: base?.sourceCode,
      originSource: base?.originSource,
      originCode: base?.originCode ?? '',
      entityOriginSource: isin,
      entityOriginCode: base?.entityOriginCode,
      issueKind: base?.issueKind,
      issuePurpose: base?.issuePurpose,
      listingSection: base?.listingSection,
      assetSecuritizationClassification:
          base?.assetSecuritizationClassification,
      exchange: _exchange ?? '',
      tradingStatus: _tradingStatus,
      settlementDays: int.tryParse(_settlementDaysController.text.trim()),
      tradingCalendar: _tradingCalendar,
      tickSize: _parseDouble(_tickSizeController.text),
      lotSize: _parseDouble(_lotSizeController.text),
      minOrderSize: _parseDouble(_minOrderSizeController.text),
      maxOrderSize: _parseDouble(_maxOrderSizeController.text),
      clearingHouse: _clearingHouse ?? '',
      settlementCurrency: _settlementCurrency ?? '',
      failHandlingRule: _failHandlingRule,
      valuationDate: _valuationDate,
      vendor: _vendor ?? '',
      priceType: _priceType,
      discountCurve: _discountCurve ?? '',
      creditCurve: _creditCurve ?? '',
      fundingCurve: _fundingCurve ?? '',
      oisCurve: _oisCurve ?? '',
      interpolationMethod: _interpolationMethod,
      compoundingConvention: _compoundingConvention,
      accruedHandling: _accruedHandling,
      snapshotEnabled: _snapshotEnabled,
      marketFrozen: _marketFrozen,
      regulatoryTag: _regulatoryTagController.text.trim(),
      curveVersion: _curveVersionController.text.trim(),
      description: base?.description ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bond Market Context'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildReadonlyRow(
                          'Bond Code',
                          _marketCodeController.text,
                        ),
                        const SizedBox(height: 10),
                        _buildReadonlyRow(
                          'ISIN',
                          _isinController.text.isEmpty
                              ? '(Assigned by source)'
                              : _isinController.text,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'Trading Market Setup'),
                  Tab(text: 'Pricing / Valuation Setup'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [_buildTradingTab(), _buildPricingTab()],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: _onSave, child: const Text('Save')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Basic Trading Environment'),
        _buildSearchableField(
          label: 'Exchange',
          options: _exchangeOptions,
          value: _exchange,
          required: true,
          onChanged: (value) => _exchange = value,
        ),
        _buildEnumDropdown<TradingStatus>(
          label: 'Trading Status',
          value: _tradingStatus,
          values: TradingStatus.values,
          required: true,
          labelOf: (e) => e.label,
          onChanged: (v) => setState(() => _tradingStatus = v),
        ),
        _buildTextField(
          label: 'Settlement Days (T+N)',
          controller: _settlementDaysController,
          required: true,
          keyboardType: TextInputType.number,
          validator: (value) {
            final text = (value ?? '').trim();
            if (text.isEmpty) return 'Settlement Days is required.';
            final parsed = int.tryParse(text);
            if (parsed == null) return 'Enter a whole number.';
            if (parsed < 0) return 'Settlement Days must be >= 0.';
            return null;
          },
        ),
        _buildEnumDropdown<TradingCalendar>(
          label: 'Trading Calendar',
          value: _tradingCalendar,
          values: TradingCalendar.values,
          required: true,
          labelOf: (e) => e.label,
          onChanged: (v) => setState(() => _tradingCalendar = v),
        ),
        const SizedBox(height: 8),
        _buildSectionTitle('Order Rules'),
        _buildTextField(
          label: 'Tick Size',
          controller: _tickSizeController,
          required: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final parsed = _parseDouble(value ?? '');
            if (parsed == null) return 'Tick Size is required.';
            if (parsed <= 0) return 'Tick Size must be > 0.';
            return null;
          },
        ),
        _buildTextField(
          label: 'Lot Size',
          controller: _lotSizeController,
          required: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final parsed = _parseDouble(value ?? '');
            if (parsed == null) return 'Lot Size is required.';
            if (parsed <= 0) return 'Lot Size must be > 0.';
            return null;
          },
        ),
        _buildTextField(
          label: 'Min Order Size',
          controller: _minOrderSizeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final text = (value ?? '').trim();
            if (text.isEmpty) return null;
            final parsed = _parseDouble(text);
            if (parsed == null) return 'Enter a valid number.';
            if (parsed < 0) return 'Min Order Size must be >= 0.';
            return null;
          },
        ),
        _buildTextField(
          label: 'Max Order Size',
          controller: _maxOrderSizeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final text = (value ?? '').trim();
            if (text.isEmpty) return null;
            final parsed = _parseDouble(text);
            if (parsed == null) return 'Enter a valid number.';
            if (parsed < 0) return 'Max Order Size must be >= 0.';
            return null;
          },
        ),
        const SizedBox(height: 8),
        _buildSectionTitle('Clearing & Settlement'),
        _buildSearchableField(
          label: 'Clearing House',
          options: _clearingHouseOptions,
          value: _clearingHouse,
          required: true,
          onChanged: (value) => _clearingHouse = value,
        ),
        _buildSearchableField(
          label: 'Settlement Currency',
          options: _currencyOptions,
          value: _settlementCurrency,
          required: true,
          onChanged: (value) => _settlementCurrency = value,
        ),
        _buildEnumDropdown<FailHandlingRule>(
          label: 'Fail Handling Rule',
          value: _failHandlingRule,
          values: FailHandlingRule.values,
          required: true,
          labelOf: (e) => e.label,
          onChanged: (v) => setState(() => _failHandlingRule = v),
        ),
      ],
    );
  }

  Widget _buildPricingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Pricing Base Information'),
        _buildDateField(
          label: 'Valuation Date',
          value: _valuationDate,
          required: true,
          onPick: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _valuationDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null && mounted) {
              setState(() => _valuationDate = picked);
            }
          },
        ),
        _buildSearchableField(
          label: 'Vendor',
          options: _vendorOptions,
          value: _vendor,
          required: true,
          onChanged: (value) => _vendor = value,
        ),
        _buildEnumDropdown<PriceType>(
          label: 'Price Type',
          value: _priceType,
          values: PriceType.values,
          required: true,
          labelOf: (e) => e.label,
          onChanged: (v) => setState(() => _priceType = v),
        ),
        const SizedBox(height: 8),
        _buildSectionTitle('Curve Selection'),
        _buildSearchableField(
          label: 'Discount Curve',
          options: _curveOptions,
          value: _discountCurve,
          required: true,
          onChanged: (value) => _discountCurve = value,
        ),
        _buildSearchableField(
          label: 'Credit Curve',
          options: _curveOptions,
          value: _creditCurve,
          onChanged: (value) => _creditCurve = value,
        ),
        _buildSearchableField(
          label: 'Funding Curve',
          options: _curveOptions,
          value: _fundingCurve,
          onChanged: (value) => _fundingCurve = value,
        ),
        _buildSearchableField(
          label: 'OIS Curve',
          options: _curveOptions,
          value: _oisCurve,
          onChanged: (value) => _oisCurve = value,
        ),
        const SizedBox(height: 8),
        _buildSectionTitle('Calculation Rules'),
        _buildEnumDropdown<InterpolationMethod>(
          label: 'Interpolation Method',
          value: _interpolationMethod,
          values: InterpolationMethod.values,
          required: true,
          labelOf: (e) => e.label,
          onChanged: (v) => setState(() => _interpolationMethod = v),
        ),
        _buildEnumDropdown<CompoundingConvention>(
          label: 'Compounding Convention',
          value: _compoundingConvention,
          values: CompoundingConvention.values,
          required: true,
          labelOf: (e) => e.label,
          onChanged: (v) => setState(() => _compoundingConvention = v),
        ),
        _buildEnumDropdown<AccruedHandling>(
          label: 'Accrued Interest Handling',
          value: _accruedHandling,
          values: AccruedHandling.values,
          required: true,
          labelOf: (e) => e.label,
          onChanged: (v) => setState(() => _accruedHandling = v),
        ),
        const SizedBox(height: 8),
        _buildSectionTitle('Additional Controls'),
        _buildFieldShell(
          label: 'Snapshot Save',
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _snapshotEnabled,
            onChanged: (v) => setState(() => _snapshotEnabled = v ?? false),
            title: const Text('Enable snapshot storage'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        _buildFieldShell(
          label: 'Market Freeze',
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _marketFrozen,
            onChanged: (v) => setState(() => _marketFrozen = v ?? false),
            title: const Text('Freeze market context'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        _buildTextField(
          label: 'Regulatory Tag',
          controller: _regulatoryTagController,
        ),
        _buildTextField(
          label: 'Curve Version',
          controller: _curveVersionController,
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildReadonlyRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 10),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildFieldShell({
    required String label,
    required Widget child,
    bool required = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(text: label),
                if (required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  )
                else
                  TextSpan(
                    text: ' (optional)',
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return _buildFieldShell(
      label: label,
      required: required,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        validator:
            validator ??
            (required
                ? (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return '$label is required.';
                    }
                    return null;
                  }
                : null),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required Future<void> Function() onPick,
    bool required = false,
  }) {
    final text = value == null ? '' : _yyyyMmDd(value);
    return _buildFieldShell(
      label: label,
      required: required,
      child: FormField<DateTime?>(
        initialValue: value,
        validator: (_) {
          if (required && _valuationDate == null) {
            return '$label is required.';
          }
          return null;
        },
        builder: (field) {
          return InkWell(
            onTap: () async {
              await onPick();
              field.didChange(_valuationDate);
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: field.errorText,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text.isEmpty ? 'Select date' : text,
                      style: TextStyle(
                        color: text.isEmpty
                            ? Theme.of(context).hintColor
                            : null,
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnumDropdown<T>({
    required String label,
    required T? value,
    required List<T> values,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
    bool required = false,
  }) {
    return _buildFieldShell(
      label: label,
      required: required,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: values
            .map((e) => DropdownMenuItem<T>(value: e, child: Text(labelOf(e))))
            .toList(),
        onChanged: onChanged,
        validator: required
            ? (selected) {
                if (selected == null) return '$label is required.';
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildSearchableField({
    required String label,
    required List<String> options,
    required String? value,
    required ValueChanged<String> onChanged,
    bool required = false,
  }) {
    return _buildFieldShell(
      label: label,
      required: required,
      child: Autocomplete<String>(
        initialValue: TextEditingValue(text: value ?? ''),
        optionsBuilder: (TextEditingValue textEditingValue) {
          final query = textEditingValue.text.trim().toLowerCase();
          if (query.isEmpty) {
            return options;
          }
          return options.where(
            (option) => option.toLowerCase().contains(query),
          );
        },
        onSelected: onChanged,
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: onChanged,
            validator: required
                ? (text) {
                    if ((text ?? '').trim().isEmpty) {
                      return '$label is required.';
                    }
                    return null;
                  }
                : null,
          );
        },
      ),
    );
  }

  String _newBondCode() {
    final now = DateTime.now();
    return 'BD${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecond.toString().padLeft(3, '0')}';
  }

  static String _toText(double? value) {
    if (value == null) return '';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  static String _yyyyMmDd(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static double? _parseDouble(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  static String? _chooseDefault(
    String? primary,
    String? fallback,
    List<String> options,
  ) {
    final v1 = (primary ?? '').trim();
    if (v1.isNotEmpty) return v1;
    final v2 = (fallback ?? '').trim();
    if (v2.isNotEmpty) return v2;
    if (options.isEmpty) return null;
    return options.first;
  }

  static Ccy? _ccyFromText(String? text) {
    final code = (text ?? '').trim().toUpperCase();
    switch (code) {
      case 'KRW':
        return Ccy.krw;
      case 'USD':
        return Ccy.usd;
      case 'EUR':
        return Ccy.eur;
      case 'JPY':
        return Ccy.jpy;
      case 'GBP':
        return Ccy.gbp;
      default:
        return null;
    }
  }
}
