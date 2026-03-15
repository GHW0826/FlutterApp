import 'package:flutter/material.dart';

import '../../models/calendar_enums.dart';
import '../../models/calendar_form_data.dart';
import '../../models/country_form_data.dart';

class CalendarEditScreen extends StatefulWidget {
  const CalendarEditScreen({
    super.key,
    this.initialData,
    required this.countryOptions,
  });

  final CalendarFormData? initialData;
  final List<CountryFormData> countryOptions;

  @override
  State<CalendarEditScreen> createState() => _CalendarEditScreenState();
}

class _CalendarEditScreenState extends State<CalendarEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _calendarCodeController;
  late TextEditingController _nameController;
  late TextEditingController _regionCodeController;
  late TextEditingController _timezoneController;
  CalendarType? _type;
  String _countryId = '';
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _calendarCodeController = TextEditingController(
      text: data?.calendarCode ?? '',
    );
    _nameController = TextEditingController(text: data?.name ?? '');
    _regionCodeController = TextEditingController(text: data?.regionCode ?? '');
    _timezoneController = TextEditingController(
      text: data?.timezone.isNotEmpty == true ? data!.timezone : 'Asia/Seoul',
    );
    _type = data?.type ?? CalendarType.countryPublic;
    _countryId = _resolveInitialCountryId(data);
    _active = data?.active ?? true;
  }

  @override
  void dispose() {
    _calendarCodeController.dispose();
    _nameController.dispose();
    _regionCodeController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  CountryFormData? get _selectedCountry {
    if (_countryId.isEmpty) return null;
    for (final country in widget.countryOptions) {
      if ((country.id ?? '') == _countryId) return country;
    }
    return null;
  }

  String _resolveInitialCountryId(CalendarFormData? data) {
    final directId = data?.countryId.trim() ?? '';
    if (directId.isNotEmpty &&
        widget.countryOptions.any((country) => country.id == directId)) {
      return directId;
    }
    final iso2 = data?.countryIso2.trim().toUpperCase() ?? '';
    if (iso2.isEmpty) return '';
    for (final country in widget.countryOptions) {
      if (country.countryIso2.toUpperCase() == iso2) {
        return country.id ?? '';
      }
    }
    return '';
  }

  void _onCountryChanged(String? value) {
    final nextId = (value ?? '').trim();
    setState(() => _countryId = nextId);
    final country = _selectedCountry;
    if (country != null) {
      _timezoneController.text = country.timezone;
    }
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final country = _selectedCountry;
    final data = CalendarFormData(
      id: widget.initialData?.id,
      calendarCode: _calendarCodeController.text.trim(),
      name: _nameController.text.trim(),
      type: _type ?? CalendarType.countryPublic,
      countryId: _countryId.trim(),
      countryIso2: country?.countryIso2 ?? '',
      countryIso3: country?.countryIso3 ?? '',
      countryName: country?.name ?? '',
      regionCode: _regionCodeController.text.trim(),
      timezone: _timezoneController.text.trim(),
      active: _active,
    );
    Navigator.of(context).pop(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialData == null ? 'Calendar New' : 'Calendar Edit',
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
              label: 'CalendarCode',
              controller: _calendarCodeController,
              required: true,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Name',
              controller: _nameController,
              required: true,
            ),
            const SizedBox(height: 12),
            _buildEnumDropdown<CalendarType>(
              label: 'Type',
              value: _type,
              values: CalendarType.values,
              required: true,
              labelOf: (value) => value.uiLabel,
              onChanged: (value) => setState(() => _type = value),
            ),
            const SizedBox(height: 12),
            _buildCountryDropdown(),
            const SizedBox(height: 12),
            _buildCountryHint(),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'RegionCode',
              controller: _regionCodeController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Timezone',
              controller: _timezoneController,
              required: true,
            ),
            const SizedBox(height: 12),
            _buildSwitchField(
              label: 'Active',
              value: _active,
              onChanged: (value) => setState(() => _active = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(value: '', child: Text('-')),
      ...widget.countryOptions
          .where((country) => (country.id ?? '').isNotEmpty)
          .map(
            (country) => DropdownMenuItem<String>(
              value: country.id!,
              child: Text(country.displayCode),
            ),
          ),
    ];
    return DropdownButtonFormField<String>(
      initialValue: _countryId,
      decoration: const InputDecoration(
        labelText: 'Country (ISO3)',
        border: OutlineInputBorder(),
      ),
      items: items,
      onChanged: _onCountryChanged,
    );
  }

  Widget _buildCountryHint() {
    final country = _selectedCountry;
    final label = country == null
        ? 'No country selected.'
        : '${country.displayCode} | ${country.name} | ${country.timezone}';
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Selected Country',
        border: OutlineInputBorder(),
      ),
      child: Text(label),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
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
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(labelOf(item))),
          )
          .toList(),
      onChanged: onChanged,
      validator: required
          ? (value) => value == null ? '$label is required.' : null
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
}
