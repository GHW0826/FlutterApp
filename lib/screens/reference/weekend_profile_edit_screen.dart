import 'package:flutter/material.dart';

import '../../models/weekend_profile_form_data.dart';

class WeekendProfileEditScreen extends StatefulWidget {
  const WeekendProfileEditScreen({super.key, this.initialData});

  final WeekendProfileFormData? initialData;

  @override
  State<WeekendProfileEditScreen> createState() => _WeekendProfileEditScreenState();
}

class _WeekendProfileEditScreenState extends State<WeekendProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _codeController = TextEditingController(text: data?.weekendProfileCode ?? '');
    _descriptionController = TextEditingController(text: data?.description ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      WeekendProfileFormData(
        id: widget.initialData?.id,
        weekendProfileCode: _codeController.text.trim(),
        name: _codeController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialData == null ? 'WeekendProfile New' : 'WeekendProfile Edit',
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
            _buildField('WeekendProfileCode', _codeController, required: true),
            const SizedBox(height: 12),
            _buildField('Description', _descriptionController, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
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
          ? (value) => (value ?? '').trim().isEmpty ? '$label is required.' : null
          : null,
    );
  }
}
