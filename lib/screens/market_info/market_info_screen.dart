import 'package:flutter/material.dart';
import 'market_management_screen.dart';
import 'market_placeholder_screen.dart';

/// Market Information - 5개 큰 주제: Market Management, Market History, Market Shape, Market Calculation, Market Change
class MarketInfoScreen extends StatelessWidget {
  const MarketInfoScreen({super.key});

  static const _mainTopics = [
    ('Market Management', Icons.tune, true),
    ('Market History', Icons.history, false),
    ('Market Shape', Icons.show_chart, false),
    ('Market Calculation', Icons.calculate, false),
    ('Market Change', Icons.trending_up, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Information'),
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
              final (label, icon, hasSub) = e;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TopicButton(
                  label: label,
                  icon: icon,
                  onTap: () {
                    if (hasSub) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const MarketManagementScreen(),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MarketPlaceholderScreen(title: label),
                        ),
                      );
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
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
