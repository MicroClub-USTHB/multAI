import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/theme/theme.dart';

class InfoBanner extends StatelessWidget {
  final String message;

  const InfoBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.widthCalculated(12),
        vertical: context.heightCalculated(10),
      ),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.warningColor,
            size: context.iconSize() * 0.9,
          ),
          SizedBox(width: context.widthCalculated(8)),
          Expanded(
            child: Text(
              message,
              style: tt.labelMedium?.copyWith(
                color: AppTheme.warningColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
