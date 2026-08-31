import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/snackbar_extensions.dart';
import '../../../../../core/extensions/string_extensions.dart';
import '../../../../../core/router/app_routes.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/widgets/app_error_view.dart';
import 'package:multai_mobile/core/widgets/join_event_success_animation.dart';
import 'package:multai_mobile/core/errors/error_presentation.dart';
import 'package:multai_mobile/features/auth/presentation/blocs/auth_bloc.dart';
import '../../domain/validators/event_code_validator.dart';
import 'package:multai_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import '../bloc/events_bloc.dart';
import '../mappers/event_status_mapper.dart';
import '../widgets/active_events_card.dart';
import '../widgets/archived_events_card.dart';
import 'event_photos_screen.dart';
import 'qr_scan_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _eventCodeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showJoinAnimation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<EventsBloc>().state;
      if (state is EventsInitial || state is EventsFailure) {
        context.read<EventsBloc>().add(GetUserEventsRequested());
      }
    });
  }

  @override
  void dispose() {
    _eventCodeController.dispose();
    super.dispose();
  }

  Future<void> _scanQrCode() async {
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const QrScanScreen()));
    if (result == null || result.isEmpty || !mounted) return;
    setState(() => _eventCodeController.text = result.toEventCode());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventsBloc, EventsState>(
      listener: (context, state) {
        if (state is JoinEventSuccess) {
          _eventCodeController.clear();
          setState(() => _showJoinAnimation = true);
        }
        if (state is EventsFailure) {
          context.showErrorSnackBar(state.errorPresentation.description);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppThemeColors.background,
            appBar: AppBar(
              title: Text(
                'MultiAi Events',
                style: context.theme.appBarTheme.titleTextStyle?.copyWith(
                  color: AppThemeColors.accent,
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(
                    right: context.widthCalculated(AppThemeMetrics.spacingLg),
                  ),
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.notifications),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          color: AppThemeColors.secondaryText,
                          size: context.iconSize(),
                        ),
                        BlocBuilder<NotificationBloc, NotificationState>(
                          builder: (context, nState) {
                            final unread = nState is NotificationLoaded
                                ? nState.unreadCount
                                : 0;
                            if (unread <= 0) return const SizedBox.shrink();
                            return Positioned(
                              top: 1,
                              right: context.widthCalculated(
                                AppThemeMetrics.spacingXs,
                              ),
                              child: Container(
                                width: context.widthCalculated(
                                  AppThemeMetrics.notifDotSize,
                                ),
                                height: context.widthCalculated(
                                  AppThemeMetrics.notifDotSize,
                                ),
                                decoration: BoxDecoration(
                                  color: AppThemeColors.accent,
                                  border: Border.all(
                                    color: AppThemeColors.background,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppThemeMetrics.radiusXl,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: BlocBuilder<EventsBloc, EventsState>(
              builder: (context, state) {
                if (state is EventsFailure) {
                  return _buildErrorState(context);
                }
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(
                      context.widthCalculated(AppThemeMetrics.spacingLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state is EventsLoaded && state.isOffline)
                          _buildOfflineBanner(context),
                        if (state is EventsLoaded && state.isRefreshing)
                          _buildRefreshingIndicator(context),
                        SizedBox(
                          height: context.heightCalculated(
                            AppThemeMetrics.spacingMd,
                          ),
                        ),
                        _buildJoinSection(context, state),
                        SizedBox(
                          height: context.heightCalculated(
                            AppThemeMetrics.spacingXl,
                          ),
                        ),
                        _buildActiveSection(context, state),
                        SizedBox(
                          height: context.heightCalculated(
                            AppThemeMetrics.spacingXl,
                          ),
                        ),
                        _buildArchivedSection(context, state),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_showJoinAnimation)
            JoinEventSuccessAnimation(
              onComplete: () {
                setState(() => _showJoinAnimation = false);
                context.showSuccessSnackBar('Successfully joined event!');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final state = context.read<EventsBloc>().state;
    if (state is! EventsFailure) return const SizedBox.shrink();
    final p = state.errorPresentation;
    return ErrorStateView(
      title: p.title,
      description: p.description,
      illustration: p.illustration,
      actionLabel: p.actionLabel,
      onAction: p.action == ErrorAction.retry
          ? () => context.read<EventsBloc>().add(EventsRetryRequested())
          : p.action == ErrorAction.signIn
              ? () {
                  context.read<AuthBloc>().add(LogoutRequested());
                  context.go(AppRoutes.login);
                }
              : p.action == ErrorAction.goBack
                  ? () => context.pop()
                  : null,
    );
  }

  // ── Refresh indicator ────────────────────────────────────────────────────
  Widget _buildRefreshingIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.heightCalculated(AppThemeMetrics.spacingSm),
      ),
      child: LinearProgressIndicator(
        backgroundColor: AppThemeColors.border.withValues(alpha: 0.2),
        valueColor: const AlwaysStoppedAnimation<Color>(AppThemeColors.primaryAccent),
      ),
    );
  }

  // ── Offline banner (showing cached data) ─────────────────────────────────
  Widget _buildOfflineBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        context.widthCalculated(AppThemeMetrics.spacingSm),
      ),
      decoration: BoxDecoration(
        color: AppThemeColors.primaryAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppThemeMetrics.radiusSm),
        border: Border.all(color: AppThemeColors.primaryAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: context.iconSize(),
            color: AppThemeColors.primaryAccent,
          ),
          SizedBox(width: context.widthCalculated(AppThemeMetrics.spacingSm)),
          Expanded(
            child: Text(
              'Showing cached data. Connect to the internet to see the latest.',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppThemeColors.primaryAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Join section ───────────────────────────────────────────────────────────
  Widget _buildJoinSection(BuildContext context, EventsState state) {
    final tt = context.textTheme;
    final isJoining = state is JoinEventLoading;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        context.widthCalculated(AppThemeMetrics.spacingLg),
      ),
      decoration: BoxDecoration(
        color: AppThemeColors.formCard,
        borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
        border: Border.all(
          color: AppThemeColors.border.withValues(alpha: 0.1),
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
                color: AppThemeColors.primaryText,
              ),
            ),
            SizedBox(
              height: context.heightCalculated(AppThemeMetrics.spacingXs),
            ),
            Text(
              'Have an invite? Enter the event code below to participate.',
              style: tt.bodySmall,
            ),
            SizedBox(
              height: context.heightCalculated(AppThemeMetrics.spacingLg),
            ),
            TextFormField(
              controller: _eventCodeController,
              decoration: InputDecoration(
                hintText: 'e.g. Xk3p9QzL2A',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Scan QR code',
                  onPressed: _scanQrCode,
                ),
              ),
              validator: EventCodeValidator.validate,
            ),
            SizedBox(
              height: context.heightCalculated(AppThemeMetrics.spacingSm),
            ),
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
                    borderRadius: BorderRadius.circular(
                      AppThemeMetrics.radiusSm,
                    ),
                  ),
                ),
                child: isJoining
                    ? SizedBox(
                        width: context.widthCalculated(
                          AppThemeMetrics.spacingLg,
                        ),
                        height: context.widthCalculated(
                          AppThemeMetrics.spacingLg,
                        ),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Join Event',
                        style: tt.titleLarge?.copyWith(
                          color: AppThemeColors.primaryText,
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
            horizontal: context.widthCalculated(AppThemeMetrics.spacingXs),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: context.widthCalculated(
                      AppThemeMetrics.statusDotSize,
                    ),
                    height: context.widthCalculated(
                      AppThemeMetrics.statusDotSize,
                    ),
                    decoration: const BoxDecoration(
                      color: AppThemeColors.activeEventDot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(
                    width: context.widthCalculated(AppThemeMetrics.spacingSm),
                  ),
                  Text('Active Events', style: tt.headlineSmall),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: context.heightCalculated(AppThemeMetrics.spacingXs),
                  horizontal: context.widthCalculated(
                    AppThemeMetrics.spacingSm,
                  ),
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
                ),
                child: Text(
                  '${activeEvents.length} Ongoing',
                  style: tt.labelMedium?.copyWith(color: cs.primary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.heightCalculated(AppThemeMetrics.spacingLg)),

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
                            AppThemeMetrics.activeCardBreakpoint,
                          ))
                      .floor()
                      .clamp(1, 10);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: context.widthCalculated(
                    AppThemeMetrics.spacingMd,
                  ),
                  mainAxisSpacing: context.heightCalculated(
                    AppThemeMetrics.spacingMd,
                  ),
                  childAspectRatio:
                      AppThemeMetrics.activeCardAspectWidth /
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
                    endDate: event.endDate,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventPhotosScreen(
                          eventId: event.id,
                          eventName: event.name,
                        ),
                      ),
                    ),
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
            Icon(
              Icons.archive_outlined,
              size: context.iconSize(),
              color: AppThemeColors.secondaryText,
            ),
            SizedBox(width: context.widthCalculated(AppThemeMetrics.spacingSm)),
            Text('Archived Events', style: tt.headlineSmall),
          ],
        ),
        SizedBox(height: context.heightCalculated(AppThemeMetrics.spacingLg)),

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
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventPhotosScreen(
                        eventId: event.id,
                        eventName: event.name,
                      ),
                    ),
                  ),
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
          vertical: context.heightCalculated(AppThemeMetrics.emptyStatePadding),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: context.iconSize() * 2.5,
              color: AppThemeColors.secondaryText,
            ),
            SizedBox(
              height: context.heightCalculated(AppThemeMetrics.spacingMd),
            ),
            Text(
              title,
              style: tt.titleMedium?.copyWith(
                color: AppThemeColors.secondaryText,
              ),
            ),
            SizedBox(
              height: context.heightCalculated(AppThemeMetrics.spacingXs),
            ),
            Text(subtitle, style: tt.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
