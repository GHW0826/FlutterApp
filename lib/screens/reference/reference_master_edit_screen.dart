import 'package:flutter/material.dart';

import '../../l10n/app_text.dart';
import '../../models/reference_master_form_data.dart';

class ReferenceMasterEditScreen extends StatefulWidget {
  const ReferenceMasterEditScreen({
    super.key,
    required this.themeId,
    required this.topicLabel,
    this.initialData,
    this.readOnly = false,
  });

  final String themeId;
  final String topicLabel;
  final ReferenceMasterFormData? initialData;
  final bool readOnly;

  @override
  State<ReferenceMasterEditScreen> createState() =>
      _ReferenceMasterEditScreenState();
}

class _ReferenceMasterEditScreenState extends State<ReferenceMasterEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _shortNameController;
  late final TextEditingController _homepageUrlController;
  late final TextEditingController _descriptionController;

  bool _active = true;

  bool get _isVendor => widget.themeId == 'vendor';
  bool get _isCreate => widget.initialData == null;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _codeController = TextEditingController(text: data?.code ?? '');
    _nameController = TextEditingController(text: data?.name ?? '');
    _shortNameController = TextEditingController(text: data?.shortName ?? '');
    _homepageUrlController = TextEditingController(
      text: data?.homepageUrl ?? '',
    );
    _descriptionController = TextEditingController(
      text: data?.description ?? '',
    );
    _active = data?.active ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _shortNameController.dispose();
    _homepageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave(ReferenceMasterSaveAction action) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = ReferenceMasterFormData(
      id: widget.initialData?.id,
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      shortName: _isVendor ? _shortNameController.text.trim() : '',
      homepageUrl: _isVendor ? _homepageUrlController.text.trim() : '',
      vendorStatus: _isVendor
          ? (_active ? VendorStatus.active : VendorStatus.inactive)
          : null,
      active: _isVendor ? _active : null,
      description: _descriptionController.text.trim(),
    );
    Navigator.of(
      context,
    ).pop(ReferenceMasterEditResult(action: action, data: data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_buildScreenTitle(context)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: widget.readOnly
            ? null
            : [
                if (_isCreate)
                  TextButton.icon(
                    onPressed: () => _onSave(ReferenceMasterSaveAction.create),
                    icon: const Icon(Icons.check, size: 20),
                    label: Text(context.tr(en: 'Save', ko: 'Save')),
                  )
                else ...[
                  TextButton.icon(
                    onPressed: () => _onSave(ReferenceMasterSaveAction.patch),
                    icon: const Icon(Icons.edit, size: 20),
                    label: Text(context.tr(en: 'Patch', ko: 'Patch')),
                  ),
                  TextButton.icon(
                    onPressed: () => _onSave(ReferenceMasterSaveAction.put),
                    icon: const Icon(Icons.sync_alt, size: 20),
                    label: Text(context.tr(en: 'Put', ko: 'Put')),
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
              label: _codeLabel(context),
              controller: _codeController,
              required: true,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: _nameLabel(context),
              controller: _nameController,
              required: true,
              readOnly: widget.readOnly,
            ),
            if (_isVendor) ...[
              const SizedBox(height: 16),
              _buildTextField(
                label: context.tr(en: 'Short Name', ko: 'Short Name'),
                controller: _shortNameController,
                readOnly: widget.readOnly,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: context.tr(en: 'Homepage URL', ko: 'Homepage URL'),
                controller: _homepageUrlController,
                readOnly: widget.readOnly,
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return null;
                  final uri = Uri.tryParse(text);
                  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                    return context.tr(en: 'Enter a valid URL.', ko: 'Enter a valid URL.');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildActiveField(),
            ],
            const SizedBox(height: 16),
            _buildTextField(
              label: context.tr(en: 'Description', ko: 'Description'),
              controller: _descriptionController,
              readOnly: widget.readOnly,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  String _buildScreenTitle(BuildContext context) {
    if (widget.readOnly) {
      return context.tr(
        en: '${widget.topicLabel} View',
        ko: '${widget.topicLabel} View',
      );
    }
    if (_isCreate) {
      return context.tr(
        en: '${widget.topicLabel} New',
        ko: '${widget.topicLabel} New',
      );
    }
    return context.tr(
      en: '${widget.topicLabel} Edit',
      ko: '${widget.topicLabel} Edit',
    );
  }

  String _codeLabel(BuildContext context) {
    if (_isVendor) {
      return context.tr(en: 'Vendor Code', ko: 'Vendor Code');
    }
    if (widget.themeId == 'currency') {
      return context.tr(en: 'Currency Code', ko: 'Currency Code');
    }
    return context.tr(en: 'Code', ko: 'Code');
  }

  String _nameLabel(BuildContext context) {
    if (_isVendor) {
      return context.tr(en: 'Vendor Name', ko: 'Vendor Name');
    }
    if (widget.themeId == 'currency') {
      return context.tr(en: 'Currency Name', ko: 'Currency Name');
    }
    return context.tr(en: 'Name', ko: 'Name');
  }

  Widget _buildActiveField() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'Active', ko: 'Active'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _active
                      ? context.tr(en: 'Enabled', ko: 'Enabled')
                      : context.tr(en: 'Disabled', ko: 'Disabled'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: _active,
            onChanged: widget.readOnly
                ? null
                : (value) => setState(() => _active = value),
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
              ? (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return context.tr(en: '$label is required.', ko: '$label is required.');
                  }
                  return null;
                }
              : null),
    );
  }
}

enum ReferenceMasterSaveAction { create, patch, put }

class ReferenceMasterEditResult {
  const ReferenceMasterEditResult({required this.action, required this.data});

  final ReferenceMasterSaveAction action;
  final ReferenceMasterFormData data;
}
