import 'package:flutter/material.dart';
import '../../models/list_item_model.dart';
import '../../api/mock_list_api.dart';
import '../../widgets/list_screen_app_bar.dart';

/// Trade 주제 전용 화면 (로직 분리용)
class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  List<ListItemModel> _items = [];
  bool _loading = true;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    final list = await fetchTradeList();
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  void _onNew() {
    final newItem = ListItemModel(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      title: '새 거래',
      subtitle: '${DateTime.now().toString().substring(0, 10)}',
    );
    setState(() {
      _items = [newItem, ..._items];
      _selectedId = newItem.id;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New: 새 거래 추가됨')),
    );
  }

  void _onEdit() {
    if (_selectedId == null) return;
    final item = _items.where((e) => e.id == _selectedId).firstOrNull;
    if (item != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Edit: ${item.title}')),
      );
    }
  }

  void _onDelete() {
    if (_selectedId == null) return;
    setState(() {
      _items = _items.where((e) => e.id != _selectedId).toList();
      _selectedId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete: 선택 거래 삭제됨')),
    );
  }

  void _deleteItem(ListItemModel item) {
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
        title: 'Trade',
        onBack: () => Navigator.of(context).pop(),
        onNew: _onNew,
        onEdit: _onEdit,
        onDelete: _onDelete,
        hasSelection: _selectedId != null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('목록이 비어 있습니다.'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
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
                ),
    );
  }
}
