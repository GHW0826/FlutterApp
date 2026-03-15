import 'package:flutter/material.dart';

import '../../models/calendar_enums.dart';
import '../../models/calendar_set_form_data.dart';

class CalendarSetEditScreen extends StatefulWidget {
  const CalendarSetEditScreen({super.key, this.initialData});

  final CalendarSetFormData? initialData;

  @override
  State<CalendarSetEditScreen> createState() => _CalendarSetEditScreenState();
}

class _CalendarSetEditScreenState extends State<CalendarSetEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _setCodeController;
  CalendarJoinRule? _joinRule;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _setCodeController = TextEditingController(text: d?.setCode ?? '');
    _joinRule = d?.joinRule ?? CalendarJoinRule.joinHolidays;
    _descriptionController = TextEditingController(text: d?.description ?? '');
  }

  @override
  void dispose() {
    _setCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final data = CalendarSetFormData(
      id: widget.initialData?.id,
      setCode: _setCodeController.text.trim(),
      joinRule: _joinRule ?? CalendarJoinRule.joinHolidays,
      description: _descriptionController.text.trim(),
    );
    Navigator.of(context).pop(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialData == null ? 'CalendarSet New' : 'CalendarSet Edit',
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
              label: 'SetCode',
              controller: _setCodeController,
              required: true,
            ),
            const SizedBox(height: 12),
            _buildEnumDropdown<CalendarJoinRule>(
              label: 'JoinRule',
              value: _joinRule,
              values: CalendarJoinRule.values,
              required: true,
              labelOf: (v) => v.uiLabel,
              onChanged: (v) => setState(() => _joinRule = v),
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
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (v) => (v ?? '').trim().isEmpty ? '$label is required.' : null
          : null,
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
}
