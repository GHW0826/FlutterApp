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
  List<CalendarSetFormData> _sets = [];
  List<CalendarFormData> _calendars = [];
  bool _loading = true;
  String? _errorMessage;
  String? _selectedId;

  final TextEditingController _keywordController = TextEditingController();
  bool _setChecked = true;
  bool _calendarChecked = true;
  String _appliedKeyword = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final members = await calendarApi.getCalendarSetMemberList();
      final sets = await calendarApi.getCalendarSetList();
      final calendars = await calendarApi.getCalendarList();
      if (!mounted) return;
      setState(() {
        _items = members;
        _sets = sets;
        _calendars = calendars;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _sets = [];
        _calendars = [];
        _loading = false;
        _errorMessage = 'Failed to load data.';
      });
    }
  }

  List<String> get _setOptions =>
      _sets.map((e) => e.setCode).toSet().toList()..sort();
  List<String> get _calendarOptions =>
      _calendars.map((e) => e.calendarCode).toSet().toList()..sort();

  void _onSearch() {
    setState(() => _appliedKeyword = _keywordController.text.trim());
  }

  List<CalendarSetMemberFormData> _filteredItems() {
    if (_appliedKeyword.isEmpty) return _items;
    final keyword = _appliedKeyword.toLowerCase();
    return _items.where((item) {
      final setCode = item.calendarSetCode.toLowerCase();
      final calendarCode = item.calendarCode.toLowerCase();
      final bySet = _setChecked && setCode.contains(keyword);
      final byCalendar = _calendarChecked && calendarCode.contains(keyword);
      if (!_setChecked && !_calendarChecked) {
        return setCode.contains(keyword) ||
            calendarCode.contains(keyword) ||
            item.seqNo.toString().contains(keyword);
      }
      return bySet || byCalendar;
    }).toList();
  }

  Future<void> _onNew() async {
    final result = await Navigator.of(context).push<CalendarSetMemberFormData?>(
      MaterialPageRoute(
        builder: (_) => CalendarSetMemberEditScreen(
          calendarSetOptions: _setOptions,
          calendarOptions: _calendarOptions,
        ),
      ),
    );
    if (result == null || !mounted) return;
    try {
      final created = await calendarApi.createCalendarSetMember(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = created.id);
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
                calendarSetOptions: _setOptions,
                calendarOptions: _calendarOptions,
              ),
            ),
          );
      if (result == null || !mounted) return;
      final updated = await calendarApi.updateCalendarSetMember(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = updated.id);
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

  Future<void> _showContextMenu(
    BuildContext context,
    TapDownDetails details,
    CalendarSetMemberFormData item,
  ) async {
    final overlay = Navigator.of(context).overlay!;
    final relRect = RelativeRect.fromSize(
      Rect.fromLTWH(details.globalPosition.dx, details.globalPosition.dy, 1, 1),
      (overlay.context.findRenderObject() as RenderBox).size,
    );
    final value = await showMenu<String>(
      context: context,
      position: relRect,
      items: const [
        PopupMenuItem(
          value: 'new',
          child: ListTile(leading: Icon(Icons.add), title: Text('New')),
        ),
        PopupMenuItem(
          value: 'edit',
          child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Delete'),
          ),
        ),
      ],
    );
    if (!mounted) return;
    switch (value) {
      case 'new':
        _onNew();
        break;
      case 'edit':
        setState(() => _selectedId = item.id);
        _onEdit();
        break;
      case 'delete':
        setState(() => _selectedId = item.id);
        _onDelete();
        break;
    }
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
        onNew: _onNew,
        onEdit: _onEdit,
        onDelete: _onDelete,
        hasSelection: _selectedId != null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchArea(),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final filtered = _filteredItems();
                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            _appliedKeyword.isEmpty
                                ? 'No items.'
                                : 'No search results.',
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return GestureDetector(
                            onSecondaryTapDown: (details) =>
                                _showContextMenu(context, details, item),
                            child: ListTile(
                              selected: _selectedId == item.id,
                              selectedTileColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.5),
                              title: Text(item.calendarSetCode),
                              subtitle: Text(
                                '${item.calendarCode} | SeqNo: ${item.seqNo}',
                              ),
                              onTap: () =>
                                  setState(() => _selectedId = item.id),
                            ),
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
