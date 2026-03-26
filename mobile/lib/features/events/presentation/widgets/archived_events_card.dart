import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ArchivedEventsCard extends StatelessWidget {
  const ArchivedEventsCard({
    super.key,
    required this.eventTitle,
    required this.eventDate,
    required this.eventImage,
  });

  final String eventTitle;
  final String eventDate;
  final String eventImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingSm),
      child: Container(
        width: 191,          
        height: 197,        
        decoration: BoxDecoration(
          color: const Color.fromRGBO(15, 23, 42, 1).withValues(alpha: 0.1), 
          borderRadius: BorderRadius.circular(AppTheme.radiusMd), // 12px
          border: Border.all(
            color: const Color.fromRGBO(30, 41, 59, 0.4).withValues(alpha: 0.4), 
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section (169 x 96)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMd),
                topRight: Radius.circular(AppTheme.radiusMd),
              ),
              child: Image.asset(
                eventImage,
                width: 189,
                height:116,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
              child: Text(
                eventTitle,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,             
                      color: const Color(0xFF94A3B8),
                    ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm), 
            // Date
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs, horizontal: AppTheme.spacingSm),
              child: Text(
                eventDate,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w400, 
                      fontSize: 13,             
                      color: const Color(0xFF64748B), 
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}