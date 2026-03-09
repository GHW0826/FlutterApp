import 'package:flutter/material.dart';

import 'calendar_topic_list_screen.dart';
import 'country_list_screen.dart';
import 'issuer_list_screen.dart';
import 'reference_topic_list_screen.dart';

/// Reference hub screen.
class ReferenceScreen extends StatelessWidget {
  const ReferenceScreen({super.key});

  static const _mainTopics = <_ReferenceTopic>[
    _ReferenceTopic(
      label: 'Country',
      themeId: 'country',
      icon: Icons.public_outlined,
    ),
    _ReferenceTopic(
      label: 'Currency',
      themeId: 'currency',
      icon: Icons.attach_money_outlined,
    ),
    _ReferenceTopic(
      label: 'Vendor',
      themeId: 'vendor',
      icon: Icons.store_outlined,
    ),
    _ReferenceTopic(
      label: 'Issuer',
      themeId: 'issuer',
      icon: Icons.account_balance_outlined,
    ),
    _ReferenceTopic(
      label: 'Calendar',
      themeId: 'calendar',
      icon: Icons.calendar_month_outlined,
    ),
    _ReferenceTopic(
      label: 'Exchange',
      themeId: 'exchange',
      icon: Icons.candlestick_chart_outlined,
    ),
    _ReferenceTopic(
      label: 'Counterparty',
      themeId: 'counterparty',
      icon: Icons.handshake_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reference'),
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
              'Select a reference topic.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ..._mainTopics.map((topic) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TopicButton(
                  label: topic.label,
                  icon: topic.icon,
                  onTap: () => _openTopic(context, topic),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _openTopic(BuildContext context, _ReferenceTopic topic) {
    if (topic.themeId == 'calendar') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const CalendarTopicListScreen(),
        ),
      );
      return;
    }
    if (topic.themeId == 'issuer') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const IssuerListScreen()));
      return;
    }
    if (topic.themeId == 'country') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CountryListScreen()),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReferenceTopicListScreen(
          themeId: topic.themeId,
          themeLabel: topic.label,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferenceTopic {
  const _ReferenceTopic({
    required this.label,
    required this.themeId,
    required this.icon,
  });

  final String label;
  final String themeId;
  final IconData icon;
}
