import 'package:flutter/material.dart';

import '../../api/calendar_api_client.dart';
import '../../models/calendar_form_data.dart';
import '../../models/calendar_weekend_form_data.dart';
import '../../models/weekend_profile_form_data.dart';
import '../../widgets/list_screen_app_bar.dart';
import 'calendar_weekend_edit_screen.dart';

class CalendarWeekendListScreen extends StatefulWidget {
  const CalendarWeekendListScreen({super.key});

  @override
  State<CalendarWeekendListScreen> createState() =>
      _CalendarWeekendListScreenState();
}

class _CalendarWeekendListScreenState extends State<CalendarWeekendListScreen> {
  List<CalendarWeekendFormData> _items = [];
  List<CalendarFormData> _calendarOptions = [];
  List<WeekendProfileFormData> _weekendProfileOptions = [];
  bool _loading = false;
  String? _errorMessage;
  String? _selectedId;
  String _appliedCalendarId = '';

  final TextEditingController _keywordController = TextEditingController();
  bool _calendarChecked = true;
  bool _profileChecked = true;
  String _appliedKeyword = '';
  String _selectedCalendarId = '';

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([
        calendarApi.getCalendarList(),
        calendarApi.getWeekendProfileList(),
      ]);
      if (!mounted) return;
      setState(() {
        _calendarOptions = results[0] as List<CalendarFormData>;
        _weekendProfileOptions = results[1] as List<WeekendProfileFormData>;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _calendarOptions = [];
        _weekendProfileOptions = [];
      });
    }
  }

  Future<void> _loadItems() async {
    final calendarId = _selectedCalendarId.trim();
    if (calendarId.isEmpty) {
      setState(() {
        _items = [];
        _selectedId = null;
        _appliedCalendarId = '';
        _errorMessage = 'CalendarId is required.';
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
      _appliedCalendarId = calendarId;
    });
    try {
      final weekends = await calendarApi.getCalendarWeekendList(
        calendarId: calendarId,
      );
      if (!mounted) return;
      setState(() {
        _items = weekends;
        _selectedId = null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _selectedId = null;
        _loading = false;
        _errorMessage = 'Failed to load data.';
      });
    }
  }

  void _onSearch() {
    setState(() => _appliedKeyword = _keywordController.text.trim());
  }

  List<CalendarWeekendFormData> _filteredItems() {
    if (_appliedKeyword.isEmpty) return _items;
    final keyword = _appliedKeyword.toLowerCase();
    return _items.where((item) {
      final calendarText =
          '${item.calendarId} ${item.calendarCode} ${item.calendarName}'
              .toLowerCase();
      final profileText =
          '${item.weekendProfileId} ${item.weekendProfileCode} ${item.weekendProfileName}'
              .toLowerCase();
      final byCalendar = _calendarChecked && calendarText.contains(keyword);
      final byProfile = _profileChecked && profileText.contains(keyword);
      if (!_calendarChecked && !_profileChecked) {
        return calendarText.contains(keyword) ||
            profileText.contains(keyword) ||
            _formatDate(item.validFrom).contains(keyword) ||
            _formatDate(item.validTo).contains(keyword);
      }
      return byCalendar || byProfile;
    }).toList();
  }

  Future<void> _onNew() async {
    final result = await Navigator.of(context).push<CalendarWeekendFormData?>(
      MaterialPageRoute(
        builder: (_) => CalendarWeekendEditScreen(
          initialCalendarId: _appliedCalendarId,
          calendarOptions: _calendarOptions,
          weekendProfileOptions: _weekendProfileOptions,
        ),
      ),
    );
    if (result == null || !mounted) return;
    try {
      final created = await calendarApi.createCalendarWeekend(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = created.effectiveId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CalendarWeekend created.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    }
  }

  Future<void> _onEdit() async {
    if (_selectedId == null) return;
    try {
      final initial = await calendarApi.getCalendarWeekendById(_selectedId!);
      if (!mounted) return;
      if (initial == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected item not found.')),
        );
        return;
      }
      final result = await Navigator.of(context).push<CalendarWeekendFormData?>(
        MaterialPageRoute(
          builder: (_) => CalendarWeekendEditScreen(
            initialData: initial,
            calendarOptions: _calendarOptions,
            weekendProfileOptions: _weekendProfileOptions,
          ),
        ),
      );
      if (result == null || !mounted) return;
      final updated = await calendarApi.updateCalendarWeekend(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = updated.effectiveId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CalendarWeekend updated.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  Future<void> _onDelete() async {
    if (_selectedId == null) return;
    try {
      await calendarApi.deleteCalendarWeekend(_selectedId!);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CalendarWeekend deleted.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void _showMissingParentMessage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Load CalendarId first.')));
  }

  Widget _buildSearchArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 90,
                    child: Text(
                      'Calendar',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCalendarId.isEmpty
                          ? null
                          : _selectedCalendarId,
                      decoration: const InputDecoration(
                        hintText: 'Select calendar',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _calendarOptions
                          .where((item) => (item.id ?? '').isNotEmpty)
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id!,
                              child: Text(
                                '${item.calendarCode} | ${item.name}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCalendarId = value ?? ''),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _loadItems,
                    icon: const Icon(Icons.download),
                    tooltip: 'Load',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(
                    width: 90,
                    child: Text(
                      'Keyword',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _keywordController,
                      decoration: const InputDecoration(
                        hintText: 'Type keyword',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _onSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _onSearch,
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _calendarChecked,
                    onChanged: (v) =>
                        setState(() => _calendarChecked = v ?? true),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _calendarChecked = !_calendarChecked),
                    child: const Text('calendar'),
                  ),
                  const SizedBox(width: 24),
                  Checkbox(
                    value: _profileChecked,
                    onChanged: (v) =>
                        setState(() => _profileChecked = v ?? true),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _profileChecked = !_profileChecked),
                    child: const Text('profile'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ListScreenAppBar(
        title: 'CalendarWeekend',
        onBack: () => Navigator.of(context).pop(),
        onNew: _appliedCalendarId.isEmpty ? _showMissingParentMessage : _onNew,
        onEdit: _onEdit,
        onDelete: _onDelete,
        hasSelection: _selectedId != null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchArea(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Builder(
                    builder: (context) {
                      final filtered = _filteredItems();
                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            _appliedCalendarId.isEmpty
                                ? 'Enter CalendarId and load weekends.'
                                : _appliedKeyword.isEmpty
                                ? 'No items.'
                                : 'No search results.',
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final itemId = item.effectiveId;
                          return ListTile(
                            selected: _selectedId == itemId,
                            selectedTileColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.5),
                            title: Text(
                              item.calendarCode.isEmpty
                                  ? item.calendarId
                                  : item.calendarCode,
                            ),
                            subtitle: Text(
                              '${_formatDate(item.validFrom)} ~ ${_formatDate(item.validTo)} | ${item.weekendProfileCode.isEmpty ? item.weekendProfileId : item.weekendProfileCode}',
                            ),
                            trailing: Text(
                              item.weekendProfileName.isEmpty
                                  ? '-'
                                  : item.weekendProfileName,
                            ),
                            onTap: () => setState(() => _selectedId = itemId),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
