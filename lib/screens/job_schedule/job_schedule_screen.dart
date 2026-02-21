import 'package:flutter/material.dart';
import 'job_placeholder_screen.dart';
import 'job_schedule_list_screen.dart';

/// Job Schedule main topic screen.
class JobScheduleScreen extends StatelessWidget {
  const JobScheduleScreen({super.key});

  static const _topics = [
    ('JobSchdule', Icons.list_alt_outlined, true),
    ('Interface Job', Icons.settings_ethernet, false),
    ('Business Closing Job', Icons.business_center_outlined, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Schedule'),
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
              'Select a topic.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ..._topics.map((e) {
              final (label, icon, isList) = e;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TopicButton(
                  label: label,
                  icon: icon,
                  onTap: () {
                    if (isList) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const JobScheduleListScreen(),
                        ),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => JobPlaceholderScreen(title: label),
                      ),
                    );
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
