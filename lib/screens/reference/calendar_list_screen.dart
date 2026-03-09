import 'package:flutter/material.dart';

import '../../api/calendar_api_client.dart';
import '../../api/country_api_client.dart';
import '../../models/calendar_form_data.dart';
import '../../models/country_form_data.dart';
import '../../widgets/list_screen_app_bar.dart';
import 'calendar_edit_screen.dart';

class CalendarListScreen extends StatefulWidget {
  const CalendarListScreen({super.key});

  @override
  State<CalendarListScreen> createState() => _CalendarListScreenState();
}

class _CalendarListScreenState extends State<CalendarListScreen> {
  List<CalendarFormData> _items = [];
  List<CountryFormData> _countries = [];
  bool _loading = true;
  String? _errorMessage;
  String? _selectedId;

  final TextEditingController _keywordController = TextEditingController();
  bool _nameChecked = true;
  bool _codeChecked = true;
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
      final results = await Future.wait([
        calendarApi.getCalendarList(),
        countryApi.getList(),
      ]);
      final list = results[0] as List<CalendarFormData>;
      final countries = results[1] as List<CountryFormData>;
      countries.sort((a, b) => a.displayCode.compareTo(b.displayCode));
      if (!mounted) return;
      setState(() {
        _items = list;
        _countries = countries;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _countries = [];
        _loading = false;
        _errorMessage = 'Failed to load data.';
      });
    }
  }

  void _onSearch() {
    setState(() => _appliedKeyword = _keywordController.text.trim());
  }

  List<CalendarFormData> _filteredItems() {
    if (_appliedKeyword.isEmpty) return _items;
    final keyword = _appliedKeyword.toLowerCase();
    return _items.where((item) {
      final byName = _nameChecked && item.name.toLowerCase().contains(keyword);
      final byCode =
          _codeChecked && item.calendarCode.toLowerCase().contains(keyword);
      if (!_nameChecked && !_codeChecked) {
        return item.name.toLowerCase().contains(keyword) ||
            item.calendarCode.toLowerCase().contains(keyword) ||
            item.type.uiLabel.toLowerCase().contains(keyword) ||
            item.countryIso2.toLowerCase().contains(keyword) ||
            item.countryIso3.toLowerCase().contains(keyword) ||
            item.countryName.toLowerCase().contains(keyword) ||
            item.timezone.toLowerCase().contains(keyword);
      }
      return byName || byCode;
    }).toList();
  }

  CalendarFormData? get _selectedItem {
    final selectedId = _selectedId;
    if (selectedId == null) return null;
    for (final item in _items) {
      if (item.id == selectedId) return item;
    }
    return null;
  }

  Future<void> _onNew() async {
    final result = await Navigator.of(context).push<CalendarFormData?>(
      MaterialPageRoute(
        builder: (_) => CalendarEditScreen(countryOptions: _countries),
      ),
    );
    if (result == null || !mounted) return;
    try {
      final created = await calendarApi.createCalendar(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = created.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Calendar created.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    }
  }

  Future<void> _onEdit() async {
    final initial = _selectedItem;
    if (initial == null) return;
    try {
      final result = await Navigator.of(context).push<CalendarFormData?>(
        MaterialPageRoute(
          builder: (_) => CalendarEditScreen(
            initialData: initial,
            countryOptions: _countries,
          ),
        ),
      );
      if (result == null || !mounted) return;
      final updated = await calendarApi.updateCalendar(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = updated.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Calendar updated.')));
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
      await calendarApi.deleteCalendar(_selectedId!);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Calendar deleted.')));
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
    CalendarFormData item,
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
                    value: _nameChecked,
                    onChanged: (v) => setState(() => _nameChecked = v ?? true),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _nameChecked = !_nameChecked),
                    child: const Text('name'),
                  ),
                  const SizedBox(width: 24),
                  Checkbox(
                    value: _codeChecked,
                    onChanged: (v) => setState(() => _codeChecked = v ?? true),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _codeChecked = !_codeChecked),
                    child: const Text('code'),
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
        title: 'Calendar',
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
                              title: Text(item.name),
                              subtitle: Text(
                                '${item.calendarCode} | ${item.type.uiLabel} | ${item.countryDisplayCode.isEmpty ? '-' : item.countryDisplayCode} | ${item.timezone}',
                              ),
                              trailing: Text(
                                item.active ? 'Active' : 'Inactive',
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
