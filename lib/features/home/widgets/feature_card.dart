import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Notion-style page row — icon chip, title + subtitle, chevron.
/// Fills available height when wrapped in Expanded.
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color chipBg;
  final VoidCallback onTap;
  final bool isAccessible;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.chipBg,
    required this.onTap,
    this.isAccessible = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // Colored icon chip
            Container(
              width: isAccessible ? 48 : 44,
              height: isAccessible ? 48 : 44,
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
              ),
              child: Icon(
                icon,
                color: color,
                size: isAccessible ? 24 : 22,
              ),
            ),
            const SizedBox(width: 16),
            // Title + subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: isAccessible ? 17 : 16,
                      color: isDark ? Colors.white : const Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isAccessible ? 13 : 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right,
              size: 22,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
