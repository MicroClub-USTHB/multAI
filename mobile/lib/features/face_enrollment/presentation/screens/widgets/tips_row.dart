import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';
 
class TipsRow extends StatelessWidget {
  const TipsRow({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: context.widthCalculated(8),
      runSpacing: context.heightCalculated(8),
      children: const [
        _TipChip(icon: Icons.blur_off_outlined, label: 'No Blur'),
        _TipChip(icon: Icons.face_outlined, label: 'Single Face Only'),
        _TipChip(icon: Icons.light_mode_outlined, label: 'Good Lighting'),
      ],
    );
  }
}
 
class _TipChip extends StatelessWidget {
  final IconData icon;
  final String label;
 
  const _TipChip({required this.icon, required this.label});
 
  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
 
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.widthCalculated(12),
        vertical: context.heightCalculated(6),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.inputBorderColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.iconSize(), color: cs.onSurface),
          SizedBox(width: context.widthCalculated(4)),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}