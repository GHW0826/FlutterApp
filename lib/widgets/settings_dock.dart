import 'package:flutter/material.dart';

import '../l10n/app_text.dart';
import '../theme/theme_controller.dart';

class SettingsDock extends StatelessWidget {
  const SettingsDock({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppThemeScope.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SettingsChip(
                  keyValue: 'theme-mode-toggle',
                  icon: controller.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: controller.isDarkMode
                      ? context.tr(en: 'Dark mode', ko: '다크 모드')
                      : context.tr(en: 'Light mode', ko: '라이트 모드'),
                  subtitle: context.tr(
                    en: 'Tap to switch theme',
                    ko: '탭해서 테마 전환',
                  ),
                  onTap: controller.toggleTheme,
                ),
                const SizedBox(height: 10),
                _SettingsChip(
                  keyValue: 'language-toggle',
                  icon: Icons.translate_rounded,
                  title: controller.isKorean ? '한국어' : 'English',
                  subtitle: context.tr(
                    en: 'Tap to switch language',
                    ko: '탭해서 언어 전환',
                  ),
                  onTap: controller.toggleLanguage,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsChip extends StatelessWidget {
  const _SettingsChip({
    required this.keyValue,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String keyValue;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: title,
      hint: subtitle,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey(keyValue),
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.surfaceContainerLowest.withValues(alpha: 0.96),
                  scheme.surfaceContainerHigh.withValues(alpha: 0.96),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: scheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: scheme.primary),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
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
