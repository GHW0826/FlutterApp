import 'package:flutter/material.dart';

import '../../models/calendar_enums.dart';
import '../../models/calendar_exception_form_data.dart';
import '../../models/calendar_form_data.dart';

class CalendarExceptionEditScreen extends StatefulWidget {
  const CalendarExceptionEditScreen({
    super.key,
    this.initialData,
    required this.calendarOptions,
    this.readOnly = false,
    this.initialCalendarId,
  });

  final CalendarExceptionFormData? initialData;
  final List<CalendarFormData> calendarOptions;
  final bool readOnly;
  final String? initialCalendarId;

  @override
  State<CalendarExceptionEditScreen> createState() =>
      _CalendarExceptionEditScreenState();
}

class _CalendarExceptionEditScreenState
    extends State<CalendarExceptionEditScreen> {
  final _formKey = GlobalKey<FormState>();

  String _calendarId = '';
  DateTime? _exceptionDate;
  bool _businessDay = false;
  CalendarExceptionType? _exceptionType;
  late TextEditingController _nameController;
  DateTime? _observedOf;
  late TextEditingController _sourceController;

  bool get _isCreate => widget.initialData == null;
  bool get _keysReadOnly => !_isCreate;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _calendarId = _resolveCalendarId(
      data?.calendarId ?? widget.initialCalendarId,
    );
    _exceptionDate = data?.exceptionDate;
    _businessDay = data?.businessDay ?? false;
    _exceptionType = data?.exceptionType ?? CalendarExceptionType.holiday;
    _nameController = TextEditingController(text: data?.name ?? '');
    _observedOf = data?.observedOf;
    _sourceController = TextEditingController(text: data?.source ?? '');
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
      id: widget.initialData?.effectiveId,
      calendarId: _calendarId,
      calendarCode: _selectedCalendar?.calendarCode ?? '',
      calendarName: _selectedCalendar?.name ?? '',
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

  CalendarFormData? get _selectedCalendar {
    final normalizedId = _calendarId.trim();
    if (normalizedId.isEmpty) return null;
    for (final item in widget.calendarOptions) {
      if ((item.id ?? '') == normalizedId) {
        return item;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.readOnly
              ? 'CalendarException View'
              : _isCreate
              ? 'CalendarException New'
              : 'CalendarException Edit',
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: widget.readOnly
            ? null
            : [
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
            _buildCalendarField(
              label: 'Calendar',
              required: true,
              enabled: !(widget.readOnly || _keysReadOnly),
            ),
            const SizedBox(height: 12),
            _buildDateField(
              label: 'ExceptionDate',
              value: _exceptionDate,
              required: true,
              readOnly: widget.readOnly || _keysReadOnly,
              onPick: (value) => setState(() => _exceptionDate = value),
            ),
            const SizedBox(height: 12),
            _buildSwitchField(
              label: 'BusinessDay',
              value: _businessDay,
              enabled: !widget.readOnly,
              onChanged: (value) => setState(() => _businessDay = value),
            ),
            const SizedBox(height: 12),
            _buildEnumDropdown<CalendarExceptionType>(
              label: 'ExceptionType',
              value: _exceptionType,
              values: CalendarExceptionType.values,
              required: true,
              enabled: !widget.readOnly,
              labelOf: (value) => value.uiLabel,
              onChanged: (value) => setState(() => _exceptionType = value),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'ExceptionName',
              controller: _nameController,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 12),
            _buildDateField(
              label: 'ObservedOf',
              value: _observedOf,
              readOnly: widget.readOnly,
              onPick: (value) => setState(() => _observedOf = value),
              onClear: widget.readOnly
                  ? null
                  : () => setState(() => _observedOf = null),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Source',
              controller: _sourceController,
              readOnly: widget.readOnly,
            ),
            if (widget.initialData?.createdAt != null) ...[
              const SizedBox(height: 12),
              _buildReadOnlyInfo(
                label: 'CreatedAt',
                value: _formatDateTime(widget.initialData!.createdAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarField({
    required String label,
    required bool required,
    required bool enabled,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: _calendarId.isEmpty ? null : _calendarId,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      items: widget.calendarOptions
          .where((item) => (item.id ?? '').isNotEmpty)
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.id!,
              child: Text('${item.calendarCode} | ${item.name}'),
            ),
          )
          .toList(),
      onChanged: enabled
          ? (value) => setState(() => _calendarId = value ?? '')
          : null,
      validator: required
          ? (_) => _calendarId.trim().isEmpty ? '$label is required.' : null
          : null,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (value) =>
                (value ?? '').trim().isEmpty ? '$label is required.' : null
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
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      items: values
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(labelOf(item))),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: required
          ? (value) => value == null ? '$label is required.' : null
          : null,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPick,
    VoidCallback? onClear,
    bool required = false,
    bool readOnly = false,
  }) {
    return InkWell(
      onTap: readOnly
          ? null
          : () async {
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
            if (!readOnly && onClear != null && value != null)
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
    required bool enabled,
  }) {
    return InputDecorator(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      child: Row(
        children: [
          Text('$label *'),
          const Spacer(),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }

  Widget _buildReadOnlyInfo({required String label, required String value}) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Text(value),
    );
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _formatDateTime(DateTime dateTime) {
    final date = _formatDate(dateTime);
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    final ss = dateTime.second.toString().padLeft(2, '0');
    return '$date $hh:$mm:$ss';
  }

  String _resolveCalendarId(String? rawId) {
    final normalizedId = (rawId ?? '').trim();
    if (normalizedId.isEmpty) return '';
    for (final item in widget.calendarOptions) {
      if ((item.id ?? '') == normalizedId) {
        return normalizedId;
      }
    }
    return '';
  }
}
