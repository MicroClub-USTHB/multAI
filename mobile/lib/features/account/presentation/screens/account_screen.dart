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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.hPadding()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.sectionSpacing()),

              /// PROFILE
              const ProfileSection(),

              SizedBox(height: context.sectionSpacing()),

              /// SETTINGS
              SettingsSection(
                title: "Account Settings",
                items: [
                  SettingItemData(
                    icon: Icons.notifications_outlined,
                    title: "Notifications",
                  ),
                  SettingItemData(
                    icon: Icons.lock_outline,
                    title: "Privacy",
                  ),
                  SettingItemData(
                    icon: Icons.security,
                    title: "Security",
                  ),
                  SettingItemData(
                    icon: Icons.person_outline,
                    title: "Account",
                  ),
                  SettingItemData(
                    icon: Icons.storage,
                    title: "Data",
                  ),
                ],
              ),

              SizedBox(height: context.sectionSpacing()),

              /// HELP
              SettingsSection(
                title: "Support",
                items: [
                  SettingItemData(
                    icon: Icons.help_outline,
                    title: "Help Center",
                  ),
                ],
              ),

              SizedBox(height: context.sectionSpacing()),

              /// LOGOUT
              const LogoutButton(),

              SizedBox(height: context.sectionSpacing()),
            ],
          ),
        ),
      ),
    );
  }
}
