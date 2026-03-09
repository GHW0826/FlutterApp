import 'package:flutter/material.dart';

import '../../models/list_item_model.dart';

class ProductNewPickerScreen extends StatefulWidget {
  const ProductNewPickerScreen({super.key});

  @override
  State<ProductNewPickerScreen> createState() => _ProductNewPickerScreenState();
}

class _ProductNewPickerScreenState extends State<ProductNewPickerScreen> {
  final ValueNotifier<_ProductTypeDef?> _selectedType =
      ValueNotifier<_ProductTypeDef?>(null);
  late final Map<String, ValueNotifier<bool>> _tileSelectedByCode;
  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    _tileSelectedByCode = {
      for (final type in _allTypes(_roots))
        type.code: ValueNotifier<bool>(false),
    };
  }

  @override
  void dispose() {
    for (final listenable in _tileSelectedByCode.values) {
      listenable.dispose();
    }
    _selectedType.dispose();
    super.dispose();
  }

  void _selectType(_ProductTypeDef typeDef) {
    if (_selectedCode == typeDef.code) return;
    final prev = _selectedCode;
    _selectedCode = typeDef.code;

    if (prev != null) {
      _tileSelectedByCode[prev]?.value = false;
    }
    _tileSelectedByCode[typeDef.code]?.value = true;
    _selectedType.value = typeDef;
  }

  Future<void> _openCreateScreen(_ProductTypeDef typeDef) async {
    final result = await Navigator.of(context).push<ListItemModel?>(
      MaterialPageRoute(
        builder: (_) => _ProductDummyCreateScreen(typeDef: typeDef),
      ),
    );
    if (!mounted || result == null) return;
    Navigator.of(context).pop(result);
  }

  Widget _buildTypeItem(_ProductTypeDef typeDef) {
    return ValueListenableBuilder<bool>(
      valueListenable: _tileSelectedByCode[typeDef.code]!,
      builder: (context, selected, _) {
        return Material(
          color: selected
              ? _depthColor(context, depth: 3, selected: true)
              : _depthColor(context, depth: 3),
          child: ListTile(
            dense: true,
            onTap: () => _selectType(typeDef),
            onLongPress: () => _openCreateScreen(typeDef),
            title: Text(typeDef.label),
            subtitle: const Text('Tap to preview · Long press to open'),
            trailing: IconButton(
              tooltip: 'Open Create Screen',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.open_in_new, size: 18),
              onPressed: () => _openCreateScreen(typeDef),
            ),
          ),
        );
      },
    );
  }

  Color _depthColor(
    BuildContext context, {
    required int depth,
    bool selected = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    if (selected) {
      return Color.alphaBlend(
        scheme.primary.withValues(alpha: 0.22),
        scheme.surface,
      );
    }

    final alpha = switch (depth) {
      1 => 0.06,
      2 => 0.12,
      3 => 0.26,
      _ => 0.18,
    };
    return Color.alphaBlend(
      scheme.primary.withValues(alpha: alpha),
      scheme.surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Type Select')),
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: RepaintBoundary(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const ListTile(
                    title: Text(
                      'LO - Product Tree',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Expand the tree, tap to preview, and long press to open.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._roots.map((root) {
                    return Card(
                      child: ExpansionTile(
                        maintainState: true,
                        backgroundColor: _depthColor(context, depth: 1),
                        collapsedBackgroundColor: _depthColor(
                          context,
                          depth: 1,
                        ),
                        title: Text(root.label),
                        children: root.groups
                            .map(
                              (group) => ExpansionTile(
                                maintainState: true,
                                backgroundColor: _depthColor(context, depth: 2),
                                collapsedBackgroundColor: _depthColor(
                                  context,
                                  depth: 2,
                                ),
                                title: Text(group.label),
                                children: group.types
                                    .map(_buildTypeItem)
                                    .toList(),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: RepaintBoundary(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: ValueListenableBuilder<_ProductTypeDef?>(
                  valueListenable: _selectedType,
                  builder: (context, selectedType, _) {
                    if (selectedType == null) {
                      return const Center(
                        child: Text('Select a product type.'),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedType.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Category: ${selectedType.categoryLabel}'),
                        const SizedBox(height: 16),
                        Text('Tabs: ${selectedType.tabs.join(', ')}'),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () => _openCreateScreen(selectedType),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open Create Screen'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDummyCreateScreen extends StatefulWidget {
  const _ProductDummyCreateScreen({required this.typeDef});

  final _ProductTypeDef typeDef;

  @override
  State<_ProductDummyCreateScreen> createState() =>
      _ProductDummyCreateScreenState();
}

class _ProductDummyCreateScreenState extends State<_ProductDummyCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    final millis = DateTime.now().millisecondsSinceEpoch;
    _nameController = TextEditingController(text: widget.typeDef.label);
    _codeController = TextEditingController(text: 'PROD-$millis');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final item = ListItemModel(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      title: _nameController.text.trim(),
      subtitle: widget.typeDef.label,
    );
    Navigator.of(context).pop(item);
  }

  Widget _buildDummyTabBody(String tabName, int tabIndex) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(tabName, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(
            labelText: '$tabName Field A',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(
            labelText: '$tabName Field B',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: 'Option 1',
          decoration: InputDecoration(
            labelText: '$tabName Option',
            border: const OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
            DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
            DropdownMenuItem(value: 'Option 3', child: Text('Option 3')),
          ],
          onChanged: (_) {},
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: tabIndex.isEven,
          onChanged: (_) {},
          title: Text('$tabName Enabled'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.typeDef.tabs;
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('New - ${widget.typeDef.label}'),
          actions: [
            TextButton.icon(
              onPressed: _onSave,
              icon: const Icon(Icons.check, size: 20),
              label: const Text('Save'),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs.map((e) => Tab(text: e)).toList(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Product Name is required.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Product Code',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Product Code is required.'
                          : null,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: TabBarView(
                  children: [
                    for (var i = 0; i < tabs.length; i++)
                      _buildDummyTabBody(tabs[i], i),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductRootDef {
  const _ProductRootDef({required this.label, required this.groups});

  final String label;
  final List<_ProductGroupDef> groups;
}

class _ProductGroupDef {
  const _ProductGroupDef({required this.label, required this.types});

  final String label;
  final List<_ProductTypeDef> types;
}

class _ProductTypeDef {
  const _ProductTypeDef({
    required this.code,
    required this.label,
    required this.categoryLabel,
    required this.tabs,
  });

  final String code;
  final String label;
  final String categoryLabel;
  final List<String> tabs;
}

final List<_ProductRootDef> _roots = [
  _ProductRootDef(
    label: 'Bond',
    groups: [
      _ProductGroupDef(
        label: 'Forward',
        types: [
          _ProductTypeDef(
            code: 'bond_forward',
            label: 'Bond Forward',
            categoryLabel: 'Bond > Forward',
            tabs: ['Basic', 'Forward Terms', 'Settlement', 'Risk'],
          ),
        ],
      ),
      _ProductGroupDef(
        label: 'Notes',
        types: [
          _ProductTypeDef(
            code: 'zero_coupon',
            label: 'Zero Coupon',
            categoryLabel: 'Bond > Notes',
            tabs: ['Basic', 'Issue', 'Pricing'],
          ),
          _ProductTypeDef(
            code: 'fixed_coupon',
            label: 'Fixed Coupon',
            categoryLabel: 'Bond > Notes',
            tabs: ['Basic', 'Coupon', 'Schedule', 'Cashflow'],
          ),
          _ProductTypeDef(
            code: 'simple_coupon',
            label: 'Simple Coupon',
            categoryLabel: 'Bond > Notes',
            tabs: ['Basic', 'Simple Interest', 'Payment'],
          ),
          _ProductTypeDef(
            code: 'compounding_coupon',
            label: 'Compounding Coupon',
            categoryLabel: 'Bond > Notes',
            tabs: ['Basic', 'Compounding Rule', 'Accrual', 'Payment'],
          ),
          _ProductTypeDef(
            code: 'simpie_compouding_coupon',
            label: 'Simpie&Compouding Coupon',
            categoryLabel: 'Bond > Notes',
            tabs: ['Basic', 'Simple Phase', 'Compounding Phase', 'Transition'],
          ),
          _ProductTypeDef(
            code: 'compounding_simple_coupon',
            label: 'Compounding&Simple Coupon',
            categoryLabel: 'Bond > Notes',
            tabs: ['Basic', 'Compounding Phase', 'Simple Phase', 'Transition'],
          ),
          _ProductTypeDef(
            code: 'fixed_with_simple_grace_coupon',
            label: 'Fixed Coupon with Simple Grace Coupon',
            categoryLabel: 'Bond > Notes',
            tabs: ['Basic', 'Fixed Coupon', 'Grace(Simple)', 'Schedule'],
          ),
          _ProductTypeDef(
            code: 'fixed_with_compounding_grace_coupon',
            label: 'Fixed Coupon With Compounding Grace Coupon',
            categoryLabel: 'Bond > Notes',
            tabs: ['Basic', 'Fixed Coupon', 'Grace(Compounding)', 'Schedule'],
          ),
          _ProductTypeDef(
            code: 'perpetual_fixed_coupon',
            label: 'Perpetual Fixed Coupon',
            categoryLabel: 'Bond > Notes',
            tabs: ['Basic', 'Coupon', 'Call/Put', 'Perpetual Rule'],
          ),
          _ProductTypeDef(
            code: 'inflation_linked_fixed_coupon',
            label: 'Inflation Linked Fixed Coupon',
            categoryLabel: 'Bond > Notes',
            tabs: ['Basic', 'Inflation Index', 'Coupon', 'Adjustment'],
          ),
        ],
      ),
    ],
  ),
  _rootFromRaw('IR', {
    'CapFloors': [
      'Standard',
      'Asian',
      'Barrier',
      'Digital',
      'Range',
      'Standard Strategy',
    ],
    'Forwards': ['Forward Rate Agreement'],
    'Notes': [
      'Vanilla Floater',
      'Floater',
      'Custom Floater',
      'Accrual',
      'Accrual Flaoter',
      'Custom Accrual',
      'Volatility',
      'Combination',
      'RFR Floater',
    ],
    'Swaps': [
      'Vanilla Swap',
      'Basis Swap',
      'Structured Swap',
      'IR Swap',
      'Overnight Index Swap',
      'Currency Fixed Swap',
      'Currency Vanilla Swap',
      'Currency Basis Swap',
      'Currency Structured Swap',
      'Currency Swap',
      'Currency Overnight Index Swap',
    ],
    'Swaptions': ['Vanilla'],
  }),
  _rootFromRaw('FX', {
    'Forwards': [
      'Cash',
      'Standard',
      'Asian',
      'Barrier',
      'Forward Start',
      'Ratchet',
      'Accrual',
    ],
    'Options': [
      'Standard',
      'Asian',
      'Barrier',
      'Binary',
      'Touch',
      'Forward Start',
      'Ladder',
      'Ratchet',
      'Accrual',
      'Accrual Binary',
    ],
    'Spot': ['Cash'],
  }),
  _rootFromRaw('Equity', {
    'Options': [
      'Standard',
      'Asian',
      'Barrier',
      'Binary',
      'Touch',
      'Forward Start',
      'Ladder',
      'Lookback',
      'Ratchet',
      'Accrual',
      'Accrual Binary',
      'Rainbow Options',
      'Warrants',
    ],
    'Notes': [
      'Basket',
      'Star',
      'Periodic Star',
      'Dispersion',
      'Options Combination',
      'Coupon',
      'Plain',
    ],
    'Swaps': [
      'Star',
      'Periodic Star',
      'Dispersion',
      'Options Combination',
      'Coupon',
      'Total Return',
    ],
  }),
  _rootFromRaw('Hybrid', {
    'Notes': [
      'Hybrid Floater',
      'Hybrid Accrual',
      'Hybrid Combination',
      'Hybrid Star',
      'Hybrid IrStar',
      'Hybrid Options Combination',
      'Hybrid Asset Coupon',
    ],
    'Swaps': [
      'Hybrid Floater',
      'Hybrid Accrual',
      'Hybrid Combination',
      'Hybrid Star',
      'Hybrid IrStar',
      'Hybrid Options Combination',
      'Hybrid Asset Coupon',
      'Hybrid Total Return',
    ],
  }),
  _rootFromRaw('Credit', {
    'Notes': ['Credit Fixed', 'Credit Floater'],
    'Swaps': [
      'Credit Default Swap',
      'Credit Linked Swap',
      'Bond Total Return',
      'Currency Bond Total Return',
      'Credit Index',
    ],
  }),
];

_ProductRootDef _rootFromRaw(
  String rootLabel,
  Map<String, List<String>> rawGroups,
) {
  return _ProductRootDef(
    label: rootLabel,
    groups: rawGroups.entries
        .map(
          (entry) => _ProductGroupDef(
            label: entry.key,
            types: _buildTypes(rootLabel, entry.key, entry.value),
          ),
        )
        .toList(growable: false),
  );
}

List<_ProductTypeDef> _buildTypes(
  String rootLabel,
  String groupLabel,
  List<String> typeLabels,
) {
  return typeLabels
      .map(
        (typeLabel) => _ProductTypeDef(
          code: _buildTypeCode(rootLabel, groupLabel, typeLabel),
          label: typeLabel,
          categoryLabel: '$rootLabel > $groupLabel',
          tabs: const ['Basic', 'Terms', 'Pricing', 'Risk'],
        ),
      )
      .toList(growable: false);
}

String _buildTypeCode(String rootLabel, String groupLabel, String typeLabel) {
  final raw = '${rootLabel}_${groupLabel}_$typeLabel'.toLowerCase();
  final compact = raw
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_');
  return compact.replaceAll(RegExp(r'^_|_$'), '');
}

Iterable<_ProductTypeDef> _allTypes(List<_ProductRootDef> roots) sync* {
  for (final root in roots) {
    for (final group in root.groups) {
      for (final type in group.types) {
        yield type;
      }
    }
  }
}
