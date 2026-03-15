import 'package:flutter/material.dart';

import '../l10n/app_text.dart';

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
  final VoidCallback? onOpen;
  final bool hasSelection;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final wideLayout = MediaQuery.sizeOf(context).width >= 860;

    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBack,
      ),
      actions: wideLayout ? _buildWideActions() : _buildCompactActions(context),
    );
  }

  List<Widget> _buildWideActions() {
    return [
      if (onOpen != null)
        _AppBarActionButton(
          labelBuilder: (context) => context.tr(en: 'Open', ko: '열기'),
          icon: Icons.open_in_new,
          enabled: hasSelection,
          onPressed: onOpen,
        ),
      _AppBarActionButton(
        labelBuilder: (context) => context.tr(en: 'New', ko: '신규'),
        icon: Icons.add,
        enabled: true,
        onPressed: onNew,
      ),
      _AppBarActionButton(
        labelBuilder: (context) => context.tr(en: 'Edit', ko: '수정'),
        icon: Icons.edit,
        enabled: hasSelection,
        onPressed: onEdit,
      ),
      _AppBarActionButton(
        labelBuilder: (context) => context.tr(en: 'Delete', ko: '삭제'),
        icon: Icons.delete_outline,
        enabled: hasSelection,
        onPressed: onDelete,
      ),
      const SizedBox(width: 8),
    ];
  }

  List<Widget> _buildCompactActions(BuildContext context) {
    return [
      PopupMenuButton<_ListAction>(
        tooltip: context.tr(en: 'Actions', ko: '동작'),
        onSelected: (value) {
          switch (value) {
            case _ListAction.open:
              if (hasSelection && onOpen != null) {
                onOpen!.call();
              }
            case _ListAction.newItem:
              onNew();
            case _ListAction.edit:
              if (hasSelection) {
                onEdit();
              }
            case _ListAction.delete:
              if (hasSelection) {
                onDelete();
              }
          }
        },
        itemBuilder: (context) => [
          if (onOpen != null)
            PopupMenuItem<_ListAction>(
              value: _ListAction.open,
              enabled: hasSelection,
              child: _PopupActionRow(
                icon: Icons.open_in_new,
                label: context.tr(en: 'Open', ko: '열기'),
              ),
            ),
          PopupMenuItem<_ListAction>(
            value: _ListAction.newItem,
            child: _PopupActionRow(
              icon: Icons.add,
              label: context.tr(en: 'New', ko: '신규'),
            ),
          ),
          PopupMenuItem<_ListAction>(
            value: _ListAction.edit,
            enabled: hasSelection,
            child: _PopupActionRow(
              icon: Icons.edit,
              label: context.tr(en: 'Edit', ko: '수정'),
            ),
          ),
          PopupMenuItem<_ListAction>(
            value: _ListAction.delete,
            enabled: hasSelection,
            child: _PopupActionRow(
              icon: Icons.delete_outline,
              label: context.tr(en: 'Delete', ko: '삭제'),
            ),
          ),
        ],
      ),
      const SizedBox(width: 8),
    ];
  }
}

enum _ListAction { open, newItem, edit, delete }

class _AppBarActionButton extends StatelessWidget {
  const _AppBarActionButton({
    required this.labelBuilder,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final String Function(BuildContext context) labelBuilder;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: TextButton.icon(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          backgroundColor: scheme.surfaceContainerLow,
          foregroundColor: scheme.onSurface,
          disabledForegroundColor: scheme.onSurfaceVariant.withValues(
            alpha: 0.38,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(labelBuilder(context)),
      ),
    );
  }
}

class _PopupActionRow extends StatelessWidget {
  const _PopupActionRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(label)],
    );
  }
}
