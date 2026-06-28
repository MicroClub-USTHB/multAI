import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';

class ProfileSection extends StatelessWidget {
  final String name;
  final String email;
  final String membershipType;
  final String? avatarUrl;

  const ProfileSection({
    super.key,
    required this.name,
    required this.email,
    required this.membershipType,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar with amber border ───────────────────────────────────
          Container(
            width: context.widthCalculated(104),
            height: context.widthCalculated(104),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: cs.primary,
                width: context.widthCalculated(3),
              ),
            ),
            child: avatarUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 120,
                      memCacheHeight: 120,
                      placeholder: (_, _) => Center(
                        child: SizedBox(
                          width: context.widthCalculated(24),
                          height: context.widthCalculated(24),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => Icon(
                        Icons.person,
                        size: context.widthCalculated(48),
                        color: AppThemeColors.secondaryText,
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: context.widthCalculated(52),
                    backgroundColor: AppThemeColors.surface,
                    child: Icon(
                      Icons.person,
                      size: context.widthCalculated(48),
                      color: AppThemeColors.secondaryText,
                    ),
                  ),
          ),
          SizedBox(height: context.heightCalculated(16)),

          // ── Name ──────────────────────────────────────────────────────
          Text(
            name,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppThemeColors.primaryText,
            ),
          ),
          SizedBox(height: context.heightCalculated(8)),

          // ── Membership badge ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.widthCalculated(12),
              vertical: context.heightCalculated(4),
            ),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(AppThemeMetrics.radiusXl),
            ),
            child: Text(
              membershipType.toUpperCase(),
              style: tt.labelSmall?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(height: context.heightCalculated(8)),

          // ── Email ─────────────────────────────────────────────────────
          Text(
            email,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
