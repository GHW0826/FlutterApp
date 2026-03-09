import 'package:flutter/material.dart';

import 'dummy/dummy_topic_list_screen.dart';
import 'job_schedule/job_schedule_screen.dart';
import 'market_info/market_info_screen.dart';
import 'product/product_screen.dart';
import 'reference/reference_screen.dart';
import 'trade/trade_screen.dart';
import 'underlying/underlying_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Platform'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            const Text(
              'Select a topic.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            _TopicButton(
              label: 'Reference',
              icon: Icons.library_books_outlined,
              onTap: () =>
                  _openTopic(context, const ReferenceScreen(), 'Reference'),
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Market Information',
              icon: Icons.analytics_outlined,
              onTap: () => _openTopic(
                context,
                const MarketInfoScreen(),
                'Market Information',
              ),
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Underlying',
              icon: Icons.account_tree_outlined,
              onTap: () =>
                  _openTopic(context, const UnderlyingScreen(), 'Underlying'),
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Product',
              icon: Icons.inventory_2_outlined,
              onTap: () =>
                  _openTopic(context, const ProductScreen(), 'Product'),
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Trade',
              icon: Icons.swap_horiz,
              onTap: () => _openTopic(context, const TradeScreen(), 'Trade'),
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Curve Setting',
              icon: Icons.show_chart_outlined,
              onTap: () => _openTopic(
                context,
                const DummyTopicListScreen(
                  title: 'Curve Setting',
                  codePrefix: 'cs',
                ),
                'Curve Setting',
              ),
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Trading',
              icon: Icons.candlestick_chart_outlined,
              onTap: () => _openTopic(
                context,
                const DummyTopicListScreen(title: 'Trading', codePrefix: 'trd'),
                'Trading',
              ),
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Position Analysis',
              icon: Icons.pie_chart_outline,
              onTap: () => _openTopic(
                context,
                const DummyTopicListScreen(
                  title: 'Position Analysis',
                  codePrefix: 'pa',
                ),
                'Position Analysis',
              ),
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Settlement&Closing',
              icon: Icons.account_balance_wallet_outlined,
              onTap: () => _openTopic(
                context,
                const DummyTopicListScreen(
                  title: 'Settlement&Closing',
                  codePrefix: 'sc',
                ),
                'Settlement&Closing',
              ),
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Parameter Setting',
              icon: Icons.tune_outlined,
              onTap: () => _openTopic(
                context,
                const DummyTopicListScreen(
                  title: 'Parameter Setting',
                  codePrefix: 'ps',
                ),
                'Parameter Setting',
              ),
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Trade Report',
              icon: Icons.description_outlined,
              onTap: () => _openTopic(
                context,
                const DummyTopicListScreen(
                  title: 'Trade Report',
                  codePrefix: 'rp',
                ),
                'Trade Report',
              ),
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Job Schedule',
              icon: Icons.schedule_outlined,
              onTap: () => _openTopic(
                context,
                const JobScheduleScreen(),
                'Job Schedule',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTopic(BuildContext context, Widget screen, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => screen,
        settings: RouteSettings(name: '/$title'),
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
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
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
