import 'package:flutter/material.dart';

import 'calendar_exception_list_screen.dart';
import 'calendar_list_screen.dart';
import 'calendar_set_list_screen.dart';
import 'calendar_set_member_list_screen.dart';
import 'calendar_weekend_list_screen.dart';

class CalendarTopicListScreen extends StatelessWidget {
  const CalendarTopicListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Select a topic.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            _TopicButton(
              label: 'Calendar',
              icon: Icons.calendar_month_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CalendarListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Calendar Weekend',
              icon: Icons.weekend_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CalendarWeekendListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Calendar Exception',
              icon: Icons.event_busy_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CalendarExceptionListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Calendar Set',
              icon: Icons.dynamic_form_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CalendarSetListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _TopicButton(
              label: 'Calendar Set Member',
              icon: Icons.group_work_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CalendarSetMemberListScreen(),
                  ),
                );
              },
            ),
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
