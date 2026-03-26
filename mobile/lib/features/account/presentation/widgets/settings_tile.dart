import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/theme/theme.dart';

class SettingItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  SettingItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });
}

class SettingsTile extends StatelessWidget {
  final SettingItemData data;

  const SettingsTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: context.heightCalculated(8)),
        padding: EdgeInsets.symmetric(
          horizontal: context.widthCalculated(16),
          vertical: context.heightCalculated(14),
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: [

            // ── icon container ───────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(context.widthCalculated(8)),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(
                data.icon,
                size: context.iconSize(),
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(width: context.widthCalculated(12)),

            // ── title + subtitle ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: tt.titleMedium?.copyWith(
                      color: AppTheme.primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (data.subtitle != null) ...[
                    SizedBox(height: context.heightCalculated(2)),
                    Text(
                      data.subtitle!,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── arrow ────────────────────────────────────────────────────
            Icon(
              Icons.arrow_forward_ios,
              size: context.iconSize() * 0.7,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}