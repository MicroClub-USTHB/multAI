import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class PicturesGrid extends StatelessWidget {
  final List<String> pictures;
  const PicturesGrid({required this.pictures, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double minItemWidth = 160;
    int crossAxisCount = (screenWidth / minItemWidth).floor();
    crossAxisCount = crossAxisCount.clamp(1, 6); 

    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppTheme.spacingSm,
        mainAxisSpacing: AppTheme.spacingSm,
        childAspectRatio: 1,
      ),
      itemCount: pictures.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            image: DecorationImage(
              image: AssetImage(pictures[index]),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}