import 'package:flutter/material.dart';

import '../../api/calendar_api_client.dart';
import '../../models/bond_curve_build_method_form_data.dart';
import '../../models/calendar_form_data.dart';

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

  final TextEditingController _buildMethodCodeController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _settlementDaysController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<CalendarFormData> _calendarOptions = [];
  bool _loadingOptions = true;

  String _fittingMethod = '';
  String _interpolationMethod = '';
  String _extrapolationMethod = '';
  String _dayCountConvention = '';
  String _compoundingType = '';
  String _compoundingFrequency = '';
  String _businessDayConvention = '';
  String _calendarId = '';
  bool _active = true;

  static const List<String> _fittingMethodOptions = [
    'Bootstrap',
    'SplineFit',
    'NelsonSiegel',
    'Svensson',
  ];

  static const List<String> _interpolationMethodOptions = [
    'LinearZero',
    'LoglinearDF',
    'CubicSplineZero',
  ];

  static const List<String> _extrapolationMethodOptions = [
    'FlatZero',
    'FlatFwd',
  ];

  static const List<String> _dayCountConventionOptions = [
    'ACT360',
    'ACT365F',
    'Thirty360',
  ];

  static const List<String> _compoundingTypeOptions = [
    'Simple',
    'Compounded',
    'Continuous',
  ];

  static const List<String> _compoundingFrequencyOptions = [
    'Annual',
    'SemiAnnual',
    'Quarterly',
    'Monthly',
  ];

  static const List<String> _businessDayConventionOptions = [
    'Following',
    'ModifiedFollowing',
    'Preceding',
  ];

  bool get _isCreate => widget.initialData == null;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _buildMethodCodeController.text = data?.buildMethodCode ?? '';
    _nameController.text = data?.name ?? '';
    _settlementDaysController.text = data?.settlementDays?.toString() ?? '';
    _descriptionController.text = data?.description ?? '';
    _fittingMethod = data?.fittingMethod ?? '';
    _interpolationMethod = data?.interpolationMethod ?? '';
    _extrapolationMethod = data?.extrapolationMethod ?? '';
    _dayCountConvention = data?.dayCountConvention ?? '';
    _compoundingType = data?.compoundingType ?? '';
    _compoundingFrequency = data?.compoundingFrequency ?? '';
    _businessDayConvention = data?.businessDayConvention ?? '';
    _calendarId = data?.calendarId ?? '';
    _active = data?.active ?? true;
    _loadOptions();
  }

  @override
  void dispose() {
    _buildMethodCodeController.dispose();
    _nameController.dispose();
    _settlementDaysController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final items = await calendarApi.getCalendarList();
      if (!mounted) return;
      setState(() {
        _calendarOptions = items;
        _calendarId = _resolveCalendarId(_calendarId);
        _loadingOptions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _calendarOptions = [];
        _loadingOptions = false;
      });
    }
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final normalizedCompoundingFrequency = _compoundingType == 'Compounded'
        ? _compoundingFrequency
        : '';

    Navigator.of(context).pop(
      BondCurveBuildMethodFormData(
        id: widget.initialData?.id,
        buildMethodCode: _buildMethodCodeController.text.trim(),
        name: _nameController.text.trim(),
        fittingMethod: _fittingMethod,
        interpolationMethod: _interpolationMethod,
        extrapolationMethod: _extrapolationMethod,
        dayCountConvention: _dayCountConvention,
        compoundingType: _compoundingType,
        compoundingFrequency: normalizedCompoundingFrequency,
        businessDayConvention: _businessDayConvention,
        calendarId: _calendarId,
        calendarCode: _calendarCodeForId(_calendarId),
        settlementDays: _parseInt(_settlementDaysController.text),
        active: _active,
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isCreate ? 'BondCurveBuildMethod New' : 'BondCurveBuildMethod Edit',
        ),
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
                    label: 'BuildMethodCode',
                    controller: _buildMethodCodeController,
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
                    label: 'FittingMethod',
                    value: _fittingMethod,
                    required: true,
                    items: _fittingMethodOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _fittingMethod = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'InterpolationMethod',
                    value: _interpolationMethod,
                    required: true,
                    items: _interpolationMethodOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _interpolationMethod = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'ExtrapolationMethod',
                    value: _extrapolationMethod,
                    required: true,
                    items: _extrapolationMethodOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _extrapolationMethod = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'DayCountConvention',
                    value: _dayCountConvention,
                    required: true,
                    items: _dayCountConventionOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _dayCountConvention = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'CompoundingType',
                    value: _compoundingType,
                    required: true,
                    items: _compoundingTypeOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _compoundingType = value ?? '';
                        if (_compoundingType != 'Compounded') {
                          _compoundingFrequency = '';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'CompoundingFrequency',
                    value: _compoundingFrequency,
                    items: _compoundingFrequencyOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: _compoundingType == 'Compounded'
                        ? (value) => setState(
                            () => _compoundingFrequency = value ?? '',
                          )
                        : (_) {},
                    required: _compoundingType == 'Compounded',
                    enabled: _compoundingType == 'Compounded',
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'BusinessDayConvention',
                    value: _businessDayConvention,
                    required: true,
                    items: _businessDayConventionOptions
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _businessDayConvention = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    label: 'Calendar',
                    value: _calendarId,
                    items: _calendarOptions
                        .where((item) => (item.id ?? '').isNotEmpty)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id!,
                            child: Text('${item.calendarCode} | ${item.name}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _calendarId = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'SettlementDays',
                    controller: _settlementDaysController,
                    keyboardType: TextInputType.number,
                    validator: _optionalIntegerValidator,
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchField(
                    label: 'Active',
                    value: _active,
                    onChanged: (value) => setState(() => _active = value),
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
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: enabled ? onChanged : null,
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

  String _resolveCalendarId(String rawId) {
    final normalized = rawId.trim();
    if (normalized.isEmpty) return '';
    for (final item in _calendarOptions) {
      if ((item.id ?? '') == normalized) {
        return normalized;
      }
    }
    return '';
  }

  String _calendarCodeForId(String id) {
    for (final item in _calendarOptions) {
      if ((item.id ?? '') == id) {
        return item.calendarCode;
      }
    }
    return '';
  }

  static int? _parseInt(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  static String? _optionalIntegerValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    return int.tryParse(text) == null ? 'Enter a whole number.' : null;
  }
}
