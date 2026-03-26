import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';

class SettingItemData {
  final IconData icon;
  final String title;

  SettingItemData({
    required this.icon,
    required this.title,
  });
}

class SettingsTile extends StatelessWidget {
  final SettingItemData data;

  const SettingsTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: context.heightCalculated(10)),
      padding: EdgeInsets.symmetric(
        horizontal: context.widthCalculated(12),
        vertical: context.heightCalculated(14),
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(context.radius()),
      ),
      child: Row(
        children: [
          Icon(data.icon, size: context.iconSize()),
          SizedBox(width: context.widthCalculated(10)),
          Expanded(
            child: Text(data.title, style: tt.bodyMedium),
          ),
          Icon(Icons.arrow_forward_ios, size: context.iconSize()),
        ],
      ),
    );
  }
}