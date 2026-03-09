import 'package:flutter/material.dart';
import '../../api/mock_list_api.dart';
import '../../models/list_item_model.dart';
import '../../widgets/list_screen_app_bar.dart';

/// Job Schedule list screen.
class JobScheduleListScreen extends StatefulWidget {
  const JobScheduleListScreen({super.key});

  @override
  State<JobScheduleListScreen> createState() => _JobScheduleListScreenState();
}

class _JobScheduleListScreenState extends State<JobScheduleListScreen> {
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
    final list = await fetchJobScheduleList();
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  void _onNew() {
    final newItem = ListItemModel(
      id: 'js${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Job Schedule',
      subtitle: '00:00',
    );
    setState(() {
      _items = [newItem, ..._items];
      _selectedId = newItem.id;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New: Job Schedule added')),
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
      const SnackBar(content: Text('Delete: selected item removed')),
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
          child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete')),
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
        _deleteItem(item);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ListScreenAppBar(
        title: 'Job Schedule',
        onBack: () => Navigator.of(context).pop(),
        onNew: _onNew,
        onEdit: _onEdit,
        onDelete: _onDelete,
        hasSelection: _selectedId != null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No job schedule items'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
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
                        title: Text(item.title),
                        subtitle:
                            item.subtitle != null ? Text(item.subtitle!) : null,
                        onTap: () => setState(() => _selectedId = item.id),
                      ),
                    );
                  },
                ),
    );
  }
}
