import 'package:flutter/material.dart';

import '../../models/issuer_form_data.dart';

class IssuerEditScreen extends StatefulWidget {
  const IssuerEditScreen({
    super.key,
    this.initialData,
    required this.parentOptions,
    this.readOnly = false,
  });

  final IssuerFormData? initialData;
  final List<IssuerFormData> parentOptions;
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
  late TextEditingController _countryIso2Controller;
  late TextEditingController _leiController;
  late TextEditingController _descriptionController;
  String _parentIssuerCode = '';
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
    _countryIso2Controller = TextEditingController(text: d?.countryIso2 ?? '');
    _leiController = TextEditingController(text: d?.lei ?? '');
    _descriptionController = TextEditingController(text: d?.description ?? '');
    _parentIssuerCode = d?.parentIssuerCode ?? '';
    _activeFlag = d?.activeFlag ?? true;
  }

  @override
  void dispose() {
    _issuerCodeController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    _shortNameController.dispose();
    _countryIso2Controller.dispose();
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
      countryIso2: _countryIso2Controller.text.trim().toUpperCase(),
      lei: _leiController.text.trim(),
      parentIssuerCode: _parentIssuerCode.trim(),
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
            _buildTextField(
              label: 'CountryIso2',
              controller: _countryIso2Controller,
              readOnly: widget.readOnly,
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) return null;
                if (text.length != 2) return 'CountryIso2 must be 2 letters.';
                return null;
              },
            ),
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
            _buildParentField(),
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
        .where((e) => e.issuerCode != _issuerCodeController.text.trim())
        .toList();
    return Autocomplete<String>(
      initialValue: TextEditingValue(
        text: _labelForParentCode(_parentIssuerCode, options),
      ),
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();
        final labels = options
            .map((e) => '${e.issuerCode} | ${e.name}')
            .toList(growable: false);
        if (query.isEmpty) return labels;
        return labels.where((e) => e.toLowerCase().contains(query));
      },
      onSelected: (selected) {
        _parentIssuerCode = selected.split('|').first.trim();
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (widget.readOnly) {
          controller.text = _labelForParentCode(_parentIssuerCode, options);
        }
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          readOnly: widget.readOnly,
          decoration: const InputDecoration(
            labelText: 'ParentIssuer',
            border: OutlineInputBorder(),
            hintText: 'IssuerCode | Name',
          ),
          onChanged: (text) {
            final candidate = text.split('|').first.trim();
            if (candidate.isEmpty) {
              _parentIssuerCode = '';
              return;
            }
            final matched = options
                .where((e) => e.issuerCode == candidate)
                .firstOrNull;
            _parentIssuerCode = matched?.issuerCode ?? candidate;
          },
          validator: (value) {
            final text = (value ?? '').trim();
            if (text.isEmpty) return null;
            final candidate = text.split('|').first.trim();
            final exists = options.any((e) => e.issuerCode == candidate);
            if (!exists) return 'Parent issuer does not exist.';
            return null;
          },
        );
      },
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

  String _labelForParentCode(String code, List<IssuerFormData> options) {
    final normalized = code.trim();
    if (normalized.isEmpty) return '';
    final matched = options
        .where((e) => e.issuerCode == normalized)
        .firstOrNull;
    if (matched == null) return normalized;
    return '${matched.issuerCode} | ${matched.name}';
  }
}

enum IssuerSaveAction { create, patch, put }

class IssuerEditResult {
  const IssuerEditResult({required this.action, required this.data});

  final IssuerSaveAction action;
  final IssuerFormData data;
}
