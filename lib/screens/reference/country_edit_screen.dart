import 'package:flutter/material.dart';

import '../../models/country_form_data.dart';

class CountryEditScreen extends StatefulWidget {
  const CountryEditScreen({super.key, this.initialData, this.readOnly = false});

  final CountryFormData? initialData;
  final bool readOnly;

  @override
  State<CountryEditScreen> createState() => _CountryEditScreenState();
}

class _CountryEditScreenState extends State<CountryEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _countryIso2Controller;
  late TextEditingController _countryIso3Controller;
  late TextEditingController _numericCodeController;
  late TextEditingController _nameController;
  late TextEditingController _timezoneController;
  late TextEditingController _descriptionController;
  bool _active = true;

  bool get _isCreate => widget.initialData == null;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _countryIso2Controller = TextEditingController(
      text: data?.countryIso2 ?? '',
    );
    _countryIso3Controller = TextEditingController(
      text: data?.countryIso3 ?? '',
    );
    _numericCodeController = TextEditingController(
      text: data?.numericCode ?? '',
    );
    _nameController = TextEditingController(text: data?.name ?? '');
    _timezoneController = TextEditingController(text: data?.timezone ?? '');
    _descriptionController = TextEditingController(
      text: data?.description ?? '',
    );
    _active = data?.active ?? true;
  }

  @override
  void dispose() {
    _countryIso2Controller.dispose();
    _countryIso3Controller.dispose();
    _numericCodeController.dispose();
    _nameController.dispose();
    _timezoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave(CountrySaveAction action) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      CountryEditResult(
        action: action,
        data: CountryFormData(
          id: widget.initialData?.id,
          countryIso2: _countryIso2Controller.text.trim().toUpperCase(),
          countryIso3: _countryIso3Controller.text.trim().toUpperCase(),
          numericCode: _numericCodeController.text.trim(),
          name: _nameController.text.trim(),
          timezone: _timezoneController.text.trim(),
          active: _active,
          description: _descriptionController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.readOnly
              ? 'Country View'
              : _isCreate
              ? 'Country New'
              : 'Country Edit',
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: widget.readOnly
            ? null
            : [
                if (_isCreate)
                  TextButton.icon(
                    onPressed: () => _onSave(CountrySaveAction.create),
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Save'),
                  )
                else ...[
                  TextButton.icon(
                    onPressed: () => _onSave(CountrySaveAction.patch),
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text('Patch'),
                  ),
                  TextButton.icon(
                    onPressed: () => _onSave(CountrySaveAction.put),
                    icon: const Icon(Icons.sync_alt, size: 20),
                    label: const Text('Put'),
                  ),
                ],
                const SizedBox(width: 8),
              ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              label: 'CountryIso2',
              controller: _countryIso2Controller,
              required: true,
              readOnly: widget.readOnly,
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return 'CountryIso2 is required.';
                if (text.length != 2) return 'CountryIso2 must be 2 letters.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'CountryIso3',
              controller: _countryIso3Controller,
              readOnly: widget.readOnly,
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return null;
                if (text.length != 3) return 'CountryIso3 must be 3 letters.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'NumericCode',
              controller: _numericCodeController,
              readOnly: widget.readOnly,
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return null;
                if (text.length != 3) return 'NumericCode must be 3 digits.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Name',
              controller: _nameController,
              required: true,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Timezone',
              controller: _timezoneController,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 12),
            _buildSwitchField(),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Description',
              controller: _descriptionController,
              readOnly: widget.readOnly,
              maxLines: 4,
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
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

  Widget _buildSwitchField() {
    return InputDecorator(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      child: Row(
        children: [
          const Text('Active *'),
          const Spacer(),
          Switch(
            value: _active,
            onChanged: widget.readOnly
                ? null
                : (value) => setState(() => _active = value),
          ),
        ],
      ),
    );
  }
}

enum CountrySaveAction { create, patch, put }

class CountryEditResult {
  const CountryEditResult({required this.action, required this.data});

  final CountrySaveAction action;
  final CountryFormData data;
}
