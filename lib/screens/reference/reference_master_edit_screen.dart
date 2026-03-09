import 'package:flutter/material.dart';

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
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  VendorStatus? _vendorStatus;
  bool? _active;
  DateTime? _effectiveFrom;
  DateTime? _effectiveTo;

  bool get _isVendor => widget.themeId == 'vendor';
  bool get _isCurrency => widget.themeId == 'currency';
  bool get _isCreate => widget.initialData == null;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _codeController = TextEditingController(text: d?.code ?? '');
    _nameController = TextEditingController(text: d?.name ?? '');
    _descriptionController = TextEditingController(text: d?.description ?? '');
    _vendorStatus = d?.vendorStatus ?? (_isVendor ? VendorStatus.active : null);
    _active = d?.active ?? (_isCurrency ? true : null);
    _effectiveFrom = d?.effectiveFrom;
    _effectiveTo = d?.effectiveTo;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave(ReferenceMasterSaveAction action) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isVendor &&
        _effectiveFrom != null &&
        _effectiveTo != null &&
        _effectiveTo!.isBefore(_effectiveFrom!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Effective To must be on or after Effective From.'),
        ),
      );
      return;
    }

    final data = ReferenceMasterFormData(
      id: widget.initialData?.id,
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      vendorStatus: _isVendor ? _vendorStatus : null,
      active: _isCurrency ? (_active ?? true) : null,
      effectiveFrom: _isVendor ? _effectiveFrom : null,
      effectiveTo: _isVendor ? _effectiveTo : null,
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
        title: Text(
          widget.readOnly
              ? '${widget.topicLabel} View'
              : _isCreate
              ? '${widget.topicLabel} New'
              : '${widget.topicLabel} Edit',
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
                    onPressed: () => _onSave(ReferenceMasterSaveAction.create),
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Save'),
                  )
                else ...[
                  TextButton.icon(
                    onPressed: () => _onSave(ReferenceMasterSaveAction.patch),
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text('Patch'),
                  ),
                  TextButton.icon(
                    onPressed: () => _onSave(ReferenceMasterSaveAction.put),
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
              label: _isVendor
                  ? 'Vendor Code'
                  : _isCurrency
                  ? 'Currency Code'
                  : 'Code',
              controller: _codeController,
              required: true,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: _isVendor
                  ? 'Vendor Name'
                  : _isCurrency
                  ? 'Currency Name'
                  : 'Name',
              controller: _nameController,
              required: true,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 16),
            if (_isVendor) ...[
              _buildVendorStatusField(),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'Effective From',
                value: _effectiveFrom,
                onPick: (picked) => setState(() => _effectiveFrom = picked),
              ),
              const SizedBox(height: 12),
              _buildDateField(
                label: 'Effective To',
                value: _effectiveTo,
                onPick: (picked) => setState(() => _effectiveTo = picked),
              ),
            ] else if (_isCurrency) ...[
              _buildActiveField(),
            ],
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Description',
              controller: _descriptionController,
              readOnly: widget.readOnly,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorStatusField() {
    return DropdownButtonFormField<VendorStatus>(
      initialValue: _vendorStatus,
      decoration: const InputDecoration(
        labelText: 'Status *',
        border: OutlineInputBorder(),
      ),
      items: VendorStatus.values
          .map(
            (status) => DropdownMenuItem<VendorStatus>(
              value: status,
              child: Row(
                children: [
                  Icon(Icons.circle, size: 12, color: _statusColor(status)),
                  const SizedBox(width: 8),
                  Text(
                    status.uiLabel,
                    style: TextStyle(color: _statusColor(status)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: widget.readOnly
          ? null
          : (value) => setState(() => _vendorStatus = value),
      validator: (value) {
        if (value == null) return 'Status is required.';
        return null;
      },
    );
  }

  Widget _buildActiveField() {
    return SwitchListTile.adaptive(
      value: _active ?? true,
      onChanged: widget.readOnly
          ? null
          : (value) => setState(() => _active = value),
      contentPadding: EdgeInsets.zero,
      title: const Text('Active'),
      subtitle: Text((_active ?? true) ? 'Enabled' : 'Disabled'),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPick,
  }) {
    final text = value == null ? '' : _formatDate(value);
    return InkWell(
      onTap: widget.readOnly
          ? null
          : () async {
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
                text.isEmpty ? 'Select date' : text,
                style: TextStyle(
                  color: text.isEmpty ? Theme.of(context).hintColor : null,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, size: 18),
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
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (v) {
              if ((v ?? '').trim().isEmpty) return '$label is required.';
              return null;
            }
          : null,
    );
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static Color _statusColor(VendorStatus status) {
    switch (status) {
      case VendorStatus.active:
        return Colors.green;
      case VendorStatus.inactive:
        return Colors.grey;
      case VendorStatus.suspended:
        return Colors.amber.shade700;
      case VendorStatus.deprecated:
        return Colors.red;
    }
  }
}

enum ReferenceMasterSaveAction { create, patch, put }

class ReferenceMasterEditResult {
  const ReferenceMasterEditResult({required this.action, required this.data});

  final ReferenceMasterSaveAction action;
  final ReferenceMasterFormData data;
}
