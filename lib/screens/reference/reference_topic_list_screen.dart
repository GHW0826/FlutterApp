import 'package:flutter/material.dart';

import '../../api/currency_api_client.dart';
import '../../api/mock_list_api.dart';
import '../../api/vendor_api_client.dart';
import '../../models/list_item_model.dart';
import '../../models/reference_master_form_data.dart';
import '../../widgets/list_screen_app_bar.dart';
import 'reference_master_edit_screen.dart';

class ReferenceTopicListScreen extends StatefulWidget {
  const ReferenceTopicListScreen({
    super.key,
    required this.themeId,
    required this.themeLabel,
  });

  final String themeId;
  final String themeLabel;

  @override
  State<ReferenceTopicListScreen> createState() =>
      _ReferenceTopicListScreenState();
}

class _ReferenceTopicListScreenState extends State<ReferenceTopicListScreen> {
  List<ListItemModel> _items = [];
  final Map<String, ReferenceMasterFormData> _formById = {};

  bool _loading = true;
  String? _errorMessage;
  String? _selectedId;

  final TextEditingController _keywordController = TextEditingController();
  bool _nameChecked = true;
  bool _codeChecked = true;
  String _appliedKeyword = '';

  bool get _isVendor => widget.themeId == 'vendor';
  bool get _isCurrency => widget.themeId == 'currency';

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
      if (_isVendor) {
        final vendors = await vendorApi.getList(page: 0, size: 100);
        if (!mounted) return;
        final map = <String, ReferenceMasterFormData>{};
        for (final vendor in vendors) {
          final id = _idOfRemoteItem(prefix: 'vendor', data: vendor);
          map[id] = vendor.copyWith(id: id);
        }
        setState(() {
          _formById
            ..clear()
            ..addAll(map);
          _items = map.entries
              .map(
                (entry) => entry.value
                    .toListItem(isVendor: true)
                    .copyWithId(entry.key),
              )
              .toList();
          _loading = false;
        });
        return;
      }

      if (_isCurrency) {
        final currencies = await currencyApi.getList();
        if (!mounted) return;
        final map = <String, ReferenceMasterFormData>{};
        for (final currency in currencies) {
          final id = _idOfRemoteItem(prefix: 'currency', data: currency);
          map[id] = currency.copyWith(id: id);
        }
        setState(() {
          _formById
            ..clear()
            ..addAll(map);
          _items = map.entries
              .map(
                (entry) => entry.value
                    .toListItem(includeActiveState: true)
                    .copyWithId(entry.key),
              )
              .toList();
          _loading = false;
        });
        return;
      }

      final list = await fetchReferenceMasterList(widget.themeId);
      if (!mounted) return;
      setState(() {
        _items = list;
        _formById
          ..clear()
          ..addEntries(
            list.map(
              (item) => MapEntry(
                item.id,
                ReferenceMasterFormData.fromListItem(
                  item,
                  isVendor: _isVendor,
                  isCurrency: _isCurrency,
                ),
              ),
            ),
          );
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

  List<ListItemModel> _getFilteredItems() {
    if (_appliedKeyword.isEmpty) return _items;
    final keyword = _appliedKeyword.toLowerCase();
    return _items.where((item) {
      final form = _formById[item.id];
      final title = item.title.toLowerCase();
      final subtitle = (item.subtitle ?? '').toLowerCase();
      final code = (form?.code ?? '').toLowerCase();
      final description = (form?.description ?? '').toLowerCase();
      final vendorStatus = (form?.vendorStatus?.uiLabel ?? '').toLowerCase();
      final currencyStatus = switch (form?.active) {
        true => 'active',
        false => 'inactive',
        null => '',
      };

      final byName = _nameChecked && title.contains(keyword);
      final byCode =
          _codeChecked &&
          (subtitle.contains(keyword) || code.contains(keyword));
      final byExtra = _isVendor
          ? vendorStatus.contains(keyword) || description.contains(keyword)
          : _isCurrency
          ? currencyStatus.contains(keyword) || description.contains(keyword)
          : description.contains(keyword);

      if (!_nameChecked && !_codeChecked) {
        return title.contains(keyword) ||
            subtitle.contains(keyword) ||
            code.contains(keyword) ||
            vendorStatus.contains(keyword) ||
            currencyStatus.contains(keyword) ||
            description.contains(keyword);
      }
      return byName || byCode || byExtra;
    }).toList();
  }

  Future<void> _onNew() async {
    final result = await Navigator.of(context).push<ReferenceMasterEditResult?>(
      MaterialPageRoute(
        builder: (_) => ReferenceMasterEditScreen(
          themeId: widget.themeId,
          topicLabel: widget.themeLabel,
        ),
      ),
    );
    if (result == null || !mounted) return;

    if (_isVendor) {
      try {
        final created = await vendorApi.create(result.data);
        if (!mounted) return;
        await _loadItems();
        if (!mounted) return;
        _selectVendorByCode(created.code);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vendor created.')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
      }
      return;
    }

    if (_isCurrency) {
      try {
        final created = await currencyApi.create(result.data);
        if (!mounted) return;
        await _loadItems();
        if (!mounted) return;
        _selectCurrencyByCode(created.code);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Currency created.')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
      }
      return;
    }

    final id =
        result.data.id ??
        '${widget.themeId}_${DateTime.now().millisecondsSinceEpoch}';
    final saved = result.data.copyWith(id: id);
    final listItem = saved.toListItem(isVendor: _isVendor);
    setState(() {
      _formById[id] = saved;
      _items = [listItem, ..._items.where((e) => e.id != id)];
      _selectedId = id;
    });
  }

  Future<void> _onOpen() async {
    final selectedItem = _selectedItem;
    if (selectedItem == null) return;

    final initial = await _resolveInitialData(selectedItem);
    if (!mounted || initial == null) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ReferenceMasterEditScreen(
          themeId: widget.themeId,
          topicLabel: widget.themeLabel,
          initialData: initial,
          readOnly: true,
        ),
      ),
    );
  }

  Future<void> _onEdit({ListItemModel? targetItem}) async {
    final selectedItem = targetItem ?? _selectedItem;
    if (selectedItem == null) return;
    if (_selectedId != selectedItem.id) {
      setState(() => _selectedId = selectedItem.id);
    }

    final initial = await _resolveInitialData(selectedItem);
    if (!mounted || initial == null) return;

    final navigator = Navigator.of(context);
    final result = await navigator.push<ReferenceMasterEditResult?>(
      MaterialPageRoute(
        builder: (_) => ReferenceMasterEditScreen(
          themeId: widget.themeId,
          topicLabel: widget.themeLabel,
          initialData: initial,
        ),
      ),
    );
    if (result == null || !mounted) return;

    if (_isVendor) {
      try {
        final resolvedId = _resolveVendorId(
          candidateId: result.data.id ?? selectedItem.id,
        );
        if (resolvedId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot resolve vendor id for update.'),
            ),
          );
          return;
        }
        final request = result.data.copyWith(id: resolvedId);
        final updated = switch (result.action) {
          ReferenceMasterSaveAction.put => await vendorApi.put(request),
          ReferenceMasterSaveAction.patch => await vendorApi.patch(request),
          ReferenceMasterSaveAction.create => await vendorApi.patch(request),
        };
        if (!mounted) return;
        await _loadItems();
        if (!mounted) return;
        _selectVendorByCode(updated.code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.action == ReferenceMasterSaveAction.put
                  ? 'Vendor replaced.'
                  : 'Vendor updated.',
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
      return;
    }

    if (_isCurrency) {
      try {
        final request = result.data.copyWith(
          id: result.data.id ?? selectedItem.id,
        );
        final updated = switch (result.action) {
          ReferenceMasterSaveAction.put => await currencyApi.put(request),
          ReferenceMasterSaveAction.patch => await currencyApi.patch(request),
          ReferenceMasterSaveAction.create => await currencyApi.patch(request),
        };
        if (!mounted) return;
        await _loadItems();
        if (!mounted) return;
        _selectCurrencyByCode(updated.code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.action == ReferenceMasterSaveAction.put
                  ? 'Currency replaced.'
                  : 'Currency updated.',
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
      return;
    }

    final id = result.data.id ?? selectedItem.id;
    final saved = result.data.copyWith(id: id);
    setState(() {
      _formById.remove(selectedItem.id);
      _formById[id] = saved;
      _items = _items
          .map(
            (e) => e.id == selectedItem.id
                ? saved.toListItem(isVendor: _isVendor).copyWithId(id)
                : e,
          )
          .toList();
      _selectedId = id;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.action == ReferenceMasterSaveAction.put
              ? '${widget.themeLabel} replaced.'
              : '${widget.themeLabel} updated.',
        ),
      ),
    );
  }

  Future<void> _onDelete() async {
    final selectedId = _selectedId;
    if (selectedId == null) return;

    if (_isVendor) {
      final resolvedId = _resolveVendorId(candidateId: selectedId);
      if (resolvedId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot resolve vendor id for delete.')),
        );
        return;
      }
      try {
        await vendorApi.delete(id: resolvedId);
        if (!mounted) return;
        setState(() {
          _formById.remove(selectedId);
          _items = _items.where((e) => e.id != selectedId).toList();
          _selectedId = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vendor deleted.')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
      return;
    }

    if (_isCurrency) {
      try {
        await currencyApi.delete(selectedId);
        if (!mounted) return;
        setState(() {
          _formById.remove(selectedId);
          _items = _items.where((e) => e.id != selectedId).toList();
          _selectedId = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Currency deleted.')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
      return;
    }

    setState(() {
      _formById.remove(selectedId);
      _items = _items.where((e) => e.id != selectedId).toList();
      _selectedId = null;
    });
  }

  Future<void> _deleteItem(ListItemModel item) async {
    if (_isVendor) {
      final resolvedId = _resolveVendorId(candidateId: item.id);
      if (resolvedId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot resolve vendor id for delete.')),
        );
        return;
      }
      try {
        await vendorApi.delete(id: resolvedId);
        if (!mounted) return;
        setState(() {
          _formById.remove(item.id);
          _items = _items.where((e) => e.id != item.id).toList();
          if (_selectedId == item.id) _selectedId = null;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
      return;
    }

    if (_isCurrency) {
      try {
        await currencyApi.delete(item.id);
        if (!mounted) return;
        setState(() {
          _formById.remove(item.id);
          _items = _items.where((e) => e.id != item.id).toList();
          if (_selectedId == item.id) _selectedId = null;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
      return;
    }

    setState(() {
      _formById.remove(item.id);
      _items = _items.where((e) => e.id != item.id).toList();
      if (_selectedId == item.id) _selectedId = null;
    });
  }

  Future<void> _showItemContextMenu(
    BuildContext context,
    TapDownDetails details,
    ListItemModel item,
  ) async {
    final overlay = Navigator.of(context).overlay!;
    final relRect = RelativeRect.fromSize(
      Rect.fromLTWH(details.globalPosition.dx, details.globalPosition.dy, 1, 1),
      (overlay.context.findRenderObject() as RenderBox).size,
    );
    final value = await showMenu<String>(
      context: context,
      position: relRect,
      items: [
        const PopupMenuItem(
          value: 'open',
          child: ListTile(
            leading: Icon(Icons.open_in_new),
            title: Text('Open'),
          ),
        ),
        const PopupMenuItem(
          value: 'new',
          child: ListTile(leading: Icon(Icons.add), title: Text('New')),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
        ),
        const PopupMenuItem(
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
      case 'new':
        _onNew();
        break;
      case 'edit':
        setState(() => _selectedId = item.id);
        _onEdit(targetItem: item);
        break;
      case 'delete':
        _deleteItem(item);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ListScreenAppBar(
        title: widget.themeLabel,
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
                      final filtered = _getFilteredItems();
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
                          final form = _formById[item.id];
                          return GestureDetector(
                            onSecondaryTapDown: (details) =>
                                _showItemContextMenu(context, details, item),
                            child: ListTile(
                              selected: selected,
                              selectedTileColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.5),
                              title: Text(form?.name ?? item.title),
                              subtitle: _buildSubtitle(item.id, item),
                              trailing: _buildStatusBadge(item.id),
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

  Widget? _buildSubtitle(String id, ListItemModel item) {
    final form = _formById[id];
    if (_isVendor) {
      return _buildVendorSubtitle(form);
    }
    if (_isCurrency) {
      return _buildCurrencySubtitle(form);
    }
    return item.subtitle != null ? Text(item.subtitle!) : null;
  }

  Widget? _buildStatusBadge(String id) {
    final form = _formById[id];
    if (_isVendor) {
      final status = form?.vendorStatus;
      if (status == null) return null;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _statusColor(status).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: _statusColor(status).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 10, color: _statusColor(status)),
            const SizedBox(width: 6),
            Text(
              status.uiLabel,
              style: TextStyle(
                color: _statusColor(status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    if (_isCurrency) {
      final active = form?.active;
      if (active == null) return null;
      final color = active ? Colors.green : Colors.grey;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          active ? 'Active' : 'Inactive',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      );
    }
    return null;
  }

  Color _statusColor(VendorStatus status) {
    switch (status) {
      case VendorStatus.active:
        return Colors.green;
      case VendorStatus.inactive:
        return Colors.grey;
      case VendorStatus.suspended:
        return Colors.amber.shade700;
      case VendorStatus.deprecated:
        return Colors.red;
    }
  }

  Widget _buildVendorSubtitle(ReferenceMasterFormData? vendor) {
    if (vendor == null) {
      return const Text('-');
    }
    final fromText = _formatDate(vendor.effectiveFrom);
    final toText = _formatDate(vendor.effectiveTo);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Code: ${vendor.code}'),
        Text('Status: ${vendor.vendorStatus?.uiLabel ?? '-'}'),
        Text('Effective: $fromText ~ $toText'),
        Text(
          'Desc: ${vendor.description.trim().isEmpty ? '-' : vendor.description.trim()}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCurrencySubtitle(ReferenceMasterFormData? currency) {
    if (currency == null) {
      return const Text('-');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Code: ${currency.code}'),
        Text('Status: ${(currency.active ?? true) ? 'Active' : 'Inactive'}'),
        Text(
          'Desc: ${currency.description.trim().isEmpty ? '-' : currency.description.trim()}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _selectVendorByCode(String vendorCode) {
    final code = vendorCode.trim();
    if (code.isEmpty) return;
    final selected = _formById.entries
        .where((entry) => entry.value.code.trim() == code)
        .firstOrNull;
    if (selected == null) return;
    setState(() => _selectedId = selected.key);
  }

  void _selectCurrencyByCode(String currencyCode) {
    final code = currencyCode.trim().toUpperCase();
    if (code.isEmpty) return;
    final selected = _formById.entries
        .where((entry) => entry.value.code.trim().toUpperCase() == code)
        .firstOrNull;
    if (selected == null) return;
    setState(() => _selectedId = selected.key);
  }

  ListItemModel? get _selectedItem {
    final selectedId = _selectedId;
    if (selectedId == null) return null;
    return _items.where((e) => e.id == selectedId).firstOrNull;
  }

  Future<ReferenceMasterFormData?> _resolveInitialData(
    ListItemModel item,
  ) async {
    if (_isVendor) {
      return vendorApi.findById(_resolveVendorId(candidateId: item.id));
    }
    if (_isCurrency) {
      return currencyApi.getById(item.id);
    }
    return _formById[item.id] ??
        ReferenceMasterFormData.fromListItem(
          item,
          isVendor: _isVendor,
          isCurrency: _isCurrency,
        );
  }

  String _idOfRemoteItem({
    required String prefix,
    required ReferenceMasterFormData data,
  }) {
    final id = (data.id ?? '').trim();
    if (id.isNotEmpty) return id;
    final code = data.code.trim();
    if (code.isNotEmpty) return code;
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _resolveVendorId({required String? candidateId}) {
    final rawId = (candidateId ?? '').trim();
    if (int.tryParse(rawId) != null) {
      return rawId;
    }

    final localId = (_formById[rawId]?.id ?? '').trim();
    if (int.tryParse(localId) != null) {
      return localId;
    }
    return '';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

extension on ListItemModel {
  ListItemModel copyWithId(String id) {
    return ListItemModel(id: id, title: title, subtitle: subtitle);
  }
}
