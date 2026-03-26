import 'package:flutter/material.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../widgets/photo_approval/photo_approval_card.dart';
import '../widgets/photo_approval/recent_decisions_section.dart';
import '../widgets/photo_approval/header_section.dart';

class PhotoApprovalPage extends StatelessWidget {
  const PhotoApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const HeaderSection(),

            SizedBox(height: context.hPadding()),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.hPadding(),
                ),
                child: Column(
                  children: [
                    const PhotoApprovalCard(),

                    SizedBox(height: context.hPadding()),

                    const RecentDecisionsSection(),
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
