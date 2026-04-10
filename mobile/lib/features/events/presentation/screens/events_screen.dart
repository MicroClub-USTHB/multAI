import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/snackbar_extensions.dart';
import '../../../../../core/extensions/string_extensions.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/theme.dart';
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
            'MultiAi Events',
            style: context.theme.appBarTheme.titleTextStyle?.copyWith(
              color: AppTheme.accentColor,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(
                right: context.widthCalculated(AppTheme.spacingLg),
              ),
              child: GestureDetector(
                onTap: () => context.go(AppRoutes.notifications),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: AppTheme.secondaryTextColor,
                      size: context.iconSize(),
                    ),
                    Positioned(
                      top: 1,
                      right: context.widthCalculated(AppTheme.spacingXs),
                      child: Container(
                        width: context.widthCalculated(AppTheme.notifDotSize),
                        height: context.widthCalculated(AppTheme.notifDotSize),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          border: Border.all(
                            color: AppTheme.backgroundColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusXl,
                          ),
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
                padding: EdgeInsets.all(
                  context.widthCalculated(AppTheme.spacingLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildJoinSection(context, state),
                    SizedBox(
                      height: context.heightCalculated(AppTheme.spacingXl),
                    ),
                    _buildActiveSection(context, state),
                    SizedBox(
                      height: context.heightCalculated(AppTheme.spacingXl),
                    ),
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

  // ── Join section ───────────────────────────────────────────────────────────
  Widget _buildJoinSection(BuildContext context, EventsState state) {
    final tt = context.textTheme;
    final isJoining = state is JoinEventLoading;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.widthCalculated(AppTheme.spacingLg)),
      decoration: BoxDecoration(
        color: AppTheme.formCardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.borderColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join New Event',
              style: tt.headlineSmall?.copyWith(
                color: AppTheme.primaryTextColor,
              ),
            ),
            SizedBox(height: context.heightCalculated(AppTheme.spacingXs)),
            Text(
              'Have an invite? Enter the link below to participate.',
              style: tt.bodySmall,
            ),
            SizedBox(height: context.heightCalculated(AppTheme.spacingLg)),
            TextFormField(
              controller: _eventCodeController,
              decoration: const InputDecoration(
                hintText: 'https://multiai.app/e/...',
              ),
              validator: EventCodeValidator.validate,
            ),
            SizedBox(height: context.heightCalculated(AppTheme.spacingSm)),
            SizedBox(
              width: double.infinity,
              height: context.heightCalculated(48),
              child: ElevatedButton(
                onPressed: isJoining
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          final code = _eventCodeController.text.toEventCode();
                          context.read<EventsBloc>().add(
                            JoinEventRequested(eventCode: code),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
                child: isJoining
                    ? SizedBox(
                        width: context.widthCalculated(AppTheme.spacingLg),
                        height: context.widthCalculated(AppTheme.spacingLg),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Join Event',
                        style: tt.titleLarge?.copyWith(
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Active section ─────────────────────────────────────────────────────────
  Widget _buildActiveSection(BuildContext context, EventsState state) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
    final activeEvents = state is EventsLoaded ? state.activeEvents : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.widthCalculated(AppTheme.spacingXs),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: context.widthCalculated(AppTheme.statusDotSize),
                    height: context.widthCalculated(AppTheme.statusDotSize),
                    decoration: const BoxDecoration(
                      color: AppTheme.activeEventDotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: context.widthCalculated(AppTheme.spacingSm)),
                  Text('Active Events', style: tt.headlineSmall),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: context.heightCalculated(AppTheme.spacingXs),
                  horizontal: context.widthCalculated(AppTheme.spacingSm),
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Text(
                  '${activeEvents.length} Ongoing',
                  style: tt.labelMedium?.copyWith(color: cs.primary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.heightCalculated(AppTheme.spacingLg)),

        if (state is EventsLoading)
          Center(child: CircularProgressIndicator(color: cs.primary))
        else if (activeEvents.isEmpty)
          _buildEmptyState(
            context: context,
            icon: Icons.event_busy,
            title: 'No active events',
            subtitle: 'Join an event to see it here!',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount =
                  (constraints.maxWidth /
                          context.widthCalculated(
                            AppTheme.activeCardBreakpoint,
                          ))
                      .floor()
                      .clamp(1, 10);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: context.widthCalculated(AppTheme.spacingMd),
                  mainAxisSpacing: context.heightCalculated(AppTheme.spacingMd),
                  childAspectRatio:
                      AppTheme.activeCardAspectWidth /
                      context.heightCalculated(120),
                ),
                itemCount: activeEvents.length,
                itemBuilder: (context, index) {
                  final event = activeEvents[index];
                  return ActiveEventsCard(
                    eventTitle: event.name,
                    eventStatus: EventStatusMapper.toDisplayStatus(
                      event.status,
                    ),
                    eventDate: event.eventDate,
                  );
                },
              );
            },
          ),
      ],
    );
  }

  // ── Archived section ───────────────────────────────────────────────────────
  Widget _buildArchivedSection(BuildContext context, EventsState state) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
    final archivedEvents = state is EventsLoaded ? state.archivedEvents : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ImageIcon(AssetImage('assets/icons/archived_icon.png')),
            SizedBox(width: context.widthCalculated(AppTheme.spacingSm)),
            Text('Archived Events', style: tt.headlineSmall),
          ],
        ),
        SizedBox(height: context.heightCalculated(AppTheme.spacingLg)),

        if (state is EventsLoading)
          Center(child: CircularProgressIndicator(color: cs.primary))
        else if (archivedEvents.isEmpty)
          _buildEmptyState(
            context: context,
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

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final tt = context.textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: context.heightCalculated(AppTheme.emptyStatePadding),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: context.iconSize() * 2.5,
              color: AppTheme.secondaryTextColor,
            ),
            SizedBox(height: context.heightCalculated(AppTheme.spacingMd)),
            Text(
              title,
              style: tt.titleMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            SizedBox(height: context.heightCalculated(AppTheme.spacingXs)),
            Text(subtitle, style: tt.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
