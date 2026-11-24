import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/theme.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class BackupProgressView extends StatelessWidget {
  final double percent;
  final int photoCount;

  const BackupProgressView({
    super.key,
    required this.percent,
    required this.photoCount,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: context.widthCalculated(120),
          height: context.heightCalculated(120),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: context.widthCalculated(120),
                height: context.heightCalculated(120),
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 8,
                  backgroundColor: context.colors.surface,
                  color: cs.primary,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: tt.headlineMedium?.copyWith(
                  color: context.colors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.heightCalculated(24)),
        Text(
          'Creating backup...',
          style: tt.titleMedium?.copyWith(color: context.colors.primaryText),
        ),
        SizedBox(height: context.heightCalculated(8)),
        Text(
          'Packaging $photoCount photos into ZIP',
          style: tt.bodyMedium?.copyWith(color: context.colors.secondaryText),
        ),
      ],
    );
  }
}
