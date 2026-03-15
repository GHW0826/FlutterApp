import 'package:flutter/material.dart';

import '../l10n/app_text.dart';
import '../widgets/topic_hub_screen.dart';
import 'dummy/dummy_topic_list_screen.dart';
import 'job_schedule/job_schedule_screen.dart';
import 'market_info/market_info_screen.dart';
import 'product/product_screen.dart';
import 'reference/reference_screen.dart';
import 'trade/trade_screen.dart';
import 'underlying/underlying_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TopicHubScreen(
      title: context.tr(en: 'Financial Platform', ko: '금융 플랫폼'),
      eyebrow: context.tr(en: 'Operations Console', ko: '운영 콘솔'),
      headline: context.tr(
        en: 'Move through the platform without fighting dense menus.',
        ko: '복잡한 메뉴를 헤매지 않고 플랫폼을 바로 탐색하세요.',
      ),
      description: context.tr(
        en: 'Core workflows are grouped into focused modules so the first screen reads like a dashboard instead of a raw admin list.',
        ko: '핵심 업무를 모듈 단위로 묶어 첫 화면이 단순 목록이 아니라 대시보드처럼 읽히도록 구성했습니다.',
      ),
      items: [
        TopicHubItem(
          label: context.tr(en: 'Reference', ko: '기준 정보'),
          icon: Icons.library_books_outlined,
          description: context.tr(
            en: 'Country, currency, vendor, issuer, and calendar data.',
            ko: '국가, 통화, 벤더, 발행기관, 캘린더 기준정보를 관리합니다.',
          ),
          accentColor: const Color(0xFF0F766E),
          onTap: () => _openTopic(
            context,
            const ReferenceScreen(),
            context.tr(en: 'Reference', ko: '기준 정보'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Market Information', ko: '시장 정보'),
          icon: Icons.analytics_outlined,
          description: context.tr(
            en: 'Manage market structures, curves, and supporting data.',
            ko: '시장 구조, 커브, 보조 데이터를 관리합니다.',
          ),
          accentColor: const Color(0xFF1D4ED8),
          onTap: () => _openTopic(
            context,
            const MarketInfoScreen(),
            context.tr(en: 'Market Information', ko: '시장 정보'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Underlying', ko: '기초자산'),
          icon: Icons.account_tree_outlined,
          description: context.tr(
            en: 'Browse underlying asset classes and theme lists.',
            ko: '기초자산 유형별 목록과 테마를 탐색합니다.',
          ),
          accentColor: const Color(0xFF7C3AED),
          onTap: () => _openTopic(
            context,
            const UnderlyingScreen(),
            context.tr(en: 'Underlying', ko: '기초자산'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Product', ko: '상품'),
          icon: Icons.inventory_2_outlined,
          description: context.tr(
            en: 'Create and review product definitions.',
            ko: '상품 정의를 생성하고 검토합니다.',
          ),
          accentColor: const Color(0xFFB45309),
          onTap: () => _openTopic(
            context,
            const ProductScreen(),
            context.tr(en: 'Product', ko: '상품'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Trade', ko: '거래'),
          icon: Icons.swap_horiz_rounded,
          description: context.tr(
            en: 'Inspect trade records and mock trade workflows.',
            ko: '거래 내역과 테스트용 거래 흐름을 확인합니다.',
          ),
          accentColor: const Color(0xFFBE123C),
          onTap: () => _openTopic(
            context,
            const TradeScreen(),
            context.tr(en: 'Trade', ko: '거래'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Curve Setting', ko: '커브 설정'),
          icon: Icons.show_chart_outlined,
          description: context.tr(
            en: 'Placeholder module for curve setup workflows.',
            ko: '커브 설정 워크플로우용 placeholder 모듈입니다.',
          ),
          accentColor: const Color(0xFF0F766E),
          onTap: () => _openTopic(
            context,
            DummyTopicListScreen(
              title: context.tr(en: 'Curve Setting', ko: '커브 설정'),
              codePrefix: 'cs',
            ),
            context.tr(en: 'Curve Setting', ko: '커브 설정'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Trading', ko: '트레이딩'),
          icon: Icons.candlestick_chart_outlined,
          description: context.tr(
            en: 'Quick access entry point for trading tools.',
            ko: '트레이딩 도구로 빠르게 진입합니다.',
          ),
          accentColor: const Color(0xFF1E40AF),
          onTap: () => _openTopic(
            context,
            DummyTopicListScreen(
              title: context.tr(en: 'Trading', ko: '트레이딩'),
              codePrefix: 'trd',
            ),
            context.tr(en: 'Trading', ko: '트레이딩'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Position Analysis', ko: '포지션 분석'),
          icon: Icons.pie_chart_outline_rounded,
          description: context.tr(
            en: 'Portfolio and exposure analysis placeholders.',
            ko: '포트폴리오와 익스포저 분석용 placeholder입니다.',
          ),
          accentColor: const Color(0xFF9333EA),
          onTap: () => _openTopic(
            context,
            DummyTopicListScreen(
              title: context.tr(en: 'Position Analysis', ko: '포지션 분석'),
              codePrefix: 'pa',
            ),
            context.tr(en: 'Position Analysis', ko: '포지션 분석'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Settlement & Closing', ko: '결제 및 마감'),
          icon: Icons.account_balance_wallet_outlined,
          description: context.tr(
            en: 'Settlement operations and end-of-day routines.',
            ko: '결제 운영과 일마감 업무를 다룹니다.',
          ),
          accentColor: const Color(0xFF0F766E),
          onTap: () => _openTopic(
            context,
            DummyTopicListScreen(
              title: context.tr(en: 'Settlement & Closing', ko: '결제 및 마감'),
              codePrefix: 'sc',
            ),
            context.tr(en: 'Settlement & Closing', ko: '결제 및 마감'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Parameter Setting', ko: '파라미터 설정'),
          icon: Icons.tune_outlined,
          description: context.tr(
            en: 'Operational parameters and system configuration.',
            ko: '운영 파라미터와 시스템 설정을 관리합니다.',
          ),
          accentColor: const Color(0xFFEA580C),
          onTap: () => _openTopic(
            context,
            DummyTopicListScreen(
              title: context.tr(en: 'Parameter Setting', ko: '파라미터 설정'),
              codePrefix: 'ps',
            ),
            context.tr(en: 'Parameter Setting', ko: '파라미터 설정'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Trade Report', ko: '거래 리포트'),
          icon: Icons.description_outlined,
          description: context.tr(
            en: 'Reporting entry point for trade outputs.',
            ko: '거래 리포트 진입 화면입니다.',
          ),
          accentColor: const Color(0xFF0F766E),
          onTap: () => _openTopic(
            context,
            DummyTopicListScreen(
              title: context.tr(en: 'Trade Report', ko: '거래 리포트'),
              codePrefix: 'rp',
            ),
            context.tr(en: 'Trade Report', ko: '거래 리포트'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Job Schedule', ko: '작업 스케줄'),
          icon: Icons.schedule_outlined,
          description: context.tr(
            en: 'Batch schedule lists and operational jobs.',
            ko: '배치 스케줄과 운영 작업을 관리합니다.',
          ),
          accentColor: const Color(0xFF0369A1),
          onTap: () => _openTopic(
            context,
            const JobScheduleScreen(),
            context.tr(en: 'Job Schedule', ko: '작업 스케줄'),
          ),
        ),
      ],
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
