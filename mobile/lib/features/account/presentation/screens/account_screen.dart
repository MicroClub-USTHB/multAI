import 'package:flutter/material.dart';
import 'package:multai_mobile/core/widgets/app_error_view.dart';
import 'package:multai_mobile/core/errors/error_presentation.dart';
import 'package:multai_mobile/features/auth/presentation/blocs/auth_bloc.dart'
    as auth;
import '../../../../core/extensions/responsive_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/extensions/snackbar_extensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/language_service.dart';
import '../../../../di/injection_container.dart';
import '../bloc/account_bloc.dart';
import '../widgets/account_app_bar.dart';
import '../widgets/profile_section.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/logout_button.dart';
import '../widgets/delete_account_button.dart';
import 'package:multai_mobile/core/theme/theme.dart';

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
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

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

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete this account?'
          'This action cannot be undone',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.theme.colorScheme.error,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Theme'),
          content: ValueListenableBuilder<ThemeMode>(
            valueListenable: AppTheme.themeMode,
            builder: (context, currentMode, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: currentMode,
                    title: const Text('Light'),
                    onChanged: (value) {
                      if (value == null) return;
                      AppTheme.themeMode.value = value;
                      Navigator.of(ctx).pop();
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: currentMode,
                    title: const Text('Dark'),
                    onChanged: (value) {
                      if (value == null) return;
                      AppTheme.themeMode.value = value;
                      Navigator.of(ctx).pop();
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: currentMode,
                    title: const Text('System default'),
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
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.chooseYourLanguage),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: 'en',
                    groupValue: currentLocale.languageCode,
                    title: Text(AppLocalizations.of(context)!.english),
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
                    title: Text(AppLocalizations.of(context)!.french),
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
                    title: Text(AppLocalizations.of(context)!.arabic),
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
            'Freed ${state.storageFreed} (${state.filesRemoved} files)',
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
    if (state is AccountLoading || state is AccountCacheClearing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: context.theme.colorScheme.primary),
            if (state is AccountCacheClearing) ...[
              const SizedBox(height: 16),
              Text('Clearing cache...', style: context.textTheme.bodyMedium),
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
    final name = state is AccountLoaded
        ? state.name
        : (state is AccountAvatarUploading
              ? state.name
              : (state is AccountProfileUpdating ? state.name : ''));
    final email = state is AccountLoaded
        ? state.email
        : (state is AccountAvatarUploading
              ? state.email
              : (state is AccountProfileUpdating ? state.email : ''));
    final url =
        avatarUrl ??
        (state is AccountLoaded
            ? state.avatarUrl
            : (state is AccountAvatarUploading
                  ? state.avatarUrl
                  : (state is AccountProfileUpdating
                        ? state.avatarUrl
                        : null)));

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

          // ── Account Settings ───────────────────────────────────────────
          SettingsSection(
            title: 'ACCOUNT SETTINGS',
            items: [
              SettingItemData(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: 'Choose dark or light theme',
                onTap: () => _showThemeDialog(context),
              ),
              SettingItemData(
                icon: Icons.lock_outline,
                title: 'Privacy & Security',
                subtitle: 'Password, 2FA, and data sharing',
                onTap: () {},
              ),
              SettingItemData(
                icon: Icons.language_outlined,
                title: AppLocalizations.of(context)!.languages,
                subtitle: AppLocalizations.of(context)!.chooseYourLanguage,
                onTap: () => _showLanguageDialog(context),
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

          SizedBox(height: context.heightCalculated(16)),

          DeleteAccountButton(onPressed: () => _confirmDeleteAccount(context)),

          SizedBox(height: context.heightCalculated(16)),

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
