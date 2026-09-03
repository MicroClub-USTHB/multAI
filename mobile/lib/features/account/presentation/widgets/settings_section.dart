import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import 'settings_tile.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingItemData> items;

  const SettingsSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Title ───────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(bottom: context.heightCalculated(8)),
          child: Text(
            title.toUpperCase(),
            style: tt.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),

        // ── Tiles ───────────────────────────────────────────────────────
        ...items.map((item) => SettingsTile(data: item)),
      ],
    );
  }
}
