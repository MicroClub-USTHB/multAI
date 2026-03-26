import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ActiveEventsCard extends StatelessWidget {
  const ActiveEventsCard({
    super.key,
    required this.eventTitle,
    required this.eventStatus,
    required this.eventDate,
    required this.eventImage,
  });

  final String eventTitle;
  final String eventStatus;
  final String eventDate;
  final String eventImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 458,
      height: 120,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(15, 23, 42, 1).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: const Color.fromRGBO(30, 41, 59, 1), width: 1),
      ),
      child: Row(
        children: [
          // Image section
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingXs),
            child: Container(
              width: 106,
              height: 116,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                image: DecorationImage(
                  image: AssetImage(eventImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppTheme.spacingSm),

          // Info section 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                // Title 
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title
                      Expanded(
                        child: Text(
                          eventTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      ),
                      // Status 
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          eventStatus,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Date row
                Padding(
                  padding: const EdgeInsets.only(bottom: 19),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: AppTheme.spacingXs),
                      Text(
                        eventDate,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Avatar and View
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage: AssetImage("assets/images/avatar_img.png"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        "View",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}