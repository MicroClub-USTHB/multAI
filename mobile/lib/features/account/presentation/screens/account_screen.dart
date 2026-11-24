import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:multai_mobile/core/cubits/locale_cubit.dart';
import 'package:multai_mobile/core/cubits/theme_cubit.dart';
import 'package:multai_mobile/core/errors/error_presentation.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/extensions/snackbar_extensions.dart';
import 'package:multai_mobile/core/network/api_client.dart';
import 'package:multai_mobile/core/router/app_routes.dart';
import 'package:multai_mobile/core/widgets/app_error_view.dart';
import 'package:multai_mobile/di/injection_container.dart' as di;
import 'package:multai_mobile/features/auth/presentation/blocs/auth_bloc.dart'
    as auth;
import 'package:multai_mobile/l10n/app_localizations.dart';

import '../bloc/account_bloc.dart';
import '../widgets/account_app_bar.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_section.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<ImageSource?> _chooseImageSource(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.camera),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.galleryPicker),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final bloc = context.read<AccountBloc>();
    final l10n = AppLocalizations.of(context)!;

    try {
      final source = await _chooseImageSource(context);
      if (source == null || !context.mounted) return;

      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 100,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (picked == null || !context.mounted) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        maxWidth: 1024,
        maxHeight: 1024,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: l10n.changeProfilePhoto,
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
            aspectRatioPresets: const [CropAspectRatioPreset.square],
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: l10n.changeProfilePhoto,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );
      if (cropped == null || !context.mounted) return;

      bloc.add(UploadAvatar(filePath: cropped.path));
    } catch (_) {
      if (!context.mounted) return;
      context.showErrorSnackBar(l10n.photoUpdateFailed);
    }
  }

  void _editName(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    final l10n = AppLocalizations.of(context)!;
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

  void _showThemeSheet(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final currentMode = themeCubit.state;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.selectTheme,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _ThemeOption(
              label: l10n.light,
              icon: Icons.light_mode_outlined,
              selected: currentMode == ThemeMode.light,
              onTap: () {
                themeCubit.setThemeMode(ThemeMode.light);
                Navigator.of(ctx).pop();
              },
            ),
            _ThemeOption(
              label: l10n.dark,
              icon: Icons.dark_mode_outlined,
              selected: currentMode == ThemeMode.dark,
              onTap: () {
                themeCubit.setThemeMode(ThemeMode.dark);
                Navigator.of(ctx).pop();
              },
            ),
            _ThemeOption(
              label: l10n.systemDefault,
              icon: Icons.brightness_auto_outlined,
              selected: currentMode == ThemeMode.system,
              onTap: () {
                themeCubit.setThemeMode(ThemeMode.system);
                Navigator.of(ctx).pop();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();
    final currentLocale = localeCubit.state;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.selectLanguage,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _LanguageOption(
              label: l10n.english,
              flag: '🇬🇧',
              selected: currentLocale.languageCode == 'en',
              onTap: () {
                localeCubit.setLocale(const Locale('en'));
                Navigator.of(ctx).pop();
              },
            ),
            _LanguageOption(
              label: l10n.arabic,
              flag: '🇸🇦',
              selected: currentLocale.languageCode == 'ar',
              onTap: () {
                localeCubit.setLocale(const Locale('ar'));
                Navigator.of(ctx).pop();
              },
            ),
            _LanguageOption(
              label: l10n.french,
              flag: '🇫🇷',
              selected: currentLocale.languageCode == 'fr',
              onTap: () {
                localeCubit.setLocale(const Locale('fr'));
                Navigator.of(ctx).pop();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.systemDefault;
    }
  }

  String _localeLabel(BuildContext context, Locale locale) {
    final l10n = AppLocalizations.of(context)!;
    switch (locale.languageCode) {
      case 'ar':
        return l10n.arabic;
      case 'fr':
        return l10n.french;
      default:
        return l10n.english;
    }
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
          backgroundColor: context.theme.scaffoldBackgroundColor,
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
              Text(
                AppLocalizations.of(context)!.clearingCache,
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
    String? avatarCacheKey,
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
    final cacheKey =
        avatarCacheKey ??
        (state is AccountLoaded
            ? state.avatarCacheKey
            : (state is AccountAvatarUploading
                  ? state.avatarCacheKey
                  : (state is AccountProfileUpdating
                        ? state.avatarCacheKey
                        : null)));

    final l10n = AppLocalizations.of(context)!;
    final themeMode = context.watch<ThemeCubit>().state;
    final currentLocale = context.watch<LocaleCubit>().state;
    final accessToken = di.sl<ApiClient>().currentAccessToken;
    final avatarHeaders = accessToken == null
        ? null
        : <String, String>{'Authorization': 'Bearer $accessToken'};

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
            membershipType: l10n.mcMember,
            avatarUrl: url,
            avatarCacheKey: cacheKey,
            avatarHeaders: avatarHeaders,
            isUploading: isUploading,
            onAvatarTap: () => _pickAndUploadAvatar(context),
            onEditName: state is AccountProfileUpdating
                ? null
                : () => _editName(context, name),
          ),
          SizedBox(height: context.heightCalculated(32)),

          // ── Preferences ────────────────────────────────────────────────
          SettingsSection(
            title: l10n.preferences,
            items: [
              SettingItemData(
                icon: Icons.dark_mode_outlined,
                title: l10n.appearance,
                subtitle:
                    '${l10n.lightDarkMode} · ${_themeModeLabel(context, themeMode)}',
                onTap: () => _showThemeSheet(context),
              ),
              SettingItemData(
                icon: Icons.language_outlined,
                title: l10n.language,
                subtitle:
                    '${l10n.changeAppLanguage} · ${_localeLabel(context, currentLocale)}',
                onTap: () => _showLanguageSheet(context),
              ),
            ],
          ),
          SizedBox(height: context.heightCalculated(24)),

          // ── Account Settings ───────────────────────────────────────────
          SettingsSection(
            title: l10n.accountSettings,
            items: [
              SettingItemData(
                icon: Icons.notifications_outlined,
                title: l10n.notifications,
                subtitle: l10n.manageAlertsAndActivity,
                onTap: () {},
              ),
              SettingItemData(
                icon: Icons.lock_outline,
                title: l10n.privacySecurity,
                subtitle: l10n.privacySecurityDescription,
                onTap: () {},
              ),
              SettingItemData(
                icon: Icons.backup_outlined,
                title: l10n.backupPhotos,
                subtitle: l10n.downloadPhotosAsZip,
                onTap: () => context.push(AppRoutes.backup),
              ),
              SettingItemData(
                icon: Icons.photo_library_outlined,
                title: l10n.myAlbums,
                subtitle: l10n.organizePhotosIntoAlbums,
                onTap: () => context.push(AppRoutes.albums),
              ),
              SettingItemData(
                icon: Icons.cleaning_services_outlined,
                title: l10n.clearImageCache,
                subtitle: state is AccountLoaded
                    ? '${l10n.freeUpStorage} · ${state.cacheSize}'
                    : l10n.freeUpStorage,
                onTap: () => _confirmClearCache(context),
              ),
            ],
          ),
          SizedBox(height: context.heightCalculated(24)),

          // ── Support ────────────────────────────────────────────────────
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
          SizedBox(height: context.heightCalculated(32)),

          // ── Logout ────────────────────────────────────────────
          LogoutButton(
            onPressed: () => context.read<AccountBloc>().add(LogoutRequested()),
          ),
          SizedBox(height: context.heightCalculated(24)),
        ],
      ),
    );
  }
}

// ── Helper widgets for bottom sheets ──────────────────────────────────────────

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return ListTile(
      leading: Icon(icon, color: selected ? cs.primary : null),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle, color: cs.primary)
          : Icon(
              Icons.circle_outlined,
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
      onTap: onTap,
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle, color: cs.primary)
          : Icon(
              Icons.circle_outlined,
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
      onTap: onTap,
    );
  }
}
