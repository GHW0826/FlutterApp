import 'package:flutter/material.dart';

import '../../models/calendar_set_member_form_data.dart';

class CalendarSetMemberEditScreen extends StatefulWidget {
  const CalendarSetMemberEditScreen({
    super.key,
    this.initialData,
    required this.calendarSetOptions,
    required this.calendarOptions,
  });

  final CalendarSetMemberFormData? initialData;
  final List<String> calendarSetOptions;
  final List<String> calendarOptions;

  @override
  State<CalendarSetMemberEditScreen> createState() =>
      _CalendarSetMemberEditScreenState();
}

class _CalendarSetMemberEditScreenState
    extends State<CalendarSetMemberEditScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _calendarSetCode;
  String? _calendarCode;
  late TextEditingController _seqNoController;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _calendarSetCode = _chooseDefault(
      d?.calendarSetCode,
      widget.calendarSetOptions,
    );
    _calendarCode = _chooseDefault(d?.calendarCode, widget.calendarOptions);
    _seqNoController = TextEditingController(text: (d?.seqNo ?? 1).toString());
  }

  @override
  void dispose() {
    _seqNoController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final data = CalendarSetMemberFormData(
      id: widget.initialData?.id,
      calendarSetCode: (_calendarSetCode ?? '').trim(),
      calendarCode: (_calendarCode ?? '').trim(),
      seqNo: int.parse(_seqNoController.text.trim()),
    );
    Navigator.of(context).pop(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialData == null
              ? 'CalendarSetMember New'
              : 'CalendarSetMember Edit',
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
            _buildSearchableField(
              label: 'CalendarSetCode',
              options: widget.calendarSetOptions,
              value: _calendarSetCode,
              required: true,
              onChanged: (value) => _calendarSetCode = value,
            ),
            const SizedBox(height: 12),
            _buildSearchableField(
              label: 'CalendarCode',
              options: widget.calendarOptions,
              value: _calendarCode,
              required: true,
              onChanged: (value) => _calendarCode = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _seqNoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'SeqNo *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return 'SeqNo is required.';
                final parsed = int.tryParse(text);
                if (parsed == null) return 'Enter a whole number.';
                if (parsed <= 0) return 'SeqNo must be greater than zero.';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchableField({
    required String label,
    required List<String> options,
    required String? value,
    required ValueChanged<String> onChanged,
    bool required = false,
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
            labelText: required ? '$label *' : label,
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
          validator: required
              ? (v) => (v ?? '').trim().isEmpty ? '$label is required.' : null
              : null,
        );
      },
    );
  }

  static String? _chooseDefault(String? value, List<String> options) {
    final normalized = (value ?? '').trim();
    if (normalized.isNotEmpty) return normalized;
    return options.isEmpty ? null : options.first;
  }
}
