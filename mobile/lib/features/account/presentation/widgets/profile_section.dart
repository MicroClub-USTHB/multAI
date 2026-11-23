import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';

class ProfileSection extends StatelessWidget {
  final String name;
  final String email;
  final String membershipType;
  final String? avatarUrl;
  final String? avatarCacheKey;
  final Map<String, String>? avatarHeaders;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onEditName;
  final bool isUploading;

  const ProfileSection({
    super.key,
    required this.name,
    required this.email,
    required this.membershipType,
    this.avatarUrl,
    this.avatarCacheKey,
    this.avatarHeaders,
    this.onAvatarTap,
    this.onEditName,
    this.isUploading = false,
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
          GestureDetector(
            onTap: isUploading ? null : onAvatarTap,
            child: Stack(
              children: [
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
                          child: ExtendedImage.network(
                            avatarUrl!,
                            headers: avatarHeaders,
                            cacheKey: avatarCacheKey,
                            fit: BoxFit.cover,
                            cache: true,
                            cacheWidth: 512,
                            cacheHeight: 512,
                            loadStateChanged: (state) {
                              switch (state.extendedImageLoadState) {
                                case LoadState.loading:
                                  return Center(
                                    child: SizedBox(
                                      width: context.widthCalculated(24),
                                      height: context.widthCalculated(24),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: cs.primary,
                                      ),
                                    ),
                                  );
                                case LoadState.failed:
                                  return Icon(
                                    Icons.person,
                                    size: context.widthCalculated(48),
                                    color: AppThemeColors.secondaryText,
                                  );
                                case LoadState.completed:
                                  return null;
                              }
                            },
                          ),
                        )
                      : CircleAvatar(
                          radius: context.widthCalculated(52),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          child: Icon(
                            Icons.person,
                            size: context.widthCalculated(48),
                            color: AppThemeColors.secondaryText,
                          ),
                        ),
                ),
                if (isUploading)
                  Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: cs.primary,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(context.widthCalculated(4)),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: context.widthCalculated(18),
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.heightCalculated(16)),

          // ── Name ──────────────────────────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (onEditName != null) ...[
                SizedBox(width: context.widthCalculated(6)),
                GestureDetector(
                  onTap: onEditName,
                  child: Icon(
                    Icons.edit_outlined,
                    size: context.iconSize() * 0.8,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
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
