import 'package:flutter/material.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class OnboardingIndicator extends StatelessWidget {
  final int currentPage;
  final int itemCount;

  const OnboardingIndicator({
    super.key,
    required this.currentPage,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        final isActive = currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.only(right: context.widthCalculated(6)),
          height: 2,
          width: isActive
              ? context.widthCalculated(28)
              : context.widthCalculated(12),
          decoration: BoxDecoration(
            color: isActive
                ? context.colors.primaryAccent
                : context.colors.subtitleText.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}
