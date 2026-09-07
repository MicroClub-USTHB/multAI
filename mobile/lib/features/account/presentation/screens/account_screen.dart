import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:multai_mobile/core/errors/error_presentation.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/extensions/snackbar_extensions.dart';
import 'package:multai_mobile/core/router/app_routes.dart';
import 'package:multai_mobile/core/services/language_service.dart';
import 'package:multai_mobile/core/theme/theme.dart';
import 'package:multai_mobile/core/widgets/app_error_view.dart';
import 'package:multai_mobile/features/auth/presentation/blocs/auth_bloc.dart'
    as auth;
import 'package:multai_mobile/l10n/app_localizations.dart';

import '../../../../di/injection_container.dart';
import '../bloc/account_bloc.dart';
import '../widgets/account_app_bar.dart';
import '../widgets/delete_account_button.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_section.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final bloc = context.read<AccountBloc>();
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (picked == null) return;

    bloc.add(UploadAvatar(filePath: picked.path));
  }

  void _editName(BuildContext context, String currentName) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editName),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          decoration: InputDecoration(hintText: l10n.yourName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();

              Navigator.of(ctx).pop();

              if (newName.isEmpty || newName == currentName) return;

              context.read<AccountBloc>().add(
                UpdateProfileRequested(name: newName),
              );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmClearCache(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearImageCache),
        content: Text(l10n.clearImageCacheDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();

              context.read<AccountBloc>().add(ClearImageCacheRequested());
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.theme.colorScheme.error,
            ),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.theme.colorScheme.error,
            ),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.theme),
          content: ValueListenableBuilder<ThemeMode>(
            valueListenable: AppTheme.themeMode,
            builder: (context, currentMode, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: currentMode,
                    title: Text(l10n.light),
                    onChanged: (value) {
                      if (value == null) return;

                      AppTheme.themeMode.value = value;
                      Navigator.of(ctx).pop();
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: currentMode,
                    title: Text(l10n.dark),
                    onChanged: (value) {
                      if (value == null) return;

                      AppTheme.themeMode.value = value;
                      Navigator.of(ctx).pop();
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: currentMode,
                    title: Text(l10n.systemDefault),
                    onChanged: (value) {
                      if (value == null) return;

                      AppTheme.themeMode.value = value;
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languageService = sl<LanguageService>();

    showDialog(
      context: context,
      builder: (ctx) {
        return ValueListenableBuilder<Locale>(
          valueListenable: languageService.locale,
          builder: (context, currentLocale, _) {
            final l10n = AppLocalizations.of(context)!;

            return AlertDialog(
              title: Text(l10n.chooseYourLanguage),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: 'en',
                    groupValue: currentLocale.languageCode,
                    title: Text(l10n.english),
                    onChanged: (value) async {
                      if (value == null) return;

                      await languageService.setLanguage(value);

                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),
                  RadioListTile<String>(
                    value: 'fr',
                    groupValue: currentLocale.languageCode,
                    title: Text(l10n.french),
                    onChanged: (value) async {
                      if (value == null) return;

                      await languageService.setLanguage(value);

                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),
                  RadioListTile<String>(
                    value: 'ar',
                    groupValue: currentLocale.languageCode,
                    title: Text(l10n.arabic),
                    onChanged: (value) async {
                      if (value == null) return;

                      await languageService.setLanguage(value);

                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
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
          context.showErrorSnackBar(state.errorPresentation.description);
        }

        if (state is AccountCacheCleared) {
          context.showSuccessSnackBar(
            AppLocalizations.of(
              context,
            )!.freedStorage(state.storageFreed, state.filesRemoved),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: const AccountAppBar(),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AccountState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is AccountLoading || state is AccountCacheClearing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: context.theme.colorScheme.primary),
            if (state is AccountCacheClearing) ...[
              const SizedBox(height: 16),
              Text(l10n.clearingCache, style: context.textTheme.bodyMedium),
            ],
          ],
        ),
      );
    }

    if (state is AccountLoaded) {
      return _buildContent(context, state);
    }

    if (state is AccountAvatarUploading) {
      return _buildContent(
        context,
        state,
        avatarUrl: state.avatarUrl,
        isUploading: true,
      );
    }

    if (state is AccountProfileUpdating) {
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
      final p = state.errorPresentation;

      return ErrorStateView(
        title: p.title,
        description: p.description,
        illustration: p.illustration,
        actionLabel: p.actionLabel,
        onAction: p.action == ErrorAction.retry
            ? () => context.read<AccountBloc>().add(LoadAccountData())
            : p.action == ErrorAction.signIn
            ? () {
                context.read<auth.AuthBloc>().add(auth.LogoutRequested());

                context.go(AppRoutes.login);
              }
            : p.action == ErrorAction.goBack
            ? () => context.pop()
            : null,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildContent(
    BuildContext context,
    AccountState state, {
    String? avatarUrl,
    bool isUploading = false,
  }) {
    final l10n = AppLocalizations.of(context)!;

    final name = state is AccountLoaded
        ? state.name
        : state is AccountAvatarUploading
        ? state.name
        : state is AccountProfileUpdating
        ? state.name
        : '';

    final email = state is AccountLoaded
        ? state.email
        : state is AccountAvatarUploading
        ? state.email
        : state is AccountProfileUpdating
        ? state.email
        : '';

    final url =
        avatarUrl ??
        (state is AccountLoaded
            ? state.avatarUrl
            : state is AccountAvatarUploading
            ? state.avatarUrl
            : state is AccountProfileUpdating
            ? state.avatarUrl
            : null);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.hPadding(),
        vertical: context.heightCalculated(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileSection(
            name: name,
            email: email,
            membershipType: 'mc-member',
            avatarUrl: url,
            isUploading: isUploading,
            onAvatarTap: () => _pickAndUploadAvatar(context),
            onEditName: state is AccountProfileUpdating
                ? null
                : () => _editName(context, name),
          ),

          SizedBox(height: context.heightCalculated(32)),

          SettingsSection(
            title: l10n.accountSettings,
            items: [
              SettingItemData(
                icon: Icons.dark_mode_outlined,
                title: l10n.theme,
                subtitle: l10n.chooseTheme,
                onTap: () => _showThemeDialog(context),
              ),
              SettingItemData(
                icon: Icons.lock_outline,
                title: l10n.privacySecurity,
                subtitle: l10n.privacySecurityDescription,
                onTap: () {},
              ),
              SettingItemData(
                icon: Icons.language_outlined,
                title: l10n.languages,
                subtitle: l10n.chooseYourLanguage,
                onTap: () => _showLanguageDialog(context),
              ),
              SettingItemData(
                icon: Icons.cleaning_services_outlined,
                title: l10n.clearImageCache,
                subtitle: l10n.freeUpStorage,
                onTap: () => _confirmClearCache(context),
              ),
            ],
          ),

          SizedBox(height: context.heightCalculated(24)),

          SettingsSection(
            title: l10n.support,
            items: [
              SettingItemData(
                icon: Icons.help_outline,
                title: l10n.helpCenter,
                onTap: () {},
              ),
            ],
          ),

          SizedBox(height: context.heightCalculated(16)),

          DeleteAccountButton(onPressed: () => _confirmDeleteAccount(context)),

          SizedBox(height: context.heightCalculated(16)),

          LogoutButton(
            onPressed: () => context.read<AccountBloc>().add(LogoutRequested()),
          ),

          SizedBox(height: context.heightCalculated(24)),
        ],
      ),
    );
  }
}
