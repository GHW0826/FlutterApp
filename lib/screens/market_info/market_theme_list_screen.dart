import 'package:flutter/material.dart';
import '../../models/list_item_model.dart';
import '../../models/bond_form_data.dart';
import '../../api/mock_list_api.dart';
import '../../api/bond_api_client.dart';
import '../../widgets/list_screen_app_bar.dart';
import 'bond_edit_screen.dart';

/// Market Management 테마별 리스트 화면 (Equity, Commodity, Fx, Price Index, Bond)
class MarketThemeListScreen extends StatefulWidget {
  const MarketThemeListScreen({
    super.key,
    required this.themeId,
    required this.themeLabel,
  });

  final String themeId;
  final String themeLabel;

  @override
  State<MarketThemeListScreen> createState() => _MarketThemeListScreenState();
}

class _MarketThemeListScreenState extends State<MarketThemeListScreen> {
  List<ListItemModel> _items = [];
  bool _loading = true;
  String? _errorMessage;
  String? _selectedId;

  final TextEditingController _keywordController = TextEditingController();
  bool _nameChecked = true;
  bool _marketCodeChecked = true;
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

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final list = widget.themeId == 'bond'
          ? await bondApi.getList()
          : await fetchMarketThemeList(widget.themeId);
      if (mounted) {
        setState(() {
          _items = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _items = [];
          _loading = false;
          _errorMessage = '통신오류';
        });
      }
    }
  }

  Future<void> _onNew() async {
    if (widget.themeId == 'bond') {
      final result = await Navigator.of(context).push<BondFormData?>(
        MaterialPageRoute(builder: (_) => const BondEditScreen()),
      );
      if (result != null && mounted) {
        try {
          final created = await bondApi.create(result);
          await _loadItems();
          if (mounted) {
            setState(() => _selectedId = created.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bond 저장됨')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('저장 실패: $e')),
            );
          }
        }
      }
      return;
    }
    final newItem = ListItemModel(
      id: '${widget.themeId}_${DateTime.now().millisecondsSinceEpoch}',
      title: '새 ${widget.themeLabel} 항목',
      subtitle: '-',
    );
    setState(() {
      _items = [newItem, ..._items];
      _selectedId = newItem.id;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('New: ${widget.themeLabel} 추가됨')),
    );
  }

  Future<void> _onEdit() async {
    if (_selectedId == null) return;
    final item = _items.where((e) => e.id == _selectedId).firstOrNull;
    if (item == null) return;
    if (widget.themeId == 'bond') {
      try {
        final initial = await bondApi.getById(item.id);
        if (!mounted) return;
        if (initial == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('항목을 찾을 수 없습니다.')),
          );
          return;
        }
        final result = await Navigator.of(context).push<BondFormData?>(
          MaterialPageRoute(builder: (_) => BondEditScreen(initialData: initial)),
        );
        if (result != null && mounted) {
          await bondApi.update(result);
          await _loadItems();
          if (mounted) {
            setState(() => _selectedId = result.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bond 수정됨')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('조회/수정 실패: $e')),
          );
        }
      }
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit: ${item.title}')),
    );
  }

  Future<void> _onDelete() async {
    if (_selectedId == null) return;
    if (widget.themeId == 'bond') {
      try {
        await bondApi.delete(_selectedId!);
        await _loadItems();
        if (mounted) {
          setState(() => _selectedId = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Delete: 선택 항목 삭제됨')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
      return;
    }
    setState(() {
      _items = _items.where((e) => e.id != _selectedId).toList();
      _selectedId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete: 선택 항목 삭제됨')),
    );
  }

  Future<void> _deleteItem(ListItemModel item) async {
    if (widget.themeId == 'bond') {
      try {
        await bondApi.delete(item.id);
        await _loadItems();
        if (mounted) {
          setState(() {
            if (_selectedId == item.id) _selectedId = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete: ${item.title}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
      return;
    }
    setState(() {
      _items = _items.where((e) => e.id != item.id).toList();
      if (_selectedId == item.id) _selectedId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete: ${item.title}')),
    );
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
        const PopupMenuItem(value: 'new', child: ListTile(leading: Icon(Icons.add), title: Text('New'))),
        const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
        const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete'))),
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
                                    hintText: '검색어 입력',
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
                ),
                Expanded(
                  child: _items.isEmpty
                      ? const Center(child: Text('목록이 비어 있습니다.'))
                      : Builder(
                          builder: (context) {
                            final filtered = _getFilteredItems();
                            if (filtered.isEmpty) {
                              return Center(
                                child: Text(
                                  _appliedKeyword.isEmpty ? '목록이 비어 있습니다.' : '검색 결과가 없습니다.',
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final selected = item.id == _selectedId;
                                return GestureDetector(
                                  onSecondaryTapDown: (details) => _showItemContextMenu(context, details, item),
                                  child: ListTile(
                                    selected: selected,
                                    selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                                    title: Text(item.title),
                                    subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                                    onTap: () => setState(() => _selectedId = item.id),
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
