import 'package:flutter/material.dart';

import '../../api/calendar_api_client.dart';
import '../../models/weekend_profile_form_data.dart';
import '../../models/weekend_profile_day_form_data.dart';
import '../../widgets/list_screen_app_bar.dart';
import 'weekend_profile_day_edit_screen.dart';

class WeekendProfileDayListScreen extends StatefulWidget {
  const WeekendProfileDayListScreen({super.key});

  @override
  State<WeekendProfileDayListScreen> createState() =>
      _WeekendProfileDayListScreenState();
}

class _WeekendProfileDayListScreenState
    extends State<WeekendProfileDayListScreen> {
  List<WeekendProfileDayFormData> _items = [];
  List<WeekendProfileFormData> _weekendProfileOptions = [];
  bool _loading = false;
  String? _errorMessage;
  String? _selectedId;
  String _appliedWeekendProfileId = '';

  final TextEditingController _keywordController = TextEditingController();
  String _appliedKeyword = '';
  String _selectedWeekendProfileId = '';

  @override
  void initState() {
    super.initState();
    _loadWeekendProfileOptions();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _loadWeekendProfileOptions() async {
    try {
      final items = await calendarApi.getWeekendProfileList();
      if (!mounted) return;
      setState(() {
        _weekendProfileOptions = items;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _weekendProfileOptions = [];
      });
    }
  }

  Future<void> _loadItems() async {
    final weekendProfileId = _selectedWeekendProfileId.trim();
    if (weekendProfileId.isEmpty) {
      setState(() {
        _items = [];
        _selectedId = null;
        _appliedWeekendProfileId = '';
        _errorMessage = 'WeekendProfileId is required.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
      _appliedWeekendProfileId = weekendProfileId;
    });
    try {
      final items = await calendarApi.getWeekendProfileDayList(
        weekendProfileId: weekendProfileId,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
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

  List<WeekendProfileDayFormData> _filteredItems() {
    if (_appliedKeyword.isEmpty) return _items;
    final keyword = _appliedKeyword.toLowerCase();
    return _items.where((item) {
      return item.isoWeekday.toString().contains(keyword) ||
          item.weekendProfileId.toLowerCase().contains(keyword) ||
          item.weekendProfileCode.toLowerCase().contains(keyword) ||
          (item.weekend ? 'weekend' : 'business').contains(keyword);
    }).toList();
  }

  Future<void> _onNew() async {
    final result = await Navigator.of(context).push<WeekendProfileDayFormData?>(
      MaterialPageRoute(
        builder: (_) => WeekendProfileDayEditScreen(
          initialWeekendProfileId: _appliedWeekendProfileId,
          weekendProfileOptions: _weekendProfileOptions,
        ),
      ),
    );
    if (result == null || !mounted) return;
    try {
      final created = await calendarApi.createWeekendProfileDay(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = created.effectiveId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WeekendProfileDay created.')),
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
      final initial = await calendarApi.getWeekendProfileDayById(_selectedId!);
      if (!mounted) return;
      if (initial == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected item not found.')),
        );
        return;
      }
      final result = await Navigator.of(context)
          .push<WeekendProfileDayFormData?>(
            MaterialPageRoute(
              builder: (_) => WeekendProfileDayEditScreen(
                initialData: initial,
                weekendProfileOptions: _weekendProfileOptions,
              ),
            ),
          );
      if (result == null || !mounted) return;
      final updated = await calendarApi.updateWeekendProfileDay(result);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = updated.effectiveId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WeekendProfileDay updated.')),
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
      await calendarApi.deleteWeekendProfileDay(_selectedId!);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WeekendProfileDay deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void _showMissingParentMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Load WeekendProfileId first.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ListScreenAppBar(
        title: 'WeekendProfileDay',
        onBack: () => Navigator.of(context).pop(),
        onNew: _appliedWeekendProfileId.isEmpty
            ? _showMissingParentMessage
            : _onNew,
        onEdit: _onEdit,
        onDelete: _onDelete,
        hasSelection: _selectedId != null,
      ),
      body: Column(
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
                          width: 120,
                          child: Text(
                            'WeekendProfile',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedWeekendProfileId.isEmpty
                                ? null
                                : _selectedWeekendProfileId,
                            decoration: const InputDecoration(
                              hintText: 'Select profile',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: _weekendProfileOptions
                                .where((item) => (item.id ?? '').isNotEmpty)
                                .map(
                                  (item) => DropdownMenuItem<String>(
                                    value: item.id!,
                                    child: Text(
                                      '${item.weekendProfileCode} | ${item.name}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(
                              () => _selectedWeekendProfileId = value ?? '',
                            ),
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
                          width: 120,
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
                  ],
                ),
              ),
            ),
          ),
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
                            _appliedWeekendProfileId.isEmpty
                                ? 'Enter WeekendProfileId and load days.'
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
                            title: Text('ISO Weekday ${item.isoWeekday}'),
                            subtitle: Text(
                              '${item.weekendProfileCode.isEmpty ? item.weekendProfileId : item.weekendProfileCode} | ${item.weekend ? 'Weekend' : 'Business'}',
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
