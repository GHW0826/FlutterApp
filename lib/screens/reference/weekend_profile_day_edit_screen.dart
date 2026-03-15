import 'package:flutter/material.dart';

import '../../models/weekend_profile_form_data.dart';
import '../../models/weekend_profile_day_form_data.dart';

class WeekendProfileDayEditScreen extends StatefulWidget {
  const WeekendProfileDayEditScreen({
    super.key,
    this.initialData,
    required this.weekendProfileOptions,
    this.initialWeekendProfileId,
  });

  final WeekendProfileDayFormData? initialData;
  final List<WeekendProfileFormData> weekendProfileOptions;
  final String? initialWeekendProfileId;

  @override
  State<WeekendProfileDayEditScreen> createState() =>
      _WeekendProfileDayEditScreenState();
}

class _WeekendProfileDayEditScreenState
    extends State<WeekendProfileDayEditScreen> {
  final _formKey = GlobalKey<FormState>();

  String _weekendProfileId = '';
  int _isoWeekday = 1;
  bool _weekend = true;

  bool get _isEdit => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _weekendProfileId = _resolveWeekendProfileId(
      data?.weekendProfileId ?? widget.initialWeekendProfileId,
    );
    _isoWeekday = data?.isoWeekday ?? 1;
    _weekend = data?.weekend ?? true;
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      WeekendProfileDayFormData(
        id: widget.initialData?.effectiveId,
        weekendProfileId: _weekendProfileId,
        weekendProfileCode: _selectedWeekendProfile?.weekendProfileCode ?? '',
        isoWeekday: _isoWeekday,
        weekend: _weekend,
      ),
    );
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
        title: Text(
          _isEdit ? 'WeekendProfileDay Edit' : 'WeekendProfileDay New',
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
            DropdownButtonFormField<String>(
              initialValue: _weekendProfileId.isEmpty
                  ? null
                  : _weekendProfileId,
              decoration: const InputDecoration(
                labelText: 'WeekendProfile *',
                border: OutlineInputBorder(),
              ),
              items: widget.weekendProfileOptions
                  .where((item) => (item.id ?? '').isNotEmpty)
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.id!,
                      child: Text('${item.weekendProfileCode} | ${item.name}'),
                    ),
                  )
                  .toList(),
              onChanged: _isEdit
                  ? null
                  : (value) => setState(() => _weekendProfileId = value ?? ''),
              validator: (_) => _weekendProfileId.trim().isEmpty
                  ? 'WeekendProfile is required.'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _isoWeekday,
              decoration: const InputDecoration(
                labelText: 'IsoWeekday *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 - Monday')),
                DropdownMenuItem(value: 2, child: Text('2 - Tuesday')),
                DropdownMenuItem(value: 3, child: Text('3 - Wednesday')),
                DropdownMenuItem(value: 4, child: Text('4 - Thursday')),
                DropdownMenuItem(value: 5, child: Text('5 - Friday')),
                DropdownMenuItem(value: 6, child: Text('6 - Saturday')),
                DropdownMenuItem(value: 7, child: Text('7 - Sunday')),
              ],
              onChanged: _isEdit
                  ? null
                  : (value) => setState(() => _isoWeekday = value ?? 1),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              child: Row(
                children: [
                  const Text('Weekend *'),
                  const Spacer(),
                  Switch(
                    value: _weekend,
                    onChanged: (value) => setState(() => _weekend = value),
                  ),
                ],
              ),
            ),
            if (widget.initialData != null &&
                widget.initialData!.weekendProfileCode.isNotEmpty) ...[
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Resolved WeekendProfileCode',
                  border: OutlineInputBorder(),
                ),
                child: Text(widget.initialData!.weekendProfileCode),
              ),
            ],
          ],
        ),
      ),
    );
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
