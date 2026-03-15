import 'package:flutter/material.dart';

import '../../api/currency_api_client.dart';
import '../../api/issuer_api_client.dart';
import '../../models/bond_curve_master_form_data.dart';
import '../../models/issuer_form_data.dart';
import '../../models/reference_master_form_data.dart';

class BondCurveMasterEditScreen extends StatefulWidget {
  const BondCurveMasterEditScreen({super.key, this.initialData});

  final BondCurveMasterFormData? initialData;

  @override
  State<BondCurveMasterEditScreen> createState() =>
      _BondCurveMasterEditScreenState();
}

class _BondCurveMasterEditScreenState extends State<BondCurveMasterEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _curveCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minRemainingYearsController =
      TextEditingController();
  final TextEditingController _minOutstandingAmountController =
      TextEditingController();

  List<ReferenceMasterFormData> _currencyOptions = [];
  List<IssuerFormData> _issuerOptions = [];
  bool _loadingOptions = true;

  String _currencyId = '';
  String _curveType = '';
  String _curvePurpose = '';
  String _rateRepresentation = '';
  String _issuerId = '';
  bool _active = true;
  bool _onTheRunOnly = false;
  bool _outputIncludesYtm = true;
  bool _outputIncludesZero = true;
  bool _outputIncludesDf = true;
  DateTime? _validFrom;
  DateTime? _validTo;

  static const List<String> _curveTypeOptions = [
    'Government',
    'OIS',
    'IRS',
    'Agency',
    'Corporate',
    'BondSpread',
    'CreditSpread',
    'Inflation',
  ];

  static const List<String> _curvePurposeOptions = [
    'Discounting',
    'Projection',
    'Benchmark',
    'Spread',
  ];

  static const List<String> _rateRepresentationOptions = [
    'ZeroRate',
    'DiscountFactor',
    'ParYield',
    'ForwardRate',
    'Spread',
  ];

  bool get _isCreate => widget.initialData == null;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _curveCodeController.text = data?.curveCode ?? '';
    _nameController.text = data?.name ?? '';
    _descriptionController.text = data?.description ?? '';
    _minRemainingYearsController.text = _formatNumber(data?.minRemainingYears);
    _minOutstandingAmountController.text = _formatNumber(
      data?.minOutstandingAmount,
    );
    _currencyId = data?.currencyId ?? '';
    _curveType = data?.curveType ?? '';
    _curvePurpose = data?.curvePurpose ?? '';
    _rateRepresentation = data?.rateRepresentation ?? '';
    _issuerId = data?.issuerId ?? '';
    _active = data?.active ?? true;
    _onTheRunOnly = data?.onTheRunOnly ?? false;
    _outputIncludesYtm = data?.outputIncludesYtm ?? true;
    _outputIncludesZero = data?.outputIncludesZero ?? true;
    _outputIncludesDf = data?.outputIncludesDf ?? true;
    _validFrom = data?.validFrom;
    _validTo = data?.validTo;
    _loadOptions();
  }

  @override
  void dispose() {
    _curveCodeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _minRemainingYearsController.dispose();
    _minOutstandingAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([
        currencyApi.getList(),
        issuerApi.getList(),
      ]);
      if (!mounted) return;
      setState(() {
        _currencyOptions = results[0] as List<ReferenceMasterFormData>;
        _issuerOptions = results[1] as List<IssuerFormData>;
        _currencyId = _resolveCurrencyId(_currencyId);
        _issuerId = _resolveIssuerId(_issuerId);
        _loadingOptions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currencyOptions = [];
        _issuerOptions = [];
        _loadingOptions = false;
      });
    }
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_validFrom != null &&
        _validTo != null &&
        _validTo!.isBefore(_validFrom!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ValidTo must be on or after ValidFrom.')),
      );
      return;
    }

    Navigator.of(context).pop(
      BondCurveMasterFormData(
        id: widget.initialData?.id,
        curveCode: _curveCodeController.text.trim(),
        name: _nameController.text.trim(),
        currencyId: _currencyId,
        currencyCode: _currencyCodeForId(_currencyId),
        curveType: _curveType,
        curvePurpose: _curvePurpose,
        rateRepresentation: _rateRepresentation,
        active: _active,
        validFrom: _validFrom,
        validTo: _validTo,
        description: _descriptionController.text.trim(),
        issuerId: _issuerId,
        issuerName: _issuerNameForId(_issuerId),
        onTheRunOnly: _onTheRunOnly,
        minRemainingYears: _parseDouble(_minRemainingYearsController.text),
        minOutstandingAmount: _parseDouble(
          _minOutstandingAmountController.text,
        ),
        outputIncludesYtm: _outputIncludesYtm,
        outputIncludesZero: _outputIncludesZero,
        outputIncludesDf: _outputIncludesDf,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreate ? 'BondCurveMaster New' : 'BondCurveMaster Edit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _loadingOptions ? null : _onSave,
            icon: const Icon(Icons.check, size: 20),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loadingOptions
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTextField(
                    label: 'CurveCode',
                    controller: _curveCodeController,
                    required: true,
                    readOnly: !_isCreate,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Name',
                    controller: _nameController,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'Currency',
                    value: _currencyId,
                    required: true,
                    items: _currencyOptions
                        .where((item) => (item.id ?? '').isNotEmpty)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id!,
                            child: Text('${item.code} | ${item.name}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _currencyId = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'CurveType',
                    value: _curveType,
                    required: true,
                    items: _curveTypeOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _curveType = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'CurvePurpose',
                    value: _curvePurpose,
                    required: true,
                    items: _curvePurposeOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _curvePurpose = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'RateRepresentation',
                    value: _rateRepresentation,
                    required: true,
                    items: _rateRepresentationOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _rateRepresentation = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchField(
                    label: 'Active',
                    value: _active,
                    onChanged: (value) => setState(() => _active = value),
                  ),
                  const SizedBox(height: 12),
                  _buildDateField(
                    label: 'ValidFrom',
                    value: _validFrom,
                    onPick: (value) => setState(() => _validFrom = value),
                  ),
                  const SizedBox(height: 12),
                  _buildDateField(
                    label: 'ValidTo',
                    value: _validTo,
                    onPick: (value) => setState(() => _validTo = value),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Description',
                    controller: _descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'Issuer',
                    value: _issuerId,
                    items: _issuerOptions
                        .where((item) => (item.id ?? '').isNotEmpty)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id!,
                            child: Text('${item.issuerCode} | ${item.name}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _issuerId = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchField(
                    label: 'OnTheRunOnly',
                    value: _onTheRunOnly,
                    onChanged: (value) => setState(() => _onTheRunOnly = value),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'MinRemainingYears',
                    controller: _minRemainingYearsController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _optionalDecimalValidator,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'MinOutstandingAmount',
                    controller: _minOutstandingAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _optionalDecimalValidator,
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchField(
                    label: 'OutputIncludesYtm',
                    value: _outputIncludesYtm,
                    onChanged: (value) =>
                        setState(() => _outputIncludesYtm = value),
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchField(
                    label: 'OutputIncludesZero',
                    value: _outputIncludesZero,
                    onChanged: (value) =>
                        setState(() => _outputIncludesZero = value),
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchField(
                    label: 'OutputIncludesDf',
                    value: _outputIncludesDf,
                    onChanged: (value) =>
                        setState(() => _outputIncludesDf = value),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      validator:
          validator ??
          (required
              ? (value) =>
                    (value ?? '').trim().isEmpty ? '$label is required.' : null
              : null),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
      validator: required
          ? (_) => value.trim().isEmpty ? '$label is required.' : null
          : null,
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InputDecorator(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      child: Row(
        children: [
          Text('$label *'),
          const Spacer(),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPick,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onPick(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null ? 'Select date' : _formatDate(value),
                style: value == null
                    ? TextStyle(color: Theme.of(context).hintColor)
                    : null,
              ),
            ),
            IconButton(
              onPressed: value == null ? null : () => onPick(null),
              icon: const Icon(Icons.close, size: 16),
              tooltip: 'Clear',
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  String _resolveCurrencyId(String rawId) {
    final normalized = rawId.trim();
    if (normalized.isEmpty) return '';
    for (final item in _currencyOptions) {
      if ((item.id ?? '') == normalized) {
        return normalized;
      }
    }
    return '';
  }

  String _resolveIssuerId(String rawId) {
    final normalized = rawId.trim();
    if (normalized.isEmpty) return '';
    for (final item in _issuerOptions) {
      if ((item.id ?? '') == normalized) {
        return normalized;
      }
    }
    return '';
  }

  String _currencyCodeForId(String id) {
    for (final item in _currencyOptions) {
      if ((item.id ?? '') == id) {
        return item.code;
      }
    }
    return '';
  }

  String _issuerNameForId(String id) {
    for (final item in _issuerOptions) {
      if ((item.id ?? '') == id) {
        return item.name;
      }
    }
    return '';
  }

  static String _formatNumber(double? value) {
    if (value == null) return '';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  static double? _parseDouble(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  static String? _optionalDecimalValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    return double.tryParse(text) == null ? 'Enter a valid number.' : null;
  }

  static String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
