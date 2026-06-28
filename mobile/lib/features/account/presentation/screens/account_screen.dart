import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/widgets/app_error_view.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/snackbar_extensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../bloc/account_bloc.dart';
import '../widgets/account_app_bar.dart';
import '../widgets/profile_section.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/logout_button.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Image Cache'),
        content: const Text(
          'This will remove all cached photos from your device. '
          'Images will need to be re-downloaded when viewed again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AccountBloc>().add(ClearImageCacheRequested());
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.theme.colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountBloc, AccountState>(
      listener: (context, state) {
        if (state is AccountLoggedOut) {
          context.go(AppRoutes.login);
        }
        if (state is AccountError) {
          context.showErrorSnackBar(state.message);
        }
        if (state is AccountCacheCleared) {
          context.showSuccessSnackBar(
            'Freed ${state.storageFreed} (${state.filesRemoved} files)',
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppThemeColors.background,
          appBar: const AccountAppBar(),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AccountState state) {
    if (state is AccountLoading || state is AccountCacheClearing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: context.theme.colorScheme.primary,
            ),
            if (state is AccountCacheClearing) ...[
              const SizedBox(height: 16),
              Text(
                'Clearing cache...',
                style: context.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      );
    }

    if (state is AccountLoaded) {
      return _buildContent(context, state);
    }

    if (state is AccountInitial) {
      context.read<AccountBloc>().add(LoadAccountData());
      return Center(
        child: CircularProgressIndicator(
          color: context.theme.colorScheme.primary,
        ),
      );
    }

    if (state is AccountError) {
      return AppErrorView(
        title: 'Could not load account data',
        subtitle: 'Please check your connection and try again.',
        onRetry: () => context.read<AccountBloc>().add(LoadAccountData()),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context, AccountLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.hPadding(),
        vertical: context.heightCalculated(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Profile ────────────────────────────────────────────────────
          ProfileSection(
            name: state.name,
            email: state.email,
            membershipType: 'mc-member',
            avatarUrl: state.avatarUrl,
          ),
          SizedBox(height: context.heightCalculated(32)),

          // ── Account Settings ───────────────────────────────────────────
          SettingsSection(
            title: 'ACCOUNT SETTINGS',
            items: [
              SettingItemData(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage alerts and activity',
                onTap: () {},
              ),
              SettingItemData(
                icon: Icons.lock_outline,
                title: 'Privacy & Security',
                subtitle: 'Password, 2FA, and data sharing',
                onTap: () {},
              ),
              SettingItemData(
                icon: Icons.storage_outlined,
                title: 'Account Data',
                subtitle: 'Export or manage your personal data',
                onTap: () {},
              ),
              SettingItemData(
                icon: Icons.cleaning_services_outlined,
                title: 'Clear Image Cache',
                subtitle: 'Free up storage space',
                onTap: () => _confirmClearCache(context),
              ),
            ],
          ),
          SizedBox(height: context.heightCalculated(24)),

          // ── Support ────────────────────────────────────────────────────
          SettingsSection(
            title: 'SUPPORT',
            items: [
              SettingItemData(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: context.heightCalculated(32)),

          // ── Logout ─────────────────────────────────────────────────────
          LogoutButton(
            onPressed: () => context.read<AccountBloc>().add(LogoutRequested()),
          ),
          SizedBox(height: context.heightCalculated(24)),
        ],
      ),
    );
  }
}
