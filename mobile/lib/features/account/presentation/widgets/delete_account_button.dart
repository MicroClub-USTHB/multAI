import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import 'package:multai_mobile/l10n/app_localizations.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class DeleteAccountButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DeleteAccountButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return SizedBox(
      width: double.infinity,
      height: context.heightCalculated(52),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: context.colors.error.withValues(alpha: 0.1),
          side: BorderSide(color: context.colors.error.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              color: context.colors.error,
              size: context.iconSize(),
            ),
            SizedBox(width: context.widthCalculated(8)),
            Text(
              AppLocalizations.of(context)!.deleteAccount,
              style: tt.titleMedium?.copyWith(
                color: context.colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
