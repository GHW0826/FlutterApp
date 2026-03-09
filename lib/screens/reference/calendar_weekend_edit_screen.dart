import 'package:flutter/material.dart';

import '../../models/calendar_weekend_form_data.dart';

class CalendarWeekendEditScreen extends StatefulWidget {
  const CalendarWeekendEditScreen({
    super.key,
    this.initialData,
    required this.calendarOptions,
  });

  final CalendarWeekendFormData? initialData;
  final List<String> calendarOptions;

  @override
  State<CalendarWeekendEditScreen> createState() =>
      _CalendarWeekendEditScreenState();
}

class _CalendarWeekendEditScreenState extends State<CalendarWeekendEditScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _calendarCode;
  DateTime? _validFrom;
  DateTime? _validTo;
  String? _weekendProfileCode;

  static const _weekendProfiles = <String>[
    'SAT_SUN',
    'FRI_SAT',
    'SUN_ONLY',
    'NONE',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _calendarCode = _chooseDefault(d?.calendarCode, widget.calendarOptions);
    _validFrom = d?.validFrom;
    _validTo = d?.validTo;
    _weekendProfileCode = _chooseDefault(
      d?.weekendProfileCode,
      _weekendProfiles,
    );
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_validFrom == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ValidFrom is required.')));
      return;
    }
    if (_validTo != null && !_validTo!.isAfter(_validFrom!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ValidTo must be after ValidFrom.')),
      );
      return;
    }
    final data = CalendarWeekendFormData(
      id: widget.initialData?.id,
      calendarCode: (_calendarCode ?? '').trim(),
      validFrom: _validFrom,
      validTo: _validTo,
      weekendProfileCode: (_weekendProfileCode ?? '').trim(),
    );
    Navigator.of(context).pop(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialData == null
              ? 'CalendarWeekend New'
              : 'CalendarWeekend Edit',
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
              label: 'CalendarCode',
              options: widget.calendarOptions,
              value: _calendarCode,
              required: true,
              onChanged: (value) => _calendarCode = value,
            ),
            const SizedBox(height: 12),
            _buildDateField(
              label: 'ValidFrom',
              value: _validFrom,
              required: true,
              onPick: (value) => setState(() => _validFrom = value),
            ),
            const SizedBox(height: 12),
            _buildDateField(
              label: 'ValidTo',
              value: _validTo,
              onPick: (value) => setState(() => _validTo = value),
              onClear: () => setState(() => _validTo = null),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label: 'WeekendProfile',
              value: _weekendProfileCode,
              options: _weekendProfiles,
              required: true,
              onChanged: (value) => setState(() => _weekendProfileCode = value),
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: required
          ? (v) => (v ?? '').trim().isEmpty ? '$label is required.' : null
          : null,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPick,
    VoidCallback? onClear,
    bool required = false,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null ? 'Select date' : _formatDate(value),
                style: value == null
                    ? TextStyle(color: Theme.of(context).hintColor)
                    : null,
              ),
            ),
            if (onClear != null && value != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 16),
                tooltip: 'Clear',
              ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  static String? _chooseDefault(String? value, List<String> options) {
    final normalized = (value ?? '').trim();
    if (normalized.isNotEmpty) return normalized;
    return options.isEmpty ? null : options.first;
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
