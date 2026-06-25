import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
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
    if (state is AccountLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: context.theme.colorScheme.primary,
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
      return Center(
        child: Padding(
          padding: EdgeInsets.all(
            context.widthCalculated(AppThemeMetrics.spacingXl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: context.iconSize() * 3,
                color: AppThemeColors.secondaryText,
              ),
              SizedBox(
                height: context.heightCalculated(AppThemeMetrics.spacingLg),
              ),
              Text(
                'Could not load account data',
                style: context.textTheme.headlineSmall?.copyWith(
                  color: AppThemeColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: context.heightCalculated(AppThemeMetrics.spacingSm),
              ),
              Text(
                'Please check your connection and try again.',
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: context.heightCalculated(AppThemeMetrics.spacingXl),
              ),
              ElevatedButton.icon(
                onPressed: () => context.read<AccountBloc>().add(
                  LoadAccountData(),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppThemeColors.primaryText,
                  backgroundColor: AppThemeColors.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeMetrics.radiusSm,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
