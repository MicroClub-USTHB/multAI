import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../widgets/account_app_bar.dart';
import '../widgets/profile_section.dart';
import '../widgets/settings_section.dart';
import '../widgets/logout_button.dart';
import '../widgets/settings_tile.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const AccountAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.hPadding(),
          vertical: context.heightCalculated(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Profile ─────────────────────────────────────────────────
            Center(child: const ProfileSection(),),
            SizedBox(height: context.heightCalculated(32)),

            // ── Account Settings ─────────────────────────────────────────
            SettingsSection(
              title: 'ACCOUNT SETTINGS',
              items: [
                SettingItemData(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage alerts and activity',
                ),
                SettingItemData(
                  icon: Icons.lock_outline,
                  title: 'Privacy & Security',
                  subtitle: 'Password, 2FA, and data sharing',
                ),
                SettingItemData(
                  icon: Icons.storage_outlined,
                  title: 'Account Data',
                  subtitle: 'Export or manage your personal data',
                ),
              ],
            ),
            SizedBox(height: context.heightCalculated(24)),

            // ── Support ──────────────────────────────────────────────────
            SettingsSection(
              title: 'SUPPORT',
              items: [
                SettingItemData(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                ),
              ],
            ),
            SizedBox(height: context.heightCalculated(32)),

            // ── Logout ───────────────────────────────────────────────────
            const LogoutButton(),
            SizedBox(height: context.heightCalculated(24)),
          ],
        ),
      ),
    );
  }
}
