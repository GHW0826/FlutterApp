import 'package:flutter/material.dart';

import '../../api/calendar_api_client.dart';
import '../../models/calendar_set_form_data.dart';
import '../../widgets/list_screen_app_bar.dart';
import 'calendar_set_edit_screen.dart';

class CalendarSetListScreen extends StatefulWidget {
  const CalendarSetListScreen({super.key});

  @override
  State<CalendarSetListScreen> createState() => _CalendarSetListScreenState();
}

class _CalendarSetListScreenState extends State<CalendarSetListScreen> {
  List<CalendarSetFormData> _items = [];
  bool _loading = true;
  String? _errorMessage;
  String? _selectedId;

  final TextEditingController _keywordController = TextEditingController();
  bool _setCodeChecked = true;
  bool _descriptionChecked = true;
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
      final list = await calendarApi.getCalendarSetList();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _loading = false;
        _errorMessage = 'Failed to load data.';
      });
    }
  }

  void _onSearch() {
    setState(() => _appliedKeyword = _keywordController.text.trim());
  }

  List<CalendarSetFormData> _filteredItems() {
    if (_appliedKeyword.isEmpty) return _items;
    final keyword = _appliedKeyword.toLowerCase();
    return _items.where((item) {
      final code = item.setCode.toLowerCase();
      final description = item.description.toLowerCase();
      final byCode = _setCodeChecked && code.contains(keyword);
      final byDescription =
          _descriptionChecked && description.contains(keyword);
      if (!_setCodeChecked && !_descriptionChecked) {
        return code.contains(keyword) ||
            description.contains(keyword) ||
            item.joinRule.uiLabel.toLowerCase().contains(keyword);
      }
      return byCode || byDescription;
    }).toList();
  }

  Future<void> _onNew() async {
    final result = await Navigator.of(context).push<CalendarSetFormData?>(
      MaterialPageRoute(builder: (_) => const CalendarSetEditScreen()),
    );
    if (result == null || !mounted) return;
    try {
      final created = await calendarApi.createCalendarSet(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = created.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CalendarSet created.')));
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
      final initial = await calendarApi.getCalendarSetById(_selectedId!);
      if (!mounted) return;
      if (initial == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected item not found.')),
        );
        return;
      }
      final result = await Navigator.of(context).push<CalendarSetFormData?>(
        MaterialPageRoute(
          builder: (_) => CalendarSetEditScreen(initialData: initial),
        ),
      );
      if (result == null || !mounted) return;
      final updated = await calendarApi.updateCalendarSet(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = updated.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CalendarSet updated.')));
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
      await calendarApi.deleteCalendarSet(_selectedId!);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CalendarSet deleted.')));
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
    CalendarSetFormData item,
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
                    value: _setCodeChecked,
                    onChanged: (v) =>
                        setState(() => _setCodeChecked = v ?? true),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _setCodeChecked = !_setCodeChecked),
                    child: const Text('set code'),
                  ),
                  const SizedBox(width: 24),
                  Checkbox(
                    value: _descriptionChecked,
                    onChanged: (v) =>
                        setState(() => _descriptionChecked = v ?? true),
                  ),
                  GestureDetector(
                    onTap: () => setState(
                      () => _descriptionChecked = !_descriptionChecked,
                    ),
                    child: const Text('description'),
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
        title: 'CalendarSet',
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
                              title: Text(item.setCode),
                              subtitle: Text(
                                '${item.joinRule.uiLabel} | ${item.description.isEmpty ? '-' : item.description}',
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
