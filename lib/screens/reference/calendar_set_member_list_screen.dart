import 'package:flutter/material.dart';

import '../../api/calendar_api_client.dart';
import '../../models/calendar_form_data.dart';
import '../../models/calendar_set_form_data.dart';
import '../../models/calendar_set_member_form_data.dart';
import '../../widgets/list_screen_app_bar.dart';
import 'calendar_set_member_edit_screen.dart';

class CalendarSetMemberListScreen extends StatefulWidget {
  const CalendarSetMemberListScreen({super.key});

  @override
  State<CalendarSetMemberListScreen> createState() =>
      _CalendarSetMemberListScreenState();
}

class _CalendarSetMemberListScreenState
    extends State<CalendarSetMemberListScreen> {
  List<CalendarSetMemberFormData> _items = [];
  List<CalendarSetFormData> _calendarSetOptions = [];
  List<CalendarFormData> _calendarOptions = [];
  bool _loading = false;
  String? _errorMessage;
  String? _selectedId;
  String _appliedCalendarSetId = '';

  final TextEditingController _keywordController = TextEditingController();
  bool _setChecked = true;
  bool _calendarChecked = true;
  String _appliedKeyword = '';
  String _selectedCalendarSetId = '';

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
        calendarApi.getCalendarSetList(),
        calendarApi.getCalendarList(),
      ]);
      if (!mounted) return;
      setState(() {
        _calendarSetOptions = results[0] as List<CalendarSetFormData>;
        _calendarOptions = results[1] as List<CalendarFormData>;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _calendarSetOptions = [];
        _calendarOptions = [];
      });
    }
  }

  Future<void> _loadItems() async {
    final calendarSetId = _selectedCalendarSetId.trim();
    if (calendarSetId.isEmpty) {
      setState(() {
        _items = [];
        _selectedId = null;
        _appliedCalendarSetId = '';
        _errorMessage = 'CalendarSetId is required.';
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
      _appliedCalendarSetId = calendarSetId;
    });
    try {
      final members = await calendarApi.getCalendarSetMemberList(
        calendarSetId: calendarSetId,
      );
      if (!mounted) return;
      setState(() {
        _items = members;
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

  List<CalendarSetMemberFormData> _filteredItems() {
    if (_appliedKeyword.isEmpty) return _items;
    final keyword = _appliedKeyword.toLowerCase();
    return _items.where((item) {
      final setText = '${item.calendarSetId} ${item.calendarSetCode}'
          .toLowerCase();
      final calendarText =
          '${item.calendarId} ${item.calendarCode} ${item.calendarName}'
              .toLowerCase();
      final bySet = _setChecked && setText.contains(keyword);
      final byCalendar = _calendarChecked && calendarText.contains(keyword);
      if (!_setChecked && !_calendarChecked) {
        return setText.contains(keyword) ||
            calendarText.contains(keyword) ||
            item.seqNo.toString().contains(keyword);
      }
      return bySet || byCalendar;
    }).toList();
  }

  Future<void> _onNew() async {
    final result = await Navigator.of(context).push<CalendarSetMemberFormData?>(
      MaterialPageRoute(
        builder: (_) => CalendarSetMemberEditScreen(
          initialCalendarSetId: _appliedCalendarSetId,
          calendarSetOptions: _calendarSetOptions,
          calendarOptions: _calendarOptions,
        ),
      ),
    );
    if (result == null || !mounted) return;
    try {
      final created = await calendarApi.createCalendarSetMember(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = created.effectiveId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CalendarSetMember created.')),
      );
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
      final initial = await calendarApi.getCalendarSetMemberById(_selectedId!);
      if (!mounted) return;
      if (initial == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected item not found.')),
        );
        return;
      }
      final result = await Navigator.of(context)
          .push<CalendarSetMemberFormData?>(
            MaterialPageRoute(
              builder: (_) => CalendarSetMemberEditScreen(
                initialData: initial,
                calendarSetOptions: _calendarSetOptions,
                calendarOptions: _calendarOptions,
              ),
            ),
          );
      if (result == null || !mounted) return;
      final updated = await calendarApi.updateCalendarSetMember(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = updated.effectiveId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CalendarSetMember updated.')),
      );
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
      await calendarApi.deleteCalendarSetMember(_selectedId!);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CalendarSetMember deleted.')),
      );
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
    ).showSnackBar(const SnackBar(content: Text('Load CalendarSetId first.')));
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
                    width: 110,
                    child: Text(
                      'CalendarSet',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCalendarSetId.isEmpty
                          ? null
                          : _selectedCalendarSetId,
                      decoration: const InputDecoration(
                        hintText: 'Select set',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _calendarSetOptions
                          .where((item) => (item.id ?? '').isNotEmpty)
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id!,
                              child: Text(item.setCode),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCalendarSetId = value ?? ''),
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
                    width: 110,
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
                    value: _setChecked,
                    onChanged: (v) => setState(() => _setChecked = v ?? true),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _setChecked = !_setChecked),
                    child: const Text('set'),
                  ),
                  const SizedBox(width: 24),
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
        title: 'CalendarSetMember',
        onBack: () => Navigator.of(context).pop(),
        onNew: _appliedCalendarSetId.isEmpty
            ? _showMissingParentMessage
            : _onNew,
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
                            _appliedCalendarSetId.isEmpty
                                ? 'Enter CalendarSetId and load members.'
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
                              '${item.calendarId} | ${item.calendarName.isEmpty ? '-' : item.calendarName} | SeqNo: ${item.seqNo}',
                            ),
                            trailing: Text(
                              item.calendarSetCode.isEmpty
                                  ? item.calendarSetId
                                  : item.calendarSetCode,
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
}
