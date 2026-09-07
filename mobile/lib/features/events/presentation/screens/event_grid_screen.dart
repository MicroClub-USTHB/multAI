import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/l10n/app_localizations.dart';
import '../../../../core/errors/error_presentation.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_metrics.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../domain/entities/event_entity.dart';
import '../bloc/events_bloc.dart';
import 'event_photos_screen.dart';

class EventGridScreen extends StatefulWidget {
  const EventGridScreen({super.key});

  @override
  State<EventGridScreen> createState() => _EventGridScreenState();
}

class _EventGridScreenState extends State<EventGridScreen> {
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
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(l10n.yourEvents, style: tt.headlineMedium),
      ),
      body: BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          if (state is EventsLoading || state is EventsInitial) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          }

          if (state is EventsFailure) {
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
                  ? () => Navigator.of(context).pop()
                  : null,
            );
          }

          final events = state is EventsLoaded
              ? [...state.activeEvents, ...state.archivedEvents]
              : const <EventEntity>[];

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: context.iconSize() * 3,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: context.heightCalculated(16)),
                  Text(
                    l10n.noEventsYet,
                    style: tt.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(
              context.widthCalculated(AppThemeMetrics.spacingLg),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: context.widthCalculated(
                AppThemeMetrics.spacingMd,
              ),
              mainAxisSpacing: context.heightCalculated(
                AppThemeMetrics.spacingMd,
              ),
              childAspectRatio: 0.95,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _EventGridTile(event: event);
            },
          );
        },
      ),
    );
  }
}

class _EventGridTile extends StatelessWidget {
  final EventEntity event;

  const _EventGridTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return GestureDetector(
      key: ValueKey(event.id),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              EventPhotosScreen(eventId: event.id, eventName: event.name),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(
          context.widthCalculated(AppThemeMetrics.spacingMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.event_rounded,
              color: AppThemeColors.primaryAccent,
              size: context.iconSize() * 1.4,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: context.heightCalculated(AppThemeMetrics.spacingXs),
                ),
                Text(
                  event.eventDate.toDisplayDate(),
                  style: tt.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
