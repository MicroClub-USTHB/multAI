import 'package:flutter/material.dart';
import '../../../../../core/extensions/responsive_extensions.dart';

enum DecisionStatus { approved, rejected }

class DecisionTile extends StatelessWidget {
  const DecisionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String title;
  final String subtitle;
  final DecisionStatus status;

  @override
  Widget build(BuildContext context) {
    final isApproved = status == DecisionStatus.approved;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(context.radius() / 2),
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isApproved ? Colors.green : Colors.grey.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isApproved ? Icons.check : Icons.block,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}


