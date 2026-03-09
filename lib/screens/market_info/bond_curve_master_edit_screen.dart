import 'package:flutter/material.dart';

import '../../models/bond_curve_enums.dart';
import '../../models/bond_curve_master_form_data.dart';

class BondCurveMasterEditScreen extends StatefulWidget {
  const BondCurveMasterEditScreen({super.key, this.initialData});

  final BondCurveMasterFormData? initialData;

  @override
  State<BondCurveMasterEditScreen> createState() =>
      _BondCurveMasterEditScreenState();
}

class _BondCurveMasterEditScreenState extends State<BondCurveMasterEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _minRemainingYearsController;
  late TextEditingController _minOutstandingAmountController;
  late TextEditingController _descriptionController;

  String? _currencyId;
  CurvePurpose? _purpose;
  BondCurveIssuerType? _issuerType;
  bool _onTheRunOnly = false;
  bool _outputIncludesYtm = true;
  bool _outputIncludesZero = true;
  bool _outputIncludesDf = true;
  bool _activeFlag = true;
  DateTime? _validFrom;
  DateTime? _validTo;

  static const List<String> _currencyOptions = <String>[
    'KRW',
    'USD',
    'EUR',
    'JPY',
    'GBP',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _nameController = TextEditingController(text: d?.name ?? '');
    _minRemainingYearsController = TextEditingController(
      text: _toText(d?.minRemainingYears),
    );
    _minOutstandingAmountController = TextEditingController(
      text: _toText(d?.minOutstandingAmount),
    );
    _descriptionController = TextEditingController(text: d?.description ?? '');

    _currencyId = _chooseDefault(d?.currencyId, _currencyOptions);
    _purpose = d?.purpose ?? CurvePurpose.benchmark;
    _issuerType = d?.issuerType ?? BondCurveIssuerType.govt;
    _onTheRunOnly = d?.onTheRunOnly ?? false;
    _outputIncludesYtm = d?.outputIncludesYtm ?? true;
    _outputIncludesZero = d?.outputIncludesZero ?? true;
    _outputIncludesDf = d?.outputIncludesDf ?? true;
    _activeFlag = d?.activeFlag ?? true;
    _validFrom = d?.validFrom;
    _validTo = d?.validTo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minRemainingYearsController.dispose();
    _minOutstandingAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_validFrom != null &&
        _validTo != null &&
        _validTo!.isBefore(_validFrom!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valid To must be on or after Valid From.'),
        ),
      );
      return;
    }

    final form = BondCurveMasterFormData(
      id: widget.initialData?.id,
      name: _nameController.text.trim(),
      currencyId: (_currencyId ?? '').trim(),
      purpose: _purpose ?? CurvePurpose.benchmark,
      issuerType: _issuerType ?? BondCurveIssuerType.govt,
      onTheRunOnly: _onTheRunOnly,
      minRemainingYears: _parseDouble(_minRemainingYearsController.text),
      minOutstandingAmount: _parseDouble(_minOutstandingAmountController.text),
      outputIncludesYtm: _outputIncludesYtm,
      outputIncludesZero: _outputIncludesZero,
      outputIncludesDf: _outputIncludesDf,
      activeFlag: _activeFlag,
      validFrom: _validFrom,
      validTo: _validTo,
      description: _descriptionController.text.trim(),
    );
    Navigator.of(context).pop(form);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialData == null
              ? 'BondCurveMaster New'
              : 'BondCurveMaster Edit',
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _onSave,
            icon: const Icon(Icons.check, size: 20),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              label: 'Name',
              controller: _nameController,
              required: true,
            ),
            const SizedBox(height: 12),
            _buildSearchableField(
              label: 'CurrencyId',
              options: _currencyOptions,
              value: _currencyId,
              required: true,
              onChanged: (value) => _currencyId = value,
            ),
            const SizedBox(height: 12),
            _buildEnumDropdown<CurvePurpose>(
              label: 'Purpose',
              value: _purpose,
              values: CurvePurpose.values,
              required: true,
              labelOf: (v) => v.label,
              onChanged: (v) => setState(() => _purpose = v),
            ),
            const SizedBox(height: 12),
            _buildEnumDropdown<BondCurveIssuerType>(
              label: 'IssuerType',
              value: _issuerType,
              values: BondCurveIssuerType.values,
              required: true,
              labelOf: (v) => v.label,
              onChanged: (v) => setState(() => _issuerType = v),
            ),
            const SizedBox(height: 12),
            _buildCheckboxField(
              label: 'OnTheRunOnly',
              value: _onTheRunOnly,
              onChanged: (v) => setState(() => _onTheRunOnly = v ?? false),
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
            _buildCheckboxField(
              label: 'OutputIncludesYtm',
              value: _outputIncludesYtm,
              onChanged: (v) => setState(() => _outputIncludesYtm = v ?? false),
            ),
            const SizedBox(height: 12),
            _buildCheckboxField(
              label: 'OutputIncludesZero',
              value: _outputIncludesZero,
              onChanged: (v) =>
                  setState(() => _outputIncludesZero = v ?? false),
            ),
            const SizedBox(height: 12),
            _buildCheckboxField(
              label: 'OutputIncludesDf',
              value: _outputIncludesDf,
              onChanged: (v) => setState(() => _outputIncludesDf = v ?? false),
            ),
            const SizedBox(height: 12),
            _buildSwitchField(
              label: 'ActiveFlag',
              value: _activeFlag,
              onChanged: (v) => setState(() => _activeFlag = v),
            ),
            const SizedBox(height: 12),
            _buildDateField(
              label: 'ValidFrom',
              value: _validFrom,
              onPick: (date) => setState(() => _validFrom = date),
            ),
            const SizedBox(height: 12),
            _buildDateField(
              label: 'ValidTo',
              value: _validTo,
              onPick: (date) => setState(() => _validTo = date),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Description',
              controller: _descriptionController,
              maxLines: 3,
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
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      validator:
          validator ??
          (required
              ? (v) {
                  if ((v ?? '').trim().isEmpty) return '$label is required.';
                  return null;
                }
              : null),
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
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      items: values
          .map((e) => DropdownMenuItem<T>(value: e, child: Text(labelOf(e))))
          .toList(),
      onChanged: onChanged,
      validator: required
          ? (v) => v == null ? '$label is required.' : null
          : null,
    );
  }

  Widget _buildSearchableField({
    required String label,
    required List<String> options,
    required String? value,
    required ValueChanged<String> onChanged,
    bool required = false,
  }) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: value ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return options;
        return options.where((e) => e.toLowerCase().contains(query));
      },
      onSelected: onChanged,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: required ? '$label *' : label,
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
          validator: required
              ? (v) => (v ?? '').trim().isEmpty ? '$label is required.' : null
              : null,
        );
      },
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
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
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
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxField({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: '$label *',
        border: const OutlineInputBorder(),
      ),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text('Enabled'),
      ),
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

  static String? _optionalDecimalValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null) return 'Enter a valid number.';
    if (parsed < 0) return 'Value must be >= 0.';
    return null;
  }

  static String? _chooseDefault(String? value, List<String> options) {
    final normalized = (value ?? '').trim();
    if (normalized.isNotEmpty) return normalized;
    return options.isEmpty ? null : options.first;
  }

  static double? _parseDouble(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  static String _toText(double? value) {
    if (value == null) return '';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
