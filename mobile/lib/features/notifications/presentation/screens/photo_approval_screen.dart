import 'package:flutter/material.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../widgets/photo_approval/photo_approval_card.dart';
import '../widgets/photo_approval/recent_decisions_section.dart';
import '../widgets/photo_approval/header_section.dart';
import '../../../../core/theme/theme.dart';

class PhotoApprovalPage extends StatelessWidget {
  const PhotoApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: context.heightCalculated(12)),

            const HeaderSection(),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.hPadding(),
                  vertical: context.heightCalculated(16),
                ),
                child: Column(
                  children: [
                    const PhotoApprovalCard(),
                    SizedBox(height: context.heightCalculated(24)),
                    const RecentDecisionsSection(),
                    SizedBox(height: context.heightCalculated(24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
