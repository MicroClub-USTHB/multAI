import 'package:flutter/material.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/theme.dart';


class PhotoStackImage extends StatelessWidget {
  const PhotoStackImage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Stack(
        children: [
          // ── Group photo ────────────────────────────────────────────────
          Image.asset(
            'assets/images/group.jpg',
            width: double.infinity,
            height: context.heightCalculated(220),
            fit: BoxFit.cover,
            errorBuilder: (context, error, _) => Container(
              width: double.infinity,
              height: context.heightCalculated(220),
              color: AppTheme.surfaceColor,
              child: Icon(
                Icons.image_outlined,
                size: context.iconSize() * 2,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),

          // ── YOU label ─────────────────────────────────────────────────
          Positioned(
            bottom: context.heightCalculated(12),
            left: context.widthCalculated(12),
            child: _AvatarLabel(
              label: 'YOU',
              color: cs.primary,
              textColor: cs.onPrimary,
            ),
          ),

          // ── Other avatars ─────────────────────────────────────────────
          Positioned(
            bottom: context.heightCalculated(12),
            left: context.widthCalculated(60),
            child: _AvatarLabel(
              label: '',
              color: AppTheme.secondaryTextColor.withValues(alpha: 0.6),
              textColor: AppTheme.primaryTextColor,
            ),
          ),
          Positioned(
            bottom: context.heightCalculated(12),
            left: context.widthCalculated(96),
            child: _AvatarLabel(
              label: '',
              color: AppTheme.secondaryTextColor.withValues(alpha: 0.4),
              textColor: AppTheme.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarLabel extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _AvatarLabel({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.widthCalculated(36),
      height: context.widthCalculated(36),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.backgroundColor, width: 2),
      ),
      alignment: Alignment.center,
      child: label.isNotEmpty
          ? Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: context.widthCalculated(9),
              ),
            )
          : Icon(
              Icons.person,
              size: context.widthCalculated(18),
              color: textColor,
            ),
    );
  }
}
