import 'package:flutter/material.dart';

import '../../l10n/app_text.dart';
import '../../widgets/topic_hub_screen.dart';
import 'market_management_screen.dart';
import 'market_placeholder_screen.dart';

class MarketInfoScreen extends StatelessWidget {
  const MarketInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TopicHubScreen(
      title: context.tr(en: 'Market Information', ko: '시장 정보'),
      eyebrow: context.tr(en: 'Market Data', ko: '시장 데이터'),
      headline: context.tr(
        en: 'Organize pricing and curve workflows in one place.',
        ko: '가격과 커브 관련 업무를 한 곳에서 정리합니다.',
      ),
      description: context.tr(
        en: 'This area groups the screens used to manage market structures, history, derived shapes, and calculation-oriented placeholders.',
        ko: '시장 구조, 이력, 파생 형태, 계산 관련 placeholder 화면을 이 영역에서 묶어 관리합니다.',
      ),
      items: [
        TopicHubItem(
          label: context.tr(en: 'Market Management', ko: '시장 관리'),
          icon: Icons.tune_rounded,
          description: context.tr(
            en: 'Working market screens including curve management.',
            ko: '커브 관리를 포함한 실제 시장 관리 화면입니다.',
          ),
          accentColor: const Color(0xFF0F766E),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MarketManagementScreen(),
            ),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Market History', ko: '시장 이력'),
          icon: Icons.history_rounded,
          description: context.tr(
            en: 'Placeholder for historical market datasets.',
            ko: '시장 이력 데이터용 placeholder입니다.',
          ),
          accentColor: const Color(0xFF1D4ED8),
          onTap: () => _openPlaceholder(
            context,
            context.tr(en: 'Market History', ko: '시장 이력'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Market Shape', ko: '시장 형태'),
          icon: Icons.show_chart_rounded,
          description: context.tr(
            en: 'Placeholder for shape-related analytics.',
            ko: '시장 형태 분석용 placeholder입니다.',
          ),
          accentColor: const Color(0xFF7C3AED),
          onTap: () => _openPlaceholder(
            context,
            context.tr(en: 'Market Shape', ko: '시장 형태'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Market Calculation', ko: '시장 계산'),
          icon: Icons.calculate_rounded,
          description: context.tr(
            en: 'Placeholder for calculation pipelines and results.',
            ko: '시장 계산 파이프라인과 결과용 placeholder입니다.',
          ),
          accentColor: const Color(0xFFB45309),
          onTap: () => _openPlaceholder(
            context,
            context.tr(en: 'Market Calculation', ko: '시장 계산'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Market Change', ko: '시장 변동'),
          icon: Icons.trending_up_rounded,
          description: context.tr(
            en: 'Placeholder for market change monitoring.',
            ko: '시장 변동 모니터링용 placeholder입니다.',
          ),
          accentColor: const Color(0xFFBE123C),
          onTap: () => _openPlaceholder(
            context,
            context.tr(en: 'Market Change', ko: '시장 변동'),
          ),
        ),
      ],
    );
  }

  void _openPlaceholder(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MarketPlaceholderScreen(title: title),
      ),
    );
  }
}
