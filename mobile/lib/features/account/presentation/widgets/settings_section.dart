import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/theme/theme.dart';
import 'settings_tile.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingItemData> items;

  const SettingsSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── section title — uppercase + muted ────────────────────────────
        Text(
          title,
          style: tt.labelMedium?.copyWith(
            color: AppTheme.secondaryTextColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: context.heightCalculated(12)),

        // ── tiles ─────────────────────────────────────────────────────────
        ...items.map((e) => SettingsTile(data: e)),
      ],
    );
  }
}