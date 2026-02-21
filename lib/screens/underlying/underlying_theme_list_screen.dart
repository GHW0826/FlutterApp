import 'package:flutter/material.dart';
import '../../api/bond_api_client.dart';
import '../../api/mock_list_api.dart';
import '../../models/bond_enums.dart';
import '../../models/list_item_model.dart';
import '../../models/underlying_bond_form_data.dart';
import '../../widgets/list_screen_app_bar.dart';
import 'underlying_bond_edit_screen.dart';

/// Underlying ?뚮쭏蹂?由ъ뒪???붾㈃ (Stock, Commodity, Rates Index, Currency Pair, Credit, Bond)
class UnderlyingThemeListScreen extends StatefulWidget {
  const UnderlyingThemeListScreen({
    super.key,
    required this.themeId,
    required this.themeLabel,
  });

  final String themeId;
  final String themeLabel;

  @override
  State<UnderlyingThemeListScreen> createState() => _UnderlyingThemeListScreenState();
}

class _UnderlyingThemeListScreenState extends State<UnderlyingThemeListScreen> {
  List<ListItemModel> _items = [];
  bool _loading = true;
  String? _errorMessage;
  String? _selectedId;

  final TextEditingController _keywordController = TextEditingController();
  bool _nameChecked = true;
  bool _marketCodeChecked = true;
  String _appliedKeyword = '';

  List<ListItemModel> _bondMarketMasters = [];
  final Map<String, UnderlyingBondFormData> _bondFormById = {};

  bool get _isBondTheme => widget.themeId == 'bond';

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
      final list = await fetchUnderlyingThemeList(widget.themeId);
      if (_isBondTheme) {
        // New???듭떊 ?놁씠 ?대━?꾨줉 濡쒖뺄 ?곗씠?곕줈 market master 紐⑸줉??以鍮꾪븳??
        _bondMarketMasters = await fetchMarketThemeList('bond');
      }
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
        _errorMessage = '?듭떊?ㅻ쪟';
      });
    }
  }

  void _onSearch() {
    setState(() => _appliedKeyword = _keywordController.text.trim());
  }

  List<ListItemModel> _getFilteredItems() {
    if (_appliedKeyword.isEmpty) return _items;
    final k = _appliedKeyword.toLowerCase();
    final searchName = _nameChecked;
    final searchCode = _marketCodeChecked;
    if (!searchName && !searchCode) {
      return _items.where((item) {
        final matchName = item.title.toLowerCase().contains(k);
        final matchCode = item.subtitle?.toLowerCase().contains(k) ?? false;
        return matchName || matchCode;
      }).toList();
    }
    return _items.where((item) {
      final matchName = searchName && item.title.toLowerCase().contains(k);
      final matchCode = searchCode && (item.subtitle?.toLowerCase().contains(k) ?? false);
      return matchName || matchCode;
    }).toList();
  }

  UnderlyingBondFormData _initialBondFormFromItem(ListItemModel item) {
    final saved = _bondFormById[item.id];
    if (saved != null) return saved;
    final marketCode = item.subtitle ?? '';
    final marketName = _bondMarketMasters
            .where((e) {
              final code = (e.subtitle?.trim().isNotEmpty ?? false) ? e.subtitle!.trim() : e.id;
              return code == marketCode;
            })
            .firstOrNull
            ?.title ??
        '';
    return UnderlyingBondFormData(
      id: item.id,
      name: item.title,
      marketDataCode: marketCode,
      marketDataName: marketName,
    );
  }

  String _marketCodeOf(ListItemModel item) {
    return (item.subtitle ?? '').trim();
  }

  String _marketNameFromMasters(String marketCode) {
    if (marketCode.isEmpty) return '';
    return _bondMarketMasters
            .where((e) {
              final code = (e.subtitle?.trim().isNotEmpty ?? false) ? e.subtitle!.trim() : e.id;
              return code == marketCode;
            })
            .firstOrNull
            ?.title ??
        '';
  }

  Future<UnderlyingBondFormData?> _loadInitialForBondEdit(ListItemModel item) async {
    try {
      final marketMasters = await bondApi.getList();
      final marketCode = _marketCodeOf(item);
      final detail = marketCode.isEmpty ? null : await bondApi.getById(marketCode);
      if (!mounted) return null;

      setState(() => _bondMarketMasters = marketMasters);
      final saved = _bondFormById[item.id];
      return (saved ?? _initialBondFormFromItem(item)).copyWith(
        id: item.id,
        name: (saved?.name.isNotEmpty ?? false) ? saved!.name : item.title,
        marketDataCode: marketCode,
        marketDataName: _marketNameFromMasters(marketCode),
        ccy: detail?.ccy ?? saved?.ccy,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('?듭떊?ㅻ쪟')),
        );
      }
      return null;
    }
  }

  Future<Ccy?> _resolveMarketCcy(String marketDataCode) async {
    final detail = await bondApi.getById(marketDataCode);
    return detail?.ccy;
  }

  Future<void> _onOpen() async {
    if (_selectedId == null) return;
    final item = _items.where((e) => e.id == _selectedId).firstOrNull;
    if (item == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open: ${item.title}')),
    );
  }

  Future<void> _onNew() async {
    if (!_isBondTheme) {
      final newItem = ListItemModel(
        id: '${widget.themeId}_${DateTime.now().millisecondsSinceEpoch}',
        title: '??${widget.themeLabel} ??ぉ',
        subtitle: '-',
      );
      setState(() {
        _items = [newItem, ..._items];
        _selectedId = newItem.id;
      });
      return;
    }

    final result = await Navigator.of(context).push<UnderlyingBondFormData?>(
      MaterialPageRoute(
        builder: (_) => UnderlyingBondEditScreen(
          marketDataOptions: _bondMarketMasters,
          resolveMarketCcy: _resolveMarketCcy,
        ),
      ),
    );

    if (result == null || !mounted) return;
    final id = result.id ?? 'ub_${DateTime.now().millisecondsSinceEpoch}';
    final saved = result.copyWith(id: id);
    final item = ListItemModel(
      id: id,
      title: saved.name,
      subtitle: saved.marketDataCode,
    );
    setState(() {
      _bondFormById[id] = saved;
      _items = [item, ..._items.where((e) => e.id != id)];
      _selectedId = id;
    });
  }

  Future<void> _onEdit() async {
    if (_selectedId == null) return;
    final item = _items.where((e) => e.id == _selectedId).firstOrNull;
    if (item == null) return;

    if (!_isBondTheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Edit: ${item.title}')),
      );
      return;
    }

    final initial = await _loadInitialForBondEdit(item);
    if (initial == null) return;
    final result = await Navigator.of(context).push<UnderlyingBondFormData?>(
      MaterialPageRoute(
        builder: (_) => UnderlyingBondEditScreen(
          initialData: initial,
          marketDataOptions: _bondMarketMasters,
          resolveMarketCcy: _resolveMarketCcy,
        ),
      ),
    );

    if (result == null || !mounted) return;
    final id = result.id ?? item.id;
    final saved = result.copyWith(id: id);
    setState(() {
      _bondFormById[id] = saved;
      _items = _items
          .map(
            (e) => e.id == item.id
                ? ListItemModel(
                    id: id,
                    title: saved.name,
                    subtitle: saved.marketDataCode,
                  )
                : e,
          )
          .toList();
      _selectedId = id;
    });
  }

  Future<void> _onDelete() async {
    if (_selectedId == null) return;
    setState(() {
      _bondFormById.remove(_selectedId!);
      _items = _items.where((e) => e.id != _selectedId).toList();
      _selectedId = null;
    });
  }

  void _deleteItem(ListItemModel item) {
    setState(() {
      _bondFormById.remove(item.id);
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
        const PopupMenuItem(value: 'open', child: ListTile(leading: Icon(Icons.open_in_new), title: Text('Open'))),
        const PopupMenuItem(value: 'new', child: ListTile(leading: Icon(Icons.add), title: Text('New'))),
        const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
        const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete'))),
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
        _onEdit();
        break;
      case 'delete':
        _deleteItem(item);
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
                    child: Text('Keyword', style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _keywordController,
                      decoration: const InputDecoration(
                        hintText: '寃?됱뼱 ?낅젰',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _onSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _onSearch,
                    icon: const Icon(Icons.search),
                    tooltip: '검색',
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
                    value: _marketCodeChecked,
                    onChanged: (v) => setState(() => _marketCodeChecked = v ?? true),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _marketCodeChecked = !_marketCodeChecked),
                    child: const Text('market code'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<ListItemModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(_appliedKeyword.isEmpty ? '紐⑸줉??鍮꾩뼱 ?덉뒿?덈떎.' : '寃??寃곌낵媛 ?놁뒿?덈떎.'),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = item.id == _selectedId;
        return GestureDetector(
          onSecondaryTapDown: (details) => _showItemContextMenu(context, details, item),
          child: ListTile(
            selected: selected,
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
            title: Text(item.title),
            subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
            onTap: () => setState(() => _selectedId = item.id),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ListScreenAppBar(
        title: widget.themeLabel,
        onBack: () => Navigator.of(context).pop(),
        onNew: _onNew,
        onEdit: _onEdit,
        onDelete: _onDelete,
        onOpen: _onOpen,
        hasSelection: _selectedId != null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _isBondTheme
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSearchArea(),
                        Expanded(child: _buildListView(_getFilteredItems())),
                      ],
                    )
                  : _buildListView(_items),
    );
  }
}


