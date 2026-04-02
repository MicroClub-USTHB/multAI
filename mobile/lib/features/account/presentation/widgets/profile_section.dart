import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/theme/theme.dart';

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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: cs.primary,
                width: context.widthCalculated(3),
              ),
            ),
            child: CircleAvatar(
              radius: context.widthCalculated(52),
              backgroundColor: AppTheme.surfaceColor,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null
                  ? Icon(
                      Icons.person,
                      size: context.widthCalculated(48),
                      color: AppTheme.secondaryTextColor,
                    )
                  : null,
            ),
          ),
          SizedBox(height: context.heightCalculated(16)),

          // ── Name ──────────────────────────────────────────────────────
          Text(
            name,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
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
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
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
