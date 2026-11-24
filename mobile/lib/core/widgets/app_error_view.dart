import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';
import '../extensions/responsive_extensions.dart';
import '../theme/app_theme_metrics.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class ErrorStateView extends StatelessWidget {
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData illustration;

  const ErrorStateView({
    super.key,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.illustration = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          context.widthCalculated(AppThemeMetrics.spacingXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              illustration,
              size: context.iconSize() * 3,
              color: context.colors.secondaryText,
            ),
            SizedBox(
              height: context.heightCalculated(AppThemeMetrics.spacingLg),
            ),
            Text(
              title,
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: context.heightCalculated(AppThemeMetrics.spacingSm),
            ),
            Text(
              description,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(
                height: context.heightCalculated(AppThemeMetrics.spacingXl),
              ),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(
                  actionLabel == 'Retry' ? Icons.refresh : Icons.login_rounded,
                ),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  foregroundColor: context.colors.primaryText,
                  backgroundColor: context.colors.primaryAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeMetrics.radiusSm,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
