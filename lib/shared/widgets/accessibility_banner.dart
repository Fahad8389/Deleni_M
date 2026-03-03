import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';

class AccessibilityBanner extends ConsumerWidget {
  const AccessibilityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isAccessible = settings.accessibilityMode;
    if (!isAccessible) return const SizedBox.shrink();

    final l10n = AppLocalizations(settings.language);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.yellowBg,
        border: Border(
          bottom: BorderSide(color: AppColors.yellow.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.accessible, color: AppColors.yellow, size: 18),
          const SizedBox(width: 8),
          Text(
            l10n.accessibilityEnabled,
            style: TextStyle(
              color: AppColors.yellow,
              fontWeight: FontWeight.w500,
              fontSize: isAccessible ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
