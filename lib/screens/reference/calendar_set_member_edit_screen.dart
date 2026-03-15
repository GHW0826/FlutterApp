import 'package:flutter/material.dart';

import '../../models/calendar_form_data.dart';
import '../../models/calendar_set_form_data.dart';
import '../../models/calendar_set_member_form_data.dart';

class CalendarSetMemberEditScreen extends StatefulWidget {
  const CalendarSetMemberEditScreen({
    super.key,
    this.initialData,
    required this.calendarSetOptions,
    required this.calendarOptions,
    this.initialCalendarSetId,
  });

  final CalendarSetMemberFormData? initialData;
  final List<CalendarSetFormData> calendarSetOptions;
  final List<CalendarFormData> calendarOptions;
  final String? initialCalendarSetId;

  @override
  State<CalendarSetMemberEditScreen> createState() =>
      _CalendarSetMemberEditScreenState();
}

class _CalendarSetMemberEditScreenState
    extends State<CalendarSetMemberEditScreen> {
  final _formKey = GlobalKey<FormState>();

  String _calendarSetId = '';
  String _calendarId = '';
  late TextEditingController _seqNoController;

  bool get _isEdit => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _calendarSetId = _resolveCalendarSetId(
      data?.calendarSetId ?? widget.initialCalendarSetId,
    );
    _calendarId = _resolveCalendarId(data?.calendarId);
    _seqNoController = TextEditingController(text: '${data?.seqNo ?? 1}');
  }

  @override
  void dispose() {
    _seqNoController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final data = CalendarSetMemberFormData(
      id: widget.initialData?.effectiveId,
      calendarSetId: _calendarSetId,
      calendarSetCode: _selectedCalendarSet?.setCode ?? '',
      calendarId: _calendarId,
      calendarCode: _selectedCalendar?.calendarCode ?? '',
      calendarName: _selectedCalendar?.name ?? '',
      seqNo: int.parse(_seqNoController.text.trim()),
    );
    Navigator.of(context).pop(data);
  }

  CalendarSetFormData? get _selectedCalendarSet {
    final normalizedId = _calendarSetId.trim();
    if (normalizedId.isEmpty) return null;
    for (final item in widget.calendarSetOptions) {
      if ((item.id ?? '') == normalizedId) {
        return item;
      }
    }
    return null;
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
          _isEdit ? 'CalendarSetMember Edit' : 'CalendarSetMember New',
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
            _buildDropdownField(
              label: 'CalendarSet',
              value: _calendarSetId,
              required: true,
              enabled: !_isEdit,
              items: widget.calendarSetOptions
                  .where((item) => (item.id ?? '').isNotEmpty)
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.id!,
                      child: Text(item.setCode),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _calendarSetId = value ?? ''),
            ),
            const SizedBox(height: 12),
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
            if (widget.initialData != null) ...[
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Resolved Values',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  [
                    if (widget.initialData!.calendarSetCode.isNotEmpty)
                      widget.initialData!.calendarSetCode,
                    if (widget.initialData!.calendarCode.isNotEmpty)
                      widget.initialData!.calendarCode,
                    if (widget.initialData!.calendarName.isNotEmpty)
                      widget.initialData!.calendarName,
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

  String _resolveCalendarSetId(String? rawId) {
    final normalizedId = (rawId ?? '').trim();
    if (normalizedId.isEmpty) return '';
    for (final item in widget.calendarSetOptions) {
      if ((item.id ?? '') == normalizedId) {
        return normalizedId;
      }
    }
    return '';
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
