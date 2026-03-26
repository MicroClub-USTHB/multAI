import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';
import '../widgets/active_events_card.dart';
import '../widgets/archived_events_card.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - AppTheme.spacingMd * 2;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "MultiAi Events",
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: AppTheme.accentColor),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingLg),
            child: GestureDetector(
              onTap: () {
                // notification page
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_none,
                    color: AppTheme.secondaryTextColor,
                    size: 25,
                  ),
                  Positioned(
                    top: 1,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        border: Border.all(
                          color: AppTheme.backgroundColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Container
              Container(
                width: containerWidth,
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  color: AppTheme.formCardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: AppTheme.borderColor.withValues(alpha: 26),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "Join New Event",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: AppTheme.primaryTextColor),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    // Subtitle
                    Text(
                      "Have an invite? Enter the link to participate.",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    // TextField
                    TextField(
                      decoration: InputDecoration(
                        hintText: "https://multiai.app/e/...",
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm),
                          ),
                        ),
                        child: Text(
                          "Join Event",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppTheme.primaryTextColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXs, vertical: AppTheme.spacingXl),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            // Title
                            Text(
                              "Active Events",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontSize: 20,
                                  ),
                            ),
                          ],
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withAlpha(26), 
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Text(
                            "3 Ongoing",
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.33,
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // active events section
                  ActiveEventsCard(
                    eventDate: "Oct 24, 2024", 
                    eventTitle: 'AI Innovation Summit 2024', 
                    eventStatus: 'LIVE', 
                    eventImage: 'assets/images/event_image1.png',
                  ),

                  SizedBox(height: AppTheme.spacingLg),

                  ActiveEventsCard(
                    eventDate: "Oct 28, 2024", 
                    eventTitle: 'Digital Art Showcase', 
                    eventStatus: 'Soon', 
                    eventImage: 'assets/images/event_image2.png',
                  ),
                ],
              ),

              SizedBox(height: AppTheme.spacingXl),

              Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.archive_rounded),

                      const SizedBox(width: AppTheme.spacingSm),
                      // Title
                      Text(
                        "Archived Events",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 20,
                            ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.spacingLg),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ArchivedEventsCard(
                          eventTitle: 'MultiAi Workshop',
                          eventDate: 'Sep 12, 2024',
                          eventImage: 'assets/images/archived_event_img1.png',
                        ),

                        ArchivedEventsCard(
                          eventTitle: 'Founder Meetup',
                          eventDate: 'Aug 30, 2024',
                          eventImage: 'assets/images/achived_event_img2.png',
                        ),

                        ArchivedEventsCard(
                          eventTitle: 'MultiAi Workshop',
                          eventDate: 'Sep 12, 2024',
                          eventImage: 'assets/images/archived_event_img1.png',
                        ),

                        ArchivedEventsCard(
                          eventTitle: 'MultiAi Workshop',
                          eventDate: 'Sep 12, 2024',
                          eventImage: 'assets/images/archived_event_img1.png',
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

