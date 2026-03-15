import 'package:flutter/material.dart';

import '../../models/country_form_data.dart';
import '../../models/issuer_form_data.dart';

class IssuerEditScreen extends StatefulWidget {
  const IssuerEditScreen({
    super.key,
    this.initialData,
    required this.parentOptions,
    required this.countryOptions,
    this.readOnly = false,
  });

  final IssuerFormData? initialData;
  final List<IssuerFormData> parentOptions;
  final List<CountryFormData> countryOptions;
  final bool readOnly;

  @override
  State<IssuerEditScreen> createState() => _IssuerEditScreenState();
}

class _IssuerEditScreenState extends State<IssuerEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _issuerCodeController;
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _shortNameController;
  late TextEditingController _leiController;
  late TextEditingController _descriptionController;
  String? _countryId;
  String? _parentIssuerId;
  bool _groupFlag = false;
  bool _activeFlag = true;

  bool get _isCreate => widget.initialData == null;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _issuerCodeController = TextEditingController(text: d?.issuerCode ?? '');
    _codeController = TextEditingController(text: d?.code ?? '');
    _nameController = TextEditingController(text: d?.name ?? '');
    _shortNameController = TextEditingController(text: d?.shortName ?? '');
    _leiController = TextEditingController(text: d?.lei ?? '');
    _descriptionController = TextEditingController(text: d?.description ?? '');
    _countryId = _resolveCountryId(d);
    _parentIssuerId = _resolveParentIssuerId(d);
    _groupFlag = d?.groupFlag ?? false;
    _activeFlag = d?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _issuerCodeController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    _shortNameController.dispose();
    _leiController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave(IssuerSaveAction action) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final data = IssuerFormData(
      id: widget.initialData?.id,
      issuerCode: _issuerCodeController.text.trim(),
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      shortName: _shortNameController.text.trim(),
      countryId: (_countryId ?? '').trim(),
      countryIso2: _countryIso2ForId(_countryId),
      lei: _leiController.text.trim(),
      parentIssuerId: (_parentIssuerId ?? '').trim(),
      parentIssuerCode: _parentIssuerCodeForId(_parentIssuerId),
      groupFlag: _groupFlag,
      activeFlag: _activeFlag,
      description: _descriptionController.text.trim(),
    );
    Navigator.of(context).pop(IssuerEditResult(action: action, data: data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.readOnly
              ? 'Issuer View'
              : _isCreate
              ? 'Issuer New'
              : 'Issuer Edit',
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
                    onPressed: () => _onSave(IssuerSaveAction.create),
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Save'),
                  )
                else ...[
                  TextButton.icon(
                    onPressed: () => _onSave(IssuerSaveAction.patch),
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text('Patch'),
                  ),
                  TextButton.icon(
                    onPressed: () => _onSave(IssuerSaveAction.put),
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
              label: 'IssuerCode',
              controller: _issuerCodeController,
              required: true,
              readOnly: widget.readOnly || !_isCreate,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Code',
              controller: _codeController,
              required: true,
              readOnly: widget.readOnly,
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
              label: 'ShortName',
              controller: _shortNameController,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 12),
            _buildCountryField(),
            const SizedBox(height: 12),
            _buildParentField(),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Lei',
              controller: _leiController,
              readOnly: widget.readOnly,
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) return null;
                if (text.length > 20) return 'Lei max length is 20.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildGroupFlagField(),
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

  Widget _buildParentField() {
    final options = widget.parentOptions
        .where((e) => e.id != widget.initialData?.id)
        .toList();
    return DropdownButtonFormField<String>(
      initialValue: _parentIssuerId?.isEmpty ?? true ? null : _parentIssuerId,
      decoration: const InputDecoration(
        labelText: 'ParentIssuer',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(value: '', child: Text('Not selected')),
        ...options
            .where((item) => (item.id ?? '').isNotEmpty)
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.id!,
                child: Text('${item.issuerCode} | ${item.name}'),
              ),
            ),
      ],
      onChanged: widget.readOnly
          ? null
          : (value) => setState(() => _parentIssuerId = value),
    );
  }

  Widget _buildCountryField() {
    return DropdownButtonFormField<String>(
      initialValue: _countryId?.isEmpty ?? true ? null : _countryId,
      decoration: const InputDecoration(
        labelText: 'Country',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(value: '', child: Text('Not selected')),
        ...widget.countryOptions
            .where((country) => (country.id ?? '').isNotEmpty)
            .map(
              (country) => DropdownMenuItem<String>(
                value: country.id!,
                child: Text(
                  '${country.countryIso2} | ${country.name.isEmpty ? country.countryIso3 : country.name}',
                ),
              ),
            ),
      ],
      onChanged: widget.readOnly
          ? null
          : (value) => setState(() => _countryId = value),
    );
  }

  Widget _buildSwitchField() {
    return InputDecorator(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      child: Row(
        children: [
          const Text('ActiveFlag *'),
          const Spacer(),
          Switch(
            value: _activeFlag,
            onChanged: widget.readOnly
                ? null
                : (value) => setState(() => _activeFlag = value),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupFlagField() {
    return InputDecorator(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      child: Row(
        children: [
          const Text('GroupFlag'),
          const Spacer(),
          Switch(
            value: _groupFlag,
            onChanged: widget.readOnly
                ? null
                : (value) => setState(() => _groupFlag = value),
          ),
        ],
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
              ? (v) {
                  if ((v ?? '').trim().isEmpty) return '$label is required.';
                  return null;
                }
              : null),
    );
  }

  String? _resolveCountryId(IssuerFormData? data) {
    if (data == null) return null;
    final directId = data.countryId.trim();
    if (directId.isNotEmpty) {
      final exists = widget.countryOptions.any((item) => item.id == directId);
      if (exists) return directId;
    }
    final iso2 = data.countryIso2.trim().toUpperCase();
    if (iso2.isEmpty) return null;
    for (final item in widget.countryOptions) {
      if (item.countryIso2.trim().toUpperCase() == iso2) {
        return item.id;
      }
    }
    return null;
  }

  String _countryIso2ForId(String? id) {
    final normalizedId = (id ?? '').trim();
    if (normalizedId.isEmpty) return '';
    for (final item in widget.countryOptions) {
      if (item.id == normalizedId) {
        return item.countryIso2.trim().toUpperCase();
      }
    }
    return '';
  }

  String? _resolveParentIssuerId(IssuerFormData? data) {
    if (data == null) return null;
    final directId = data.parentIssuerId.trim();
    if (directId.isNotEmpty) {
      final exists = widget.parentOptions.any((item) => item.id == directId);
      if (exists) return directId;
    }
    final code = data.parentIssuerCode.trim();
    if (code.isEmpty) return null;
    for (final item in widget.parentOptions) {
      if (item.issuerCode == code) {
        return item.id;
      }
    }
    return null;
  }

  String _parentIssuerCodeForId(String? id) {
    final normalizedId = (id ?? '').trim();
    if (normalizedId.isEmpty) return '';
    for (final item in widget.parentOptions) {
      if (item.id == normalizedId) {
        return item.issuerCode;
      }
    }
    return '';
  }
}

enum IssuerSaveAction { create, patch, put }

class IssuerEditResult {
  const IssuerEditResult({required this.action, required this.data});

  final IssuerSaveAction action;
  final IssuerFormData data;
}
