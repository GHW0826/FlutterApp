import 'package:flutter/material.dart';

import '../../models/calendar_form_data.dart';
import '../../models/calendar_weekend_form_data.dart';
import '../../models/weekend_profile_form_data.dart';

class CalendarWeekendEditScreen extends StatefulWidget {
  const CalendarWeekendEditScreen({
    super.key,
    this.initialData,
    required this.calendarOptions,
    required this.weekendProfileOptions,
    this.initialCalendarId,
  });

  final CalendarWeekendFormData? initialData;
  final List<CalendarFormData> calendarOptions;
  final List<WeekendProfileFormData> weekendProfileOptions;
  final String? initialCalendarId;

  @override
  State<CalendarWeekendEditScreen> createState() =>
      _CalendarWeekendEditScreenState();
}

class _CalendarWeekendEditScreenState extends State<CalendarWeekendEditScreen> {
  final _formKey = GlobalKey<FormState>();

  String _calendarId = '';
  String _weekendProfileId = '';
  DateTime? _validFrom;
  DateTime? _validTo;

  bool get _isEdit => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _calendarId = _resolveCalendarId(
      data?.calendarId ?? widget.initialCalendarId,
    );
    _weekendProfileId = _resolveWeekendProfileId(data?.weekendProfileId);
    _validFrom = data?.validFrom;
    _validTo = data?.validTo;
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
      id: widget.initialData?.effectiveId,
      calendarId: _calendarId,
      calendarCode: _selectedCalendar?.calendarCode ?? '',
      calendarName: _selectedCalendar?.name ?? '',
      validFrom: _validFrom,
      validTo: _validTo,
      weekendProfileId: _weekendProfileId,
      weekendProfileCode: _selectedWeekendProfile?.weekendProfileCode ?? '',
      weekendProfileName: _selectedWeekendProfile?.name ?? '',
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

  WeekendProfileFormData? get _selectedWeekendProfile {
    final normalizedId = _weekendProfileId.trim();
    if (normalizedId.isEmpty) return null;
    for (final item in widget.weekendProfileOptions) {
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
        title: Text(_isEdit ? 'CalendarWeekend Edit' : 'CalendarWeekend New'),
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
            _buildDropdownField(
              label: 'Calendar',
              value: _calendarId,
              required: true,
              enabled: !_isEdit,
              items: widget.calendarOptions
                  .where((item) => (item.id ?? '').isNotEmpty)
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.id!,
                      child: Text('${item.calendarCode} | ${item.name}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _calendarId = value ?? ''),
            ),
            const SizedBox(height: 12),
            _buildDateField(
              label: 'ValidFrom',
              value: _validFrom,
              required: true,
              readOnly: _isEdit,
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
            _buildDropdownField(
              label: 'WeekendProfile',
              value: _weekendProfileId,
              required: true,
              items: widget.weekendProfileOptions
                  .where((item) => (item.id ?? '').isNotEmpty)
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.id!,
                      child: Text('${item.weekendProfileCode} | ${item.name}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _weekendProfileId = value ?? ''),
            ),
            if (widget.initialData != null) ...[
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Resolved Values',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  [
                    if (widget.initialData!.calendarCode.isNotEmpty)
                      widget.initialData!.calendarCode,
                    if (widget.initialData!.calendarName.isNotEmpty)
                      widget.initialData!.calendarName,
                    if (widget.initialData!.weekendProfileCode.isNotEmpty)
                      widget.initialData!.weekendProfileCode,
                    if (widget.initialData!.weekendProfileName.isNotEmpty)
                      widget.initialData!.weekendProfileName,
                  ].join(' | '),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    bool required = false,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: required
          ? (_) => value.trim().isEmpty ? '$label is required.' : null
          : null,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPick,
    bool required = false,
    bool readOnly = false,
    VoidCallback? onClear,
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
              child: Text(value == null ? 'Select date' : _formatDate(value)),
            ),
            if (!readOnly && onClear != null && value != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 16),
                tooltip: 'Clear',
              ),
            Icon(
              readOnly ? Icons.lock_outline : Icons.calendar_today,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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

  String _resolveWeekendProfileId(String? rawId) {
    final normalizedId = (rawId ?? '').trim();
    if (normalizedId.isEmpty) return '';
    for (final item in widget.weekendProfileOptions) {
      if ((item.id ?? '') == normalizedId) {
        return normalizedId;
      }
    }
    return '';
  }
}
