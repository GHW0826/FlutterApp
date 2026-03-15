import 'package:flutter/material.dart';

import '../../api/calendar_api_client.dart';
import '../../models/calendar_exception_form_data.dart';
import '../../models/calendar_form_data.dart';
import '../../widgets/list_screen_app_bar.dart';
import 'calendar_exception_edit_screen.dart';

class CalendarExceptionListScreen extends StatefulWidget {
  const CalendarExceptionListScreen({super.key});

  @override
  State<CalendarExceptionListScreen> createState() =>
      _CalendarExceptionListScreenState();
}

class _CalendarExceptionListScreenState
    extends State<CalendarExceptionListScreen> {
  List<CalendarExceptionFormData> _items = [];
  List<CalendarFormData> _calendarOptions = [];
  bool _loading = false;
  String? _errorMessage;
  String? _selectedId;

  final TextEditingController _keywordController = TextEditingController();
  bool _nameChecked = true;
  bool _typeChecked = true;
  String _appliedKeyword = '';
  String _appliedCalendarId = '';
  String _selectedCalendarId = '';

  @override
  void initState() {
    super.initState();
    _loadCalendarOptions();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _loadCalendarOptions() async {
    try {
      final calendars = await calendarApi.getCalendarList();
      if (!mounted) return;
      setState(() {
        _calendarOptions = calendars;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _calendarOptions = [];
      });
    }
  }

  Future<void> _loadItems() async {
    final calendarId = _selectedCalendarId.trim();
    if (calendarId.isEmpty) {
      setState(() {
        _items = [];
        _loading = false;
        _errorMessage = null;
        _appliedCalendarId = '';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _appliedCalendarId = calendarId;
    });
    try {
      final exceptions = await calendarApi.getCalendarExceptionList(
        calendarId: calendarId,
      );
      if (!mounted) return;
      setState(() {
        _items = exceptions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _loading = false;
        _errorMessage = 'Failed to load data: $e';
      });
    }
  }

  CalendarExceptionFormData? get _selectedItem {
    final selectedId = _selectedId;
    if (selectedId == null) return null;
    return _items.where((item) => item.effectiveId == selectedId).firstOrNull;
  }

  void _onSearch() {
    setState(() => _appliedKeyword = _keywordController.text.trim());
  }

  Future<void> _onFilter() async {
    _selectedId = null;
    await _loadItems();
  }

  List<CalendarExceptionFormData> _filteredItems() {
    if (_appliedKeyword.isEmpty) return _items;
    final keyword = _appliedKeyword.toLowerCase();
    return _items.where((item) {
      final name = item.name.toLowerCase();
      final type = item.exceptionType.uiLabel.toLowerCase();
      final date = _formatDate(item.exceptionDate).toLowerCase();
      final source = item.source.toLowerCase();
      final byName = _nameChecked && name.contains(keyword);
      final byType = _typeChecked && type.contains(keyword);
      if (!_nameChecked && !_typeChecked) {
        return name.contains(keyword) ||
            type.contains(keyword) ||
            date.contains(keyword) ||
            source.contains(keyword);
      }
      return byName ||
          byType ||
          date.contains(keyword) ||
          source.contains(keyword);
    }).toList();
  }

  Future<void> _onOpen() async {
    final selected = _selectedItem;
    if (selected == null) return;
    final initial = await calendarApi.getCalendarExceptionById(
      selected.effectiveId,
    );
    if (!mounted || initial == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CalendarExceptionEditScreen(
          initialData: initial,
          calendarOptions: _calendarOptions,
          readOnly: true,
        ),
      ),
    );
  }

  Future<void> _onNew() async {
    if (_appliedCalendarId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter CalendarId first.')));
      return;
    }
    final result = await Navigator.of(context).push<CalendarExceptionFormData?>(
      MaterialPageRoute(
        builder: (_) => CalendarExceptionEditScreen(
          initialCalendarId: _appliedCalendarId,
          calendarOptions: _calendarOptions,
        ),
      ),
    );
    if (result == null || !mounted) return;
    try {
      final created = await calendarApi.createCalendarException(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = created.effectiveId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CalendarException created.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    }
  }

  Future<void> _onEdit() async {
    final selected = _selectedItem;
    if (selected == null) return;
    try {
      final initial = await calendarApi.getCalendarExceptionById(
        selected.effectiveId,
      );
      if (!mounted) return;
      if (initial == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected item not found.')),
        );
        return;
      }
      final result = await Navigator.of(context)
          .push<CalendarExceptionFormData?>(
            MaterialPageRoute(
              builder: (_) => CalendarExceptionEditScreen(
                initialData: initial,
                calendarOptions: _calendarOptions,
              ),
            ),
          );
      if (result == null || !mounted) return;
      final updated = await calendarApi.patchCalendarException(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = updated.effectiveId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CalendarException updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  Future<void> _onDelete() async {
    final selected = _selectedId;
    if (selected == null) return;
    try {
      await calendarApi.deleteCalendarException(selected);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CalendarException deleted.')),
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
    CalendarExceptionFormData item,
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
          value: 'open',
          child: ListTile(
            leading: Icon(Icons.open_in_new),
            title: Text('Open'),
          ),
        ),
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
      case 'open':
        setState(() => _selectedId = item.effectiveId);
        _onOpen();
        break;
      case 'new':
        _onNew();
        break;
      case 'edit':
        setState(() => _selectedId = item.effectiveId);
        _onEdit();
        break;
      case 'delete':
        setState(() => _selectedId = item.effectiveId);
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
                    onPressed: _onFilter,
                    icon: const Icon(Icons.filter_alt_outlined),
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
                    value: _nameChecked,
                    onChanged: (value) =>
                        setState(() => _nameChecked = value ?? true),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _nameChecked = !_nameChecked),
                    child: const Text('name'),
                  ),
                  const SizedBox(width: 24),
                  Checkbox(
                    value: _typeChecked,
                    onChanged: (value) =>
                        setState(() => _typeChecked = value ?? true),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _typeChecked = !_typeChecked),
                    child: const Text('type'),
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
        title: 'CalendarException',
        onBack: () => Navigator.of(context).pop(),
        onOpen: _onOpen,
        onNew: _onNew,
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
                : _appliedCalendarId.isEmpty
                ? const Center(
                    child: Text('Enter CalendarId and load exceptions.'),
                  )
                : Builder(
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
                              selected: _selectedId == item.effectiveId,
                              selectedTileColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.5),
                              title: Text(
                                item.name.isEmpty
                                    ? item.exceptionType.uiLabel
                                    : item.name,
                              ),
                              subtitle: Text(
                                '${item.calendarId} | ${_formatDate(item.exceptionDate)} | ${item.exceptionType.uiLabel}'
                                '${item.source.trim().isEmpty ? '' : ' | ${item.source.trim()}'}',
                              ),
                              trailing: Text(
                                item.businessDay ? 'BusinessDay' : 'Holiday',
                              ),
                              onTap: () => setState(
                                () => _selectedId = item.effectiveId,
                              ),
                              onLongPress: _onOpen,
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
