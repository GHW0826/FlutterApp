import 'package:flutter/material.dart';

import '../../models/bond_curve_build_method_form_data.dart';
import '../../models/bond_curve_enums.dart';

class BondCurveBuildMethodEditScreen extends StatefulWidget {
  const BondCurveBuildMethodEditScreen({super.key, this.initialData});

  final BondCurveBuildMethodFormData? initialData;

  @override
  State<BondCurveBuildMethodEditScreen> createState() =>
      _BondCurveBuildMethodEditScreenState();
}

class _BondCurveBuildMethodEditScreenState
    extends State<BondCurveBuildMethodEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _settlementDaysController;
  late TextEditingController _descriptionController;

  CurveFittingMethod? _fittingMethod;
  CurveInterpolationMethod? _interpolationMethod;
  ExtrapolationMethod? _extrapolationMethod;
  DayCountConvention? _dayCount;
  CurveCompoundingType? _compoundingType;
  CompoundingFrequency? _compoundingFrequency;
  BusinessDayConvention? _businessDayConvention;
  String? _calendarId;

  static const List<String> _calendarOptions = <String>[
    'KR',
    'US',
    'JP',
    'EU',
    'TARGET',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _nameController = TextEditingController(text: d?.name ?? '');
    _settlementDaysController = TextEditingController(
      text: d?.settlementDays?.toString() ?? '',
    );
    _descriptionController = TextEditingController(text: d?.description ?? '');

    _fittingMethod = d?.fittingMethod ?? CurveFittingMethod.bootstrap;
    _interpolationMethod =
        d?.interpolationMethod ?? CurveInterpolationMethod.logLinearDf;
    _extrapolationMethod =
        d?.extrapolationMethod ?? ExtrapolationMethod.flatFwd;
    _dayCount = d?.dayCount ?? DayCountConvention.act365f;
    _compoundingType = d?.compoundingType ?? CurveCompoundingType.compounded;
    _compoundingFrequency = d?.compoundingFrequency;
    _businessDayConvention =
        d?.businessDayConvention ?? BusinessDayConvention.following;
    _calendarId = _chooseDefault(d?.calendarId, _calendarOptions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _settlementDaysController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final normalizedCompoundingFreq =
        _compoundingType == CurveCompoundingType.compounded
        ? _compoundingFrequency
        : null;
    final form = BondCurveBuildMethodFormData(
      id: widget.initialData?.id,
      name: _nameController.text.trim(),
      fittingMethod: _fittingMethod ?? CurveFittingMethod.bootstrap,
      interpolationMethod:
          _interpolationMethod ?? CurveInterpolationMethod.logLinearDf,
      extrapolationMethod: _extrapolationMethod ?? ExtrapolationMethod.flatFwd,
      dayCount: _dayCount ?? DayCountConvention.act365f,
      compoundingType: _compoundingType ?? CurveCompoundingType.compounded,
      compoundingFrequency: normalizedCompoundingFreq,
      businessDayConvention:
          _businessDayConvention ?? BusinessDayConvention.following,
      calendarId: (_calendarId ?? '').trim(),
      settlementDays: _parseInt(_settlementDaysController.text),
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
              ? 'BondCurveBuildMethod New'
              : 'BondCurveBuildMethod Edit',
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
            _buildEnumDropdown<CurveFittingMethod>(
              label: 'FittingMethod',
              value: _fittingMethod,
              values: CurveFittingMethod.values,
              required: true,
              labelOf: (v) => v.label,
              onChanged: (v) => setState(() => _fittingMethod = v),
            ),
            const SizedBox(height: 12),
            _buildEnumDropdown<CurveInterpolationMethod>(
              label: 'InterpolationMethod',
              value: _interpolationMethod,
              values: CurveInterpolationMethod.values,
              required: true,
              labelOf: (v) => v.label,
              onChanged: (v) => setState(() => _interpolationMethod = v),
            ),
            const SizedBox(height: 12),
            _buildEnumDropdown<ExtrapolationMethod>(
              label: 'ExtrapolationMethod',
              value: _extrapolationMethod,
              values: ExtrapolationMethod.values,
              required: true,
              labelOf: (v) => v.label,
              onChanged: (v) => setState(() => _extrapolationMethod = v),
            ),
            const SizedBox(height: 12),
            _buildEnumDropdown<DayCountConvention>(
              label: 'DayCount',
              value: _dayCount,
              values: DayCountConvention.values,
              required: true,
              labelOf: (v) => v.label,
              onChanged: (v) => setState(() => _dayCount = v),
            ),
            const SizedBox(height: 12),
            _buildEnumDropdown<CurveCompoundingType>(
              label: 'CompoundingType',
              value: _compoundingType,
              values: CurveCompoundingType.values,
              required: true,
              labelOf: (v) => v.label,
              onChanged: (v) {
                setState(() {
                  _compoundingType = v;
                  if (v != CurveCompoundingType.compounded) {
                    _compoundingFrequency = null;
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            _buildEnumDropdown<CompoundingFrequency>(
              label: 'CompoundingFrequency',
              value: _compoundingFrequency,
              values: CompoundingFrequency.values,
              required: _compoundingType == CurveCompoundingType.compounded,
              labelOf: (v) => v.label,
              onChanged: _compoundingType == CurveCompoundingType.compounded
                  ? (v) => setState(() => _compoundingFrequency = v)
                  : (_) {},
              enabled: _compoundingType == CurveCompoundingType.compounded,
            ),
            const SizedBox(height: 12),
            _buildEnumDropdown<BusinessDayConvention>(
              label: 'BusinessDayConvention',
              value: _businessDayConvention,
              values: BusinessDayConvention.values,
              required: true,
              labelOf: (v) => v.label,
              onChanged: (v) => setState(() => _businessDayConvention = v),
            ),
            const SizedBox(height: 12),
            _buildSearchableField(
              label: 'CalendarId',
              options: _calendarOptions,
              value: _calendarId,
              onChanged: (v) => _calendarId = v,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'SettlementDays',
              controller: _settlementDaysController,
              keyboardType: TextInputType.number,
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return null;
                final parsed = int.tryParse(text);
                if (parsed == null) return 'Enter a whole number.';
                if (parsed < 0) return 'Value must be >= 0.';
                return null;
              },
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
    bool enabled = true,
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
      onChanged: enabled ? onChanged : null,
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
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
        );
      },
    );
  }

  static int? _parseInt(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }

  static String? _chooseDefault(String? value, List<String> options) {
    final normalized = (value ?? '').trim();
    if (normalized.isNotEmpty) return normalized;
    return options.isEmpty ? null : options.first;
  }
}
