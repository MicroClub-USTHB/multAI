import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
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
          backgroundColor: AppTheme.backgroundColor,
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

    // initial — trigger load
    if (state is AccountInitial) {
      context.read<AccountBloc>().add(LoadAccountData());
      return Center(
        child: CircularProgressIndicator(
          color: context.theme.colorScheme.primary,
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
            name:           state.name,
            email:          state.email,
            membershipType: state.membershipType,
            avatarUrl:      state.avatarUrl,
          ),
          SizedBox(height: context.heightCalculated(32)),

          // ── Account Settings ───────────────────────────────────────────
          SettingsSection(
            title: 'ACCOUNT SETTINGS',
            items: [
              SettingItemData(
                icon:     Icons.notifications_outlined,
                title:    'Notifications',
                subtitle: 'Manage alerts and activity',
                onTap:    () {},
              ),
              SettingItemData(
                icon:     Icons.lock_outline,
                title:    'Privacy & Security',
                subtitle: 'Password, 2FA, and data sharing',
                onTap:    () {},
              ),
              SettingItemData(
                icon:     Icons.storage_outlined,
                title:    'Account Data',
                subtitle: 'Export or manage your personal data',
                onTap:    () {},
              ),
            ],
          ),
          SizedBox(height: context.heightCalculated(24)),

          // ── Support ────────────────────────────────────────────────────
          SettingsSection(
            title: 'SUPPORT',
            items: [
              SettingItemData(
                icon:  Icons.help_outline,
                title: 'Help Center',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: context.heightCalculated(32)),

          // ── Logout ─────────────────────────────────────────────────────
          LogoutButton(
            onPressed: () => context
                .read<AccountBloc>()
                .add(LogoutRequested()),
          ),
          SizedBox(height: context.heightCalculated(24)),
        ],
      ),
    );
  }
}
