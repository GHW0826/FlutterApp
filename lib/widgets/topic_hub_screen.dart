import 'package:flutter/material.dart';

import '../l10n/app_text.dart';

class TopicHubItem {
  const TopicHubItem({
    required this.label,
    required this.icon,
    required this.description,
    required this.onTap,
    this.accentColor,
  });

  final String label;
  final IconData icon;
  final String description;
  final VoidCallback onTap;
  final Color? accentColor;
}

class TopicHubScreen extends StatelessWidget {
  const TopicHubScreen({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.headline,
    required this.description,
    required this.items,
  });

  final String title;
  final String eyebrow;
  final String headline;
  final String description;
  final List<TopicHubItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 1200 ? 40.0 : 24.0;
          final cardWidth = _resolveCardWidth(constraints.maxWidth);

          return ListView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              24,
              horizontalPadding,
              120,
            ),
            children: [
              _HubHeader(
                eyebrow: eyebrow,
                headline: headline,
                description: description,
                itemCount: items.length,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  context.tr(en: 'Workspace modules', ko: '워크스페이스 모듈'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: items.map((item) {
                  return SizedBox(
                    width: cardWidth,
                    child: _HubTopicCard(item: item),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  double _resolveCardWidth(double maxWidth) {
    if (maxWidth >= 1200) {
      return (maxWidth - 80 - 32) / 3;
    }
    if (maxWidth >= 760) {
      return (maxWidth - 48 - 16) / 2;
    }
    return maxWidth - 48;
  }
}

class _HubHeader extends StatelessWidget {
  const _HubHeader({
    required this.eyebrow,
    required this.headline,
    required this.description,
    required this.itemCount,
  });

  final String eyebrow;
  final String headline;
  final String description;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.18),
            scheme.tertiary.withValues(alpha: 0.16),
            scheme.secondary.withValues(alpha: 0.14),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                eyebrow.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(headline, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _HeaderChip(
                  icon: Icons.grid_view_rounded,
                  label: context.tr(
                    en: '$itemCount modules',
                    ko: '$itemCount개 모듈',
                  ),
                ),
                _HeaderChip(
                  icon: Icons.design_services_rounded,
                  label: context.tr(
                    en: 'Refined visual system',
                    ko: '정리된 비주얼 시스템',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _HubTopicCard extends StatelessWidget {
  const _HubTopicCard({required this.item});

  final TopicHubItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = item.accentColor ?? scheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.outlineVariant),
            gradient: LinearGradient(
              colors: [
                scheme.surfaceContainerLowest,
                accent.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 160),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(item.icon, color: accent),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_outward_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
