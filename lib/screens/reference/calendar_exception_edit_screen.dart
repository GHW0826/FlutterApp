import 'package:flutter/material.dart';

import '../../models/calendar_enums.dart';
import '../../models/calendar_exception_form_data.dart';

class CalendarExceptionEditScreen extends StatefulWidget {
  const CalendarExceptionEditScreen({
    super.key,
    this.initialData,
    required this.calendarOptions,
  });

  final CalendarExceptionFormData? initialData;
  final List<String> calendarOptions;

  @override
  State<CalendarExceptionEditScreen> createState() =>
      _CalendarExceptionEditScreenState();
}

class _CalendarExceptionEditScreenState
    extends State<CalendarExceptionEditScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _calendarCode;
  DateTime? _exceptionDate;
  bool _businessDay = false;
  CalendarExceptionType? _exceptionType;
  late TextEditingController _nameController;
  DateTime? _observedOf;
  late TextEditingController _sourceController;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _calendarCode = _chooseDefault(d?.calendarCode, widget.calendarOptions);
    _exceptionDate = d?.exceptionDate;
    _businessDay = d?.businessDay ?? false;
    _exceptionType = d?.exceptionType ?? CalendarExceptionType.holiday;
    _nameController = TextEditingController(text: d?.name ?? '');
    _observedOf = d?.observedOf;
    _sourceController = TextEditingController(text: d?.source ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_exceptionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ExceptionDate is required.')),
      );
      return;
    }
    final data = CalendarExceptionFormData(
      id: widget.initialData?.id,
      calendarCode: (_calendarCode ?? '').trim(),
      exceptionDate: _exceptionDate,
      businessDay: _businessDay,
      exceptionType: _exceptionType ?? CalendarExceptionType.holiday,
      name: _nameController.text.trim(),
      observedOf: _observedOf,
      source: _sourceController.text.trim(),
      createdAt: widget.initialData?.createdAt,
    );
    Navigator.of(context).pop(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialData == null
              ? 'CalendarException New'
              : 'CalendarException Edit',
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
              label: 'ExceptionDate',
              value: _exceptionDate,
              required: true,
              onPick: (value) => setState(() => _exceptionDate = value),
            ),
            const SizedBox(height: 12),
            _buildSwitchField(
              label: 'IsBusinessDay',
              value: _businessDay,
              onChanged: (v) => setState(() => _businessDay = v),
            ),
            const SizedBox(height: 12),
            _buildEnumDropdown<CalendarExceptionType>(
              label: 'ExceptionType',
              value: _exceptionType,
              values: CalendarExceptionType.values,
              required: true,
              labelOf: (v) => v.uiLabel,
              onChanged: (v) => setState(() => _exceptionType = v),
            ),
            const SizedBox(height: 12),
            _buildTextField(label: 'Name', controller: _nameController),
            const SizedBox(height: 12),
            _buildDateField(
              label: 'ObservedOf',
              value: _observedOf,
              onPick: (value) => setState(() => _observedOf = value),
              onClear: () => setState(() => _observedOf = null),
            ),
            const SizedBox(height: 12),
            _buildTextField(label: 'Source', controller: _sourceController),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (v) => (v ?? '').trim().isEmpty ? '$label is required.' : null
          : null,
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
