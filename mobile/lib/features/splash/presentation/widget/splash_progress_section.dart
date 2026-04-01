import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/theme.dart';

class SplashProgressSection extends StatelessWidget {
  const SplashProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'INITIALIZING ENGINE',
              style: TextStyle(
                letterSpacing: 2.4,
                fontSize: 16,
                color: AppTheme.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '42%',
              style: TextStyle(fontSize: 12, color: AppTheme.slateGray),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        const LinearProgressIndicator(value: 0.42, minHeight: 2),
        const SizedBox(height: AppTheme.spacingLg),
        Row(
          children: [
            Expanded(child: _buildCard(Icons.photo_outlined)),
            const SizedBox(width: 8),
            Expanded(child: _buildCard(Icons.videocam_outlined)),
            const SizedBox(width: 8),
            Expanded(child: _buildCard(Icons.face_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(IconData icon) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Icon(icon, color: AppTheme.gold.withOpacity(0.4), size: 24),
    );
  }
}
