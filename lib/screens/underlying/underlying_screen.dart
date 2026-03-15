import 'package:flutter/material.dart';

import '../../l10n/app_text.dart';
import '../../widgets/topic_hub_screen.dart';
import 'underlying_theme_list_screen.dart';

class UnderlyingScreen extends StatelessWidget {
  const UnderlyingScreen({super.key});

  static const _topics = [
    _UnderlyingTopic(
      themeId: 'bond',
      labelEn: 'Bond',
      labelKo: '채권',
      icon: Icons.savings_outlined,
      accent: Color(0xFF0F766E),
    ),
    _UnderlyingTopic(
      themeId: 'stock',
      labelEn: 'Stock',
      labelKo: '주식',
      icon: Icons.candlestick_chart_rounded,
      accent: Color(0xFF1D4ED8),
    ),
    _UnderlyingTopic(
      themeId: 'commodity',
      labelEn: 'Commodity',
      labelKo: '상품',
      icon: Icons.diamond_outlined,
      accent: Color(0xFFB45309),
    ),
    _UnderlyingTopic(
      themeId: 'rates_index',
      labelEn: 'Rates Index',
      labelKo: '금리 지수',
      icon: Icons.bar_chart_rounded,
      accent: Color(0xFF7C3AED),
    ),
    _UnderlyingTopic(
      themeId: 'currency_pair',
      labelEn: 'Currency Pair',
      labelKo: '통화 페어',
      icon: Icons.paid_outlined,
      accent: Color(0xFF0369A1),
    ),
    _UnderlyingTopic(
      themeId: 'credit',
      labelEn: 'Credit',
      labelKo: '신용',
      icon: Icons.credit_card_outlined,
      accent: Color(0xFFBE123C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return TopicHubScreen(
      title: context.tr(en: 'Underlying', ko: '기초자산'),
      eyebrow: context.tr(en: 'Asset Universe', ko: '자산 유니버스'),
      headline: context.tr(
        en: 'Start from the asset class, then drill into the theme list.',
        ko: '자산군에서 시작해 필요한 테마 목록으로 바로 이동합니다.',
      ),
      description: context.tr(
        en: 'Underlying modules are grouped by instrument family so the next screen is always scoped to the data domain you actually want.',
        ko: '기초자산 모듈을 상품군 단위로 묶어 원하는 데이터 도메인으로 바로 좁혀갈 수 있습니다.',
      ),
      items: _topics.map((topic) {
        final label = context.tr(en: topic.labelEn, ko: topic.labelKo);
        return TopicHubItem(
          label: label,
          icon: topic.icon,
          description: context.tr(
            en: 'Open the ${topic.labelEn} underlying list and related records.',
            ko: '$label 기초자산 목록과 관련 데이터를 확인합니다.',
          ),
          accentColor: topic.accent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => UnderlyingThemeListScreen(
                themeId: topic.themeId,
                themeLabel: label,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _UnderlyingTopic {
  const _UnderlyingTopic({
    required this.themeId,
    required this.labelEn,
    required this.labelKo,
    required this.icon,
    required this.accent,
  });

  final String themeId;
  final String labelEn;
  final String labelKo;
  final IconData icon;
  final Color accent;
}
