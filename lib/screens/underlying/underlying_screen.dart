import 'package:flutter/material.dart';
import 'underlying_theme_list_screen.dart';

/// Underlying - 6개 큰 주제: Stock, Commodity, Rates Index, Currency Pair, Credit, Bond
class UnderlyingScreen extends StatelessWidget {
  const UnderlyingScreen({super.key});

  static const _mainTopics = [
    ('Stock', Icons.candlestick_chart),
    ('Commodity', Icons.diamond),
    ('Rates Index', Icons.bar_chart),
    ('Currency Pair', Icons.attach_money),
    ('Credit', Icons.credit_card),
    ('Bond', Icons.savings),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Underlying'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              '주제를 선택하세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ..._mainTopics.map((e) {
              final (label, icon) = e;
              final themeId = _labelToThemeId(label);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TopicButton(
                  label: label,
                  icon: icon,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => UnderlyingThemeListScreen(
                          themeId: themeId,
                          themeLabel: label,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static String _labelToThemeId(String label) {
    switch (label) {
      case 'Stock':
        return 'stock';
      case 'Commodity':
        return 'commodity';
      case 'Rates Index':
        return 'rates_index';
      case 'Currency Pair':
        return 'currency_pair';
      case 'Credit':
        return 'credit';
      case 'Bond':
        return 'bond';
      default:
        return label.toLowerCase().replaceAll(' ', '_');
    }
  }
}

class _TopicButton extends StatelessWidget {
  const _TopicButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
