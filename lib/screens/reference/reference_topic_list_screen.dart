import 'package:flutter/material.dart';

import '../../api/currency_api_client.dart';
import '../../api/mock_list_api.dart';
import '../../api/vendor_api_client.dart';
import '../../l10n/app_text.dart';
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
        true => context.tr(en: 'active', ko: '활성').toLowerCase(),
        false => context.tr(en: 'inactive', ko: '비활성').toLowerCase(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(en: 'Vendor created.', ko: '벤더가 생성되었습니다.'),
            ),
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(en: 'Currency created.', ko: '통화가 생성되었습니다.'),
            ),
          ),
        );
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
          ReferenceMasterSaveAction.create => await vendorApi.create(request),
        };
        if (!mounted) return;
        await _loadItems();
        if (!mounted) return;
        _selectVendorByCode(updated.code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.action == ReferenceMasterSaveAction.put
                  ? context.tr(en: 'Vendor replaced.', ko: '벤더가 전체 치환되었습니다.')
                  : context.tr(en: 'Vendor updated.', ko: '벤더가 수정되었습니다.'),
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
          ReferenceMasterSaveAction.create => await currencyApi.create(request),
        };
        if (!mounted) return;
        await _loadItems();
        if (!mounted) return;
        _selectCurrencyByCode(updated.code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.action == ReferenceMasterSaveAction.put
                  ? context.tr(en: 'Currency replaced.', ko: '통화가 전체 치환되었습니다.')
                  : context.tr(en: 'Currency updated.', ko: '통화가 수정되었습니다.'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(en: 'Vendor deleted.', ko: '벤더가 삭제되었습니다.'),
            ),
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(en: 'Currency deleted.', ko: '통화가 삭제되었습니다.'),
            ),
          ),
        );
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
        PopupMenuItem(
          value: 'open',
          child: ListTile(
            leading: const Icon(Icons.open_in_new),
            title: Text(context.tr(en: 'Open', ko: '열기')),
          ),
        ),
        PopupMenuItem(
          value: 'new',
          child: ListTile(
            leading: const Icon(Icons.add),
            title: Text(context.tr(en: 'New', ko: '신규')),
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: const Icon(Icons.edit),
            title: Text(context.tr(en: 'Edit', ko: '수정')),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(context.tr(en: 'Delete', ko: '삭제')),
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
                                ? context.tr(en: 'No items.', ko: '항목이 없습니다.')
                                : context.tr(
                                    en: 'No search results.',
                                    ko: '검색 결과가 없습니다.',
                                  ),
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
                  SizedBox(
                    width: 90,
                    child: Text(
                      context.tr(en: 'Keyword', ko: '검색어'),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _keywordController,
                      decoration: InputDecoration(
                        hintText: context.tr(
                          en: 'Type keyword',
                          ko: '검색어를 입력하세요',
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
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
                    tooltip: context.tr(en: 'Search', ko: '검색'),
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
                    child: Text(context.tr(en: 'name', ko: '이름')),
                  ),
                  const SizedBox(width: 24),
                  Checkbox(
                    value: _codeChecked,
                    onChanged: (v) => setState(() => _codeChecked = v ?? true),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _codeChecked = !_codeChecked),
                    child: Text(context.tr(en: 'code', ko: '코드')),
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
              _vendorStatusLabel(context, status),
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
          active
              ? context.tr(en: 'Active', ko: '활성')
              : context.tr(en: 'Inactive', ko: '비활성'),
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
        Text(context.tr(en: 'Code: ${vendor.code}', ko: '코드: ${vendor.code}')),
        Text(
          context.tr(
            en: 'Status: ${vendor.vendorStatus?.uiLabel ?? '-'}',
            ko: '상태: ${vendor.vendorStatus == null ? '-' : _vendorStatusLabel(context, vendor.vendorStatus!)}',
          ),
        ),
        Text(
          context.tr(
            en: 'Effective: $fromText ~ $toText',
            ko: '유효기간: $fromText ~ $toText',
          ),
        ),
        Text(
          context.tr(
            en: 'Desc: ${vendor.description.trim().isEmpty ? '-' : vendor.description.trim()}',
            ko: '설명: ${vendor.description.trim().isEmpty ? '-' : vendor.description.trim()}',
          ),
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
        Text(
          context.tr(en: 'Code: ${currency.code}', ko: '코드: ${currency.code}'),
        ),
        Text(
          context.tr(
            en: 'Status: ${(currency.active ?? true) ? 'Active' : 'Inactive'}',
            ko: '상태: ${(currency.active ?? true) ? '활성' : '비활성'}',
          ),
        ),
        Text(
          context.tr(
            en: 'Desc: ${currency.description.trim().isEmpty ? '-' : currency.description.trim()}',
            ko: '설명: ${currency.description.trim().isEmpty ? '-' : currency.description.trim()}',
          ),
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

String _vendorStatusLabel(BuildContext context, VendorStatus status) {
  switch (status) {
    case VendorStatus.active:
      return context.tr(en: 'Active', ko: '활성');
    case VendorStatus.inactive:
      return context.tr(en: 'Inactive', ko: '비활성');
    case VendorStatus.suspended:
      return context.tr(en: 'Suspended', ko: '중지');
    case VendorStatus.deprecated:
      return context.tr(en: 'Deprecated', ko: '중단');
  }
}

extension on ListItemModel {
  ListItemModel copyWithId(String id) {
    return ListItemModel(id: id, title: title, subtitle: subtitle);
  }
}
