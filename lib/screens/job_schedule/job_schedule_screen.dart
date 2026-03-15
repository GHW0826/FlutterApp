import 'package:flutter/material.dart';

import '../../l10n/app_text.dart';
import '../../widgets/topic_hub_screen.dart';
import 'job_placeholder_screen.dart';
import 'job_schedule_list_screen.dart';

class JobScheduleScreen extends StatelessWidget {
  const JobScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TopicHubScreen(
      title: context.tr(en: 'Job Schedule', ko: '작업 스케줄'),
      eyebrow: context.tr(en: 'Batch Operations', ko: '배치 운영'),
      headline: context.tr(
        en: 'Operational jobs are grouped by the way teams actually use them.',
        ko: '운영 작업을 실제 업무 흐름 기준으로 묶었습니다.',
      ),
      description: context.tr(
        en: 'The main schedule list stays prominent, while related placeholder areas remain visible without crowding the screen.',
        ko: '메인 스케줄 목록을 중심에 두고 관련 placeholder 영역도 과밀하지 않게 함께 보여줍니다.',
      ),
      items: [
        TopicHubItem(
          label: context.tr(en: 'Job Schedule', ko: '작업 스케줄'),
          icon: Icons.list_alt_outlined,
          description: context.tr(
            en: 'View and maintain scheduled jobs.',
            ko: '스케줄된 작업을 조회하고 관리합니다.',
          ),
          accentColor: const Color(0xFF0F766E),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const JobScheduleListScreen(),
            ),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Interface Job', ko: '인터페이스 작업'),
          icon: Icons.settings_ethernet_rounded,
          description: context.tr(
            en: 'Placeholder for interface-oriented batch jobs.',
            ko: '인터페이스 배치 작업용 placeholder입니다.',
          ),
          accentColor: const Color(0xFF1D4ED8),
          onTap: () => _openPlaceholder(
            context,
            context.tr(en: 'Interface Job', ko: '인터페이스 작업'),
          ),
        ),
        TopicHubItem(
          label: context.tr(en: 'Business Closing Job', ko: '업무 마감 작업'),
          icon: Icons.business_center_outlined,
          description: context.tr(
            en: 'Placeholder for end-of-day and closing tasks.',
            ko: '일마감과 마감 작업용 placeholder입니다.',
          ),
          accentColor: const Color(0xFFB45309),
          onTap: () => _openPlaceholder(
            context,
            context.tr(en: 'Business Closing Job', ko: '업무 마감 작업'),
          ),
        ),
      ],
    );
  }

  void _openPlaceholder(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobPlaceholderScreen(title: title),
      ),
    );
  }
}
