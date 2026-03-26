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
        Text(title, style: tt.titleMedium),
        SizedBox(height: context.heightCalculated(8)),

        ...items.map((e) => SettingsTile(data: e)), // ✅ works now
      ],
    );
  }
}
