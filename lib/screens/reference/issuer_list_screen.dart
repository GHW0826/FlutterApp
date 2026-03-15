import 'package:flutter/material.dart';

import '../../api/country_api_client.dart';
import '../../models/country_form_data.dart';
import '../../api/issuer_api_client.dart';
import '../../models/issuer_form_data.dart';
import '../../widgets/list_screen_app_bar.dart';
import 'issuer_edit_screen.dart';

class IssuerListScreen extends StatefulWidget {
  const IssuerListScreen({super.key});

  @override
  State<IssuerListScreen> createState() => _IssuerListScreenState();
}

class _IssuerListScreenState extends State<IssuerListScreen> {
  List<IssuerFormData> _items = [];
  List<CountryFormData> _countryOptions = [];
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
        issuerApi.getList(),
        countryApi.getList(),
      ]);
      final list = results[0] as List<IssuerFormData>;
      final countries = results[1] as List<CountryFormData>;
      if (!mounted) return;
      setState(() {
        _items = list;
        _countryOptions = countries;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _countryOptions = [];
        _loading = false;
        _errorMessage = 'Failed to load issuer list.';
      });
    }
  }

  IssuerFormData? get _selectedItem {
    final selectedId = _selectedId;
    if (selectedId == null) return null;
    for (final item in _items) {
      if (item.id == selectedId) return item;
    }
    return null;
  }

  void _onSearch() {
    setState(() => _appliedKeyword = _keywordController.text.trim());
  }

  List<IssuerFormData> _filteredItems() {
    if (_appliedKeyword.isEmpty) return _items;
    final keyword = _appliedKeyword.toLowerCase();
    return _items.where((item) {
      final byName = _nameChecked && item.name.toLowerCase().contains(keyword);
      final byCode =
          _codeChecked &&
          (item.code.toLowerCase().contains(keyword) ||
              item.issuerCode.toLowerCase().contains(keyword));
      if (!_nameChecked && !_codeChecked) {
        return item.name.toLowerCase().contains(keyword) ||
            item.code.toLowerCase().contains(keyword) ||
            item.issuerCode.toLowerCase().contains(keyword) ||
            item.countryIso2.toLowerCase().contains(keyword) ||
            item.description.toLowerCase().contains(keyword);
      }
      return byName || byCode;
    }).toList();
  }

  Future<void> _onOpen() async {
    final selectedId = _selectedId;
    if (selectedId == null) return;
    final initial = await issuerApi.getById(selectedId);
    if (!mounted || initial == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => IssuerEditScreen(
          initialData: initial,
          parentOptions: _items,
          countryOptions: _countryOptions,
          readOnly: true,
        ),
      ),
    );
  }

  Future<void> _onEdit() async {
    final selectedId = _selectedId;
    if (selectedId == null) return;
    final initial = await issuerApi.getById(selectedId);
    if (!mounted || initial == null) return;

    final navigator = Navigator.of(context);
    final result = await navigator.push<IssuerEditResult?>(
      MaterialPageRoute(
        builder: (_) => IssuerEditScreen(
          initialData: initial,
          parentOptions: _items,
          countryOptions: _countryOptions,
        ),
      ),
    );
    if (result == null || !mounted) return;
    try {
      final updated = switch (result.action) {
        IssuerSaveAction.put => await issuerApi.put(result.data),
        IssuerSaveAction.patch => await issuerApi.patch(result.data),
        IssuerSaveAction.create => await issuerApi.create(result.data),
      };
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = updated.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.action == IssuerSaveAction.put
                ? 'Issuer replaced.'
                : 'Issuer updated.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  Future<void> _onNew() async {
    final result = await Navigator.of(context).push<IssuerEditResult?>(
      MaterialPageRoute(
        builder: (_) => IssuerEditScreen(
          parentOptions: _items,
          countryOptions: _countryOptions,
        ),
      ),
    );
    if (result == null || !mounted) return;
    try {
      final created = await issuerApi.create(result.data);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = created.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Issuer created.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    }
  }

  Future<void> _onDelete() async {
    final selected = _selectedItem;
    if (selected == null) return;
    final hasChildren = _items.any(
      (e) => e.parentIssuerCode == selected.issuerCode,
    );
    if (hasChildren) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete issuer that has child issuers.'),
        ),
      );
      return;
    }
    try {
      final targetId = (selected.id ?? '').trim();
      if (targetId.isEmpty) {
        throw StateError('Issuer id is empty.');
      }
      await issuerApi.delete(id: targetId);
      await _loadItems();
      if (!mounted) return;
      setState(() => _selectedId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Issuer deleted.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _showItemContextMenu(
    BuildContext context,
    TapDownDetails details,
    IssuerFormData item,
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
          value: 'edit',
          child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
        ),
        PopupMenuItem(
          value: 'new',
          child: ListTile(leading: Icon(Icons.add), title: Text('New')),
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
        setState(() => _selectedId = item.id);
        _onOpen();
        break;
      case 'edit':
        setState(() => _selectedId = item.id);
        _onEdit();
        break;
      case 'new':
        _onNew();
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
        title: 'Issuer',
        onBack: () => Navigator.of(context).pop(),
        onOpen: _onOpen,
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
                          final selected = item.id == _selectedId;
                          return GestureDetector(
                            onSecondaryTapDown: (details) =>
                                _showItemContextMenu(context, details, item),
                            child: ListTile(
                              selected: selected,
                              selectedTileColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.5),
                              title: Text(item.name),
                              subtitle: Text(
                                '${item.issuerCode} | ${item.code} | ${item.countryIso2.isEmpty ? '-' : item.countryIso2} | ${item.activeFlag ? 'Active' : 'Inactive'}',
                              ),
                              trailing: item.parentIssuerCode.isEmpty
                                  ? null
                                  : Text('Parent: ${item.parentIssuerCode}'),
                              onTap: () =>
                                  setState(() => _selectedId = item.id),
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
}
