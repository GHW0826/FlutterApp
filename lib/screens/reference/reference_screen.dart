import 'package:flutter/material.dart';

import '../../l10n/app_text.dart';
import '../../widgets/topic_hub_screen.dart';
import 'calendar_topic_list_screen.dart';
import 'country_list_screen.dart';
import 'issuer_list_screen.dart';
import 'reference_topic_list_screen.dart';

class ReferenceScreen extends StatelessWidget {
  const ReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TopicHubScreen(
      title: context.tr(en: 'Reference', ko: '기준 정보'),
      eyebrow: context.tr(en: 'Master Data', ko: '마스터 데이터'),
      headline: context.tr(
        en: 'Foundational datasets live here.',
        ko: '기본 기준 데이터가 이 영역에 모여 있습니다.',
      ),
      description: context.tr(
        en: 'Reference modules collect the shared entities used throughout the platform, from geography and issuers to vendor and calendar setup.',
        ko: '국가, 발행기관, 벤더, 캘린더처럼 플랫폼 전반에서 공통으로 쓰는 기준 엔티티를 관리합니다.',
      ),
      items: [
        TopicHubItem(
          label: context.tr(en: 'Country', ko: '국가'),
          icon: Icons.public_outlined,
          description: context.tr(
            en: 'Country codes, names, timezones, and activation state.',
            ko: '국가 코드, 명칭, 타임존, 활성 상태를 관리합니다.',
          ),
          accentColor: const Color(0xFF0F766E),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CountryListScreen()),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Currency', ko: '통화'),
          icon: Icons.attach_money_outlined,
          description: context.tr(
            en: 'Currency master data and related reference items.',
            ko: '통화 마스터 데이터와 관련 기준 정보를 관리합니다.',
          ),
          accentColor: const Color(0xFFB45309),
          onTap: () => _openReferenceTopic(
            context,
            'currency',
            context.tr(en: 'Currency', ko: '통화'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Vendor', ko: '벤더'),
          icon: Icons.store_outlined,
          description: context.tr(
            en: 'Vendor definitions and upstream market sources.',
            ko: '벤더 정의와 외부 시장 데이터 소스를 관리합니다.',
          ),
          accentColor: const Color(0xFF1D4ED8),
          onTap: () => _openReferenceTopic(
            context,
            'vendor',
            context.tr(en: 'Vendor', ko: '벤더'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Issuer', ko: '발행기관'),
          icon: Icons.account_balance_outlined,
          description: context.tr(
            en: 'Issuer profile maintenance and review flows.',
            ko: '발행기관 프로필을 등록하고 검토합니다.',
          ),
          accentColor: const Color(0xFF7C3AED),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const IssuerListScreen()),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Calendar', ko: '캘린더'),
          icon: Icons.calendar_month_outlined,
          description: context.tr(
            en: 'Holiday, weekend, exception, and set management.',
            ko: '휴일, 주말, 예외일, 캘린더 세트를 관리합니다.',
          ),
          accentColor: const Color(0xFF0369A1),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const CalendarTopicListScreen(),
            ),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Exchange', ko: '거래소'),
          icon: Icons.candlestick_chart_outlined,
          description: context.tr(
            en: 'Placeholder reference space for exchange metadata.',
            ko: '거래소 메타데이터용 placeholder 영역입니다.',
          ),
          accentColor: const Color(0xFFEA580C),
          onTap: () => _openReferenceTopic(
            context,
            'exchange',
            context.tr(en: 'Exchange', ko: '거래소'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Counterparty', ko: '거래상대방'),
          icon: Icons.handshake_outlined,
          description: context.tr(
            en: 'Counterparty reference entities and master settings.',
            ko: '거래상대방 기준 엔티티와 마스터 설정을 관리합니다.',
          ),
          accentColor: const Color(0xFFBE123C),
          onTap: () => _openReferenceTopic(
            context,
            'counterparty',
            context.tr(en: 'Counterparty', ko: '거래상대방'),
          ),
        ),
      ],
    );
  }

  void _openReferenceTopic(
    BuildContext context,
    String themeId,
    String themeLabel,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ReferenceTopicListScreen(themeId: themeId, themeLabel: themeLabel),
      ),
    );
  }
}
