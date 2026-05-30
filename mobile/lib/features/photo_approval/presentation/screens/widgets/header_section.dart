import 'package:flutter/material.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/navigation_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.hPadding()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Logo + name ────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: cs.primary,
                size: context.iconSize() * 1.2,
              ),
              SizedBox(width: context.widthCalculated(8)),
              Text(
                'MultiAi',
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppThemeColors.primaryText,
                ),
              ),
            ],
          ),

          // ── Close button ───────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: EdgeInsets.all(context.widthCalculated(6)),
              decoration: BoxDecoration(
                color: AppThemeColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: context.iconSize(),
                color: AppThemeColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
