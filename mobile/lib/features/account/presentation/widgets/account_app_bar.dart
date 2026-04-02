import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';

class AccountAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AccountAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.theme.colorScheme.onSurface),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: Text(
        'Account',
        style: tt.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryTextColor,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}