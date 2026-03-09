import 'package:flutter/material.dart';

/// New / Edit / Delete (및 선택적 Open) 액션이 있는 AppBar 공통 위젯
class ListScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ListScreenAppBar({
    super.key,
    required this.title,
    required this.onBack,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    this.onOpen,
    this.hasSelection = false,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  /// Open 버튼 (있으면 표시, Underlying 등)
  final VoidCallback? onOpen;
  final bool hasSelection;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
      ),
      actions: [
        if (onOpen != null)
          TextButton.icon(
            onPressed: hasSelection ? onOpen : null,
            icon: const Icon(Icons.open_in_new, size: 20),
            label: const Text('Open'),
          ),
        TextButton.icon(
          onPressed: onNew,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('New'),
        ),
        TextButton.icon(
          onPressed: hasSelection ? onEdit : null,
          icon: const Icon(Icons.edit, size: 20),
          label: const Text('Edit'),
        ),
        TextButton.icon(
          onPressed: hasSelection ? onDelete : null,
          icon: const Icon(Icons.delete_outline, size: 20),
          label: const Text('Delete'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
