import 'package:flutter/material.dart';

import '../../api/calendar_api_client.dart';
import '../../models/calendar_form_data.dart';
import '../../models/calendar_weekend_form_data.dart';
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
  List<CalendarFormData> _calendars = [];
  bool _loading = true;
  String? _errorMessage;
  String? _selectedId;

  final TextEditingController _keywordController = TextEditingController();
  bool _calendarChecked = true;
  bool _profileChecked = true;
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
      final weekends = await calendarApi.getCalendarWeekendList();
      final calendars = await calendarApi.getCalendarList();
      if (!mounted) return;
      setState(() {
        _items = weekends;
        _calendars = calendars;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _calendars = [];
        _loading = false;
        _errorMessage = 'Failed to load data.';
      });
    }
  }

  List<String> get _calendarOptions =>
      _calendars.map((e) => e.calendarCode).toSet().toList()..sort();

  void _onSearch() {
    setState(() => _appliedKeyword = _keywordController.text.trim());
  }

  List<CalendarWeekendFormData> _filteredItems() {
    if (_appliedKeyword.isEmpty) return _items;
    final keyword = _appliedKeyword.toLowerCase();
    return _items.where((item) {
      final calendarCode = item.calendarCode.toLowerCase();
      final profileCode = item.weekendProfileCode.toLowerCase();
      final byCalendar = _calendarChecked && calendarCode.contains(keyword);
      final byProfile = _profileChecked && profileCode.contains(keyword);
      if (!_calendarChecked && !_profileChecked) {
        return calendarCode.contains(keyword) ||
            profileCode.contains(keyword) ||
            _formatDate(item.validFrom).toLowerCase().contains(keyword) ||
            _formatDate(item.validTo).toLowerCase().contains(keyword);
      }
      return byCalendar || byProfile;
    }).toList();
  }

  Future<void> _onNew() async {
    final result = await Navigator.of(context).push<CalendarWeekendFormData?>(
      MaterialPageRoute(
        builder: (_) =>
            CalendarWeekendEditScreen(calendarOptions: _calendarOptions),
      ),
    );
    if (result == null || !mounted) return;
    try {
      final created = await calendarApi.createCalendarWeekend(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = created.id);
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
          ),
        ),
      );
      if (result == null || !mounted) return;
      final updated = await calendarApi.updateCalendarWeekend(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = updated.id);
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

  Future<void> _showContextMenu(
    BuildContext context,
    TapDownDetails details,
    CalendarWeekendFormData item,
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
                              title: Text(item.calendarCode),
                              subtitle: Text(
                                '${_formatDate(item.validFrom)} ~ ${_formatDate(item.validTo)} | ${item.weekendProfileCode}',
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

  static String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
