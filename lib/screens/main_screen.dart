import 'package:flutter/material.dart';
import 'product/product_screen.dart';
import 'trade/trade_screen.dart';
import 'market_info/market_info_screen.dart';
import 'underlying/underlying_screen.dart';
import 'job_schedule/job_schedule_screen.dart';

/// 금융 솔루션 메인 화면 - 주제별 진입 버튼
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('금융 솔루션'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Text(
              '주제를 선택하세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            _TopicButton(
              label: 'Product',
              icon: Icons.inventory_2_outlined,
              onTap: () => _openTopic(context, const ProductScreen(), 'Product'),
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Trade',
              icon: Icons.swap_horiz,
              onTap: () => _openTopic(context, const TradeScreen(), 'Trade'),
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
              onTap: () => _openTopic(
                context,
                const UnderlyingScreen(),
                'Underlying',
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
