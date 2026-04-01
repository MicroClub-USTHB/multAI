import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../di/injection_container.dart' as di;

import '../bloc/events_bloc.dart';
import '../widgets/active_events_card.dart';
import '../widgets/archived_events_card.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _eventCodeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _eventCodeController.dispose();
    super.dispose();
  }

  // Extracts event code from either a full URL or a bare code
  String _parseEventCode(String input) {
    final trimmed = input.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return trimmed;
  }

  // Validator for the event code field
  String? _validateEventCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an event code';
    }
    final code = _parseEventCode(value);
    if (code.isEmpty) {
      return 'Invalid event code';
    }
    return null;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _resolveStatus(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return 'LIVE';
      case 'scheduled':
        return 'Soon';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<EventsBloc>()..add(GetUserEventsRequested()),
      child: Builder(
        builder: (context) {
          return BlocListener<EventsBloc, EventsState>(
            listener: (context, state) {
              if (state is JoinEventSuccess) {
                _eventCodeController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Successfully joined event!')),
                );
              }
              if (state is EventsFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              appBar: AppBar(
                title: Text(
                  "MultiAi Events",
                  style: Theme.of(context)
                      .appBarTheme
                      .titleTextStyle
                      ?.copyWith(color: AppTheme.accentColor),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: AppTheme.spacingLg),
                    child: GestureDetector(
                      onTap: () {
                        // navigate to notifications page when ready
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
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusXl),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              body: BlocBuilder<EventsBloc, EventsState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildJoinSection(context, state),
                          SizedBox(height: AppTheme.spacingXl),
                          _buildActiveSection(context, state),
                          SizedBox(height: AppTheme.spacingXl),
                          _buildArchivedSection(context, state),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJoinSection(BuildContext context, EventsState state) {
    final isJoining = state is JoinEventLoading;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - AppTheme.spacingMd * 2;

    return Container(
      width: containerWidth,
      padding: EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.formCardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.borderColor.withValues(alpha: 26),
          width: 1,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Join New Event",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppTheme.primaryTextColor),
            ),
            SizedBox(height: AppTheme.spacingXs),
            Text(
              "Have an invite? Enter the link below to participate.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: AppTheme.spacingLg),
            TextFormField(
              controller: _eventCodeController,
              decoration: InputDecoration(
                hintText: "https://multiai.app/e/...",
              ),
              validator: _validateEventCode,
            ),
            SizedBox(height: AppTheme.spacingSm),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isJoining
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          final code = _parseEventCode(_eventCodeController.text);
                          context
                              .read<EventsBloc>()
                              .add(JoinEventRequested(eventCode: code));
                        }
                      },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
                child: isJoining
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
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
    );
  }

  Widget _buildActiveSection(BuildContext context, EventsState state) {
    final activeEvents = state is EventsLoaded ? state.activeEvents : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingSm),
                  Text(
                    "Active Events",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 20),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Text(
                  '${activeEvents.length} Ongoing',
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
        SizedBox(height: AppTheme.spacingLg),
        if (state is EventsLoading)
          Center(child: CircularProgressIndicator())
        else if (activeEvents.isEmpty)
          _buildEmptyState(
            icon: Icons.event_busy,
            title: 'No active events',
            subtitle: 'Join an event to see it here!',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = (constraints.maxWidth / 350).floor();
              crossAxisCount = crossAxisCount < 1 ? 1 : crossAxisCount;

              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppTheme.spacingMd,
                  mainAxisSpacing: AppTheme.spacingMd,
                  childAspectRatio: 358 / 120,
                ),
                itemCount: activeEvents.length,
                itemBuilder: (context, index) {
                  final event = activeEvents[index];
                  return ActiveEventsCard(
                    eventTitle: event.name,
                    eventStatus: _resolveStatus(event.status),
                    eventDate: _formatDate(event.eventDate),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildArchivedSection(BuildContext context, EventsState state) {
    final archivedEvents = state is EventsLoaded ? state.archivedEvents : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ImageIcon( AssetImage('assets/icons/archived_icon.png') ),
            SizedBox(width: AppTheme.spacingSm),
            Text(
              "Archived Events",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 20),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacingLg),
        if (state is EventsLoading)
          Center(child: CircularProgressIndicator())
        else if (archivedEvents.isEmpty)
          _buildEmptyState(
            icon: Icons.archive_outlined,
            title: 'No archived events',
            subtitle: 'Your archived events will appear here.',
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: archivedEvents.map((event) {
                return ArchivedEventsCard(
                  eventTitle: event.name,
                  eventDate: _formatDate(event.eventDate),
                  // Placeholder image until backend provides one
                  // eventImage: 'assets/images/achived_event_img2.png',
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppTheme.secondaryTextColor),
            SizedBox(height: AppTheme.spacingMd),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
            ),
            SizedBox(height: AppTheme.spacingXs),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

