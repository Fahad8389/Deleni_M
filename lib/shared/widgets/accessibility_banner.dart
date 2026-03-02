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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.15),
        border: Border(
          bottom: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.accessible, color: AppColors.gold, size: 20),
          const SizedBox(width: 8),
          Text(
            l10n.accessibilityEnabled,
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
              fontSize: isAccessible ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
