import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/extensions/string_extensions.dart';
import '../../../../../core/extensions/snackbar_extensions.dart';
import '../../domain/validators/event_code_validator.dart';
import '../bloc/events_bloc.dart';
import '../mappers/event_status_mapper.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventsBloc, EventsState>(
      listener: (context, state) {
        if (state is JoinEventSuccess) {
          _eventCodeController.clear();
          context.showSuccessSnackBar('Successfully joined event!');
        }
        if (state is EventsFailure) {
          context.showErrorSnackBar(state.message);
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
              padding: const EdgeInsets.only(right: AppTheme.spacingLg),
              child: GestureDetector(
                onTap: () {},
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: AppTheme.secondaryTextColor,
                      size: AppTheme.iconLg,
                    ),
                    Positioned(
                      top: 1,
                      right: AppTheme.spacingXs,
                      child: Container(
                        width: AppTheme.notifDotSize,
                        height: AppTheme.notifDotSize,
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
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildJoinSection(context, state),
                    const SizedBox(height: AppTheme.spacingXl),
                    _buildActiveSection(context, state),
                    const SizedBox(height: AppTheme.spacingXl),
                    _buildArchivedSection(context, state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildJoinSection(BuildContext context, EventsState state) {
    final isJoining = state is JoinEventLoading;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - AppTheme.spacingMd * 2;

    return Container(
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
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              "Have an invite? Enter the link below to participate.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            TextFormField(
              controller: _eventCodeController,
              decoration: const InputDecoration(
                hintText: "https://multiai.app/e/...",
              ),
              validator: EventCodeValidator.validate,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            SizedBox(
              width: double.infinity,
              height: AppTheme.activeCardHeight / 2.5,
              child: ElevatedButton(
                onPressed: isJoining
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          final code = _eventCodeController.text.toEventCode();
                          context.read<EventsBloc>().add(JoinEventRequested(eventCode: code));
                        }
                      },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(AppTheme.radiusSm)
                  ),
                ),
                child: isJoining
                    ? const SizedBox(
                        width: AppTheme.spacingLg,
                        height: AppTheme.spacingLg,
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
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: AppTheme.statusDotSize,
                    height: AppTheme.statusDotSize,
                    decoration: const BoxDecoration(
                      color: AppTheme.activeEventDotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    "Active Events",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: AppTheme.fontSizeXl),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingXs,
                  horizontal: AppTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Text(
                  '${activeEvents.length} Ongoing',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: AppTheme.fontSizeSm,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        if (state is EventsLoading)
          const Center(child: CircularProgressIndicator())
        else if (activeEvents.isEmpty)
          _buildEmptyState(
            icon: Icons.event_busy,
            title: 'No active events',
            subtitle: 'Join an event to see it here!',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount =
                  (constraints.maxWidth / AppTheme.activeCardBreakpoint)
                      .floor()
                      .clamp(1, 10);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppTheme.spacingMd,
                  mainAxisSpacing: AppTheme.spacingMd,
                  childAspectRatio:
                      AppTheme.activeCardAspectWidth / AppTheme.activeCardHeight,
                ),
                itemCount: activeEvents.length,
                itemBuilder: (context, index) {
                  final event = activeEvents[index];
                  return ActiveEventsCard(
                    eventTitle: event.name,
                    eventStatus:
                        EventStatusMapper.toDisplayStatus(event.status),
                    eventDate: event.eventDate,
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildArchivedSection(BuildContext context, EventsState state) {
    final archivedEvents =
        state is EventsLoaded ? state.archivedEvents : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ImageIcon(AssetImage('assets/icons/archived_icon.png')),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              "Archived Events",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: AppTheme.fontSizeXl),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingLg),
        if (state is EventsLoading)
          const Center(child: CircularProgressIndicator())
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
                  eventDate: event.eventDate,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: AppTheme.emptyStatePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppTheme.emptyStateIconSize,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXs),
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

