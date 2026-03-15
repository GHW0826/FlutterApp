import 'package:flutter/material.dart';

import '../../api/calendar_api_client.dart';
import '../../models/weekend_profile_form_data.dart';
import '../../widgets/list_screen_app_bar.dart';
import 'weekend_profile_edit_screen.dart';

class WeekendProfileListScreen extends StatefulWidget {
  const WeekendProfileListScreen({super.key});

  @override
  State<WeekendProfileListScreen> createState() => _WeekendProfileListScreenState();
}

class _WeekendProfileListScreenState extends State<WeekendProfileListScreen> {
  List<WeekendProfileFormData> _items = [];
  bool _loading = true;
  String? _errorMessage;
  String? _selectedId;

  final TextEditingController _keywordController = TextEditingController();
  bool _codeChecked = true;
  bool _nameChecked = true;
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
      final profiles = await calendarApi.getWeekendProfileList();
      if (!mounted) return;
      setState(() {
        _items = profiles;
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

  List<WeekendProfileFormData> _filteredItems() {
    if (_appliedKeyword.isEmpty) return _items;
    final keyword = _appliedKeyword.toLowerCase();
    return _items.where((item) {
      final byCode =
          _codeChecked && item.weekendProfileCode.toLowerCase().contains(keyword);
      final byName = _nameChecked && item.name.toLowerCase().contains(keyword);
      if (!_codeChecked && !_nameChecked) {
        return item.weekendProfileCode.toLowerCase().contains(keyword) ||
            item.name.toLowerCase().contains(keyword) ||
            item.description.toLowerCase().contains(keyword);
      }
      return byCode || byName;
    }).toList();
  }

  Future<void> _onNew() async {
    final result = await Navigator.of(context).push<WeekendProfileFormData?>(
      MaterialPageRoute(builder: (_) => const WeekendProfileEditScreen()),
    );
    if (result == null || !mounted) return;
    try {
      final created = await calendarApi.createWeekendProfile(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = created.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WeekendProfile created.')),
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
      final initial = await calendarApi.getWeekendProfileById(_selectedId!);
      if (!mounted) return;
      if (initial == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected item not found.')),
        );
        return;
      }
      final result = await Navigator.of(context).push<WeekendProfileFormData?>(
        MaterialPageRoute(
          builder: (_) => WeekendProfileEditScreen(initialData: initial),
        ),
      );
      if (result == null || !mounted) return;
      final updated = await calendarApi.updateWeekendProfile(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = updated.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WeekendProfile updated.')),
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
      await calendarApi.deleteWeekendProfile(_selectedId!);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WeekendProfile deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ListScreenAppBar(
        title: 'WeekendProfile',
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
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
                                value: _codeChecked,
                                onChanged: (v) =>
                                    setState(() => _codeChecked = v ?? true),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _codeChecked = !_codeChecked),
                                child: const Text('code'),
                              ),
                              const SizedBox(width: 24),
                              Checkbox(
                                value: _nameChecked,
                                onChanged: (v) =>
                                    setState(() => _nameChecked = v ?? true),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _nameChecked = !_nameChecked),
                                child: const Text('name'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final filtered = _filteredItems();
                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            _appliedKeyword.isEmpty ? 'No items.' : 'No search results.',
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            selected: _selectedId == item.id,
                            selectedTileColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.5),
                            title: Text(item.weekendProfileCode),
                            subtitle: Text(item.name),
                            trailing: Text(
                              item.description.isEmpty ? '-' : item.description,
                            ),
                            onTap: () => setState(() => _selectedId = item.id),
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
