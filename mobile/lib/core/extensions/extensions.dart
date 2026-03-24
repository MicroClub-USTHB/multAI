import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'dart:math';

extension StringExtension on String {
  String get capitalize {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String get capitalizeFirstofEach {
    return split(" ").map((str) => str.capitalize).join(" ");
  }
}

extension ThemeExtension on BuildContext {
  ThemeData get theme {
    return Theme.of(this);
  }
}

extension MediaQueryExtension on BuildContext {
  MediaQueryData get mediaQuery {
    return MediaQuery.of(this);
  }
}

extension SizeExtension on BuildContext {
  Size get size {
    return MediaQuery.of(this).size;
  }
}

extension WidthExtension on BuildContext {
  double get width {
    return MediaQuery.of(this).size.width;
  }
}

extension HeightExtension on BuildContext {
  double get height {
    return MediaQuery.of(this).size.height;
  }
}

extension TextThemeExtension on BuildContext {
  TextTheme get textTheme {
    return Theme.of(this).textTheme;
  }
}

extension FucusOff on BuildContext {
  void unfocus() {
    FocusScope.of(this).unfocus();
  }
}

extension GetArgs on BuildContext {
  T getArgs<T>() {
    final data =
        ModalRoute.of(this)!.settings.arguments as Map<String, dynamic>;
    return data["data"] as T;
  }
}

extension OrientationExtension on BuildContext {
  Orientation get orientation {
    return MediaQuery.of(this).orientation;
  }
}

extension Calculator on BuildContext {
  double heightCalculated(double height) {
    return height * MediaQuery.of(this).size.height / 852;
  }

  double widthCalculated(double width) {
    return width * MediaQuery.of(this).size.width / 393;
  }
}

extension SnackBarExtension on BuildContext {
  void showErrorSnackBar(String message) {
    final tt = Theme.of(this).textTheme;
    final cs = Theme.of(this).colorScheme;
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: tt.bodySmall?.copyWith(color: cs.onError),
          ),
          backgroundColor: cs.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          margin: const EdgeInsets.all(AppTheme.spacingMd),
        ),
      );
  }

  void showSuccessSnackBar(String message) {
    final tt = Theme.of(this).textTheme;
    final cs = Theme.of(this).colorScheme;

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: tt.bodySmall?.copyWith(color: cs.onPrimary),
          ),
          backgroundColor: cs.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          margin: const EdgeInsets.all(AppTheme.spacingMd),
        ),
      );
  }
}

extension ResponsiveExtension on BuildContext {
  double hPadding() =>
      (width * 0.06).clamp(AppTheme.spacingLg, AppTheme.spacingXxl);

  double cardMaxWidth() => min(width * 0.92, 480.0);

  double logoSize() => (width * 0.15).clamp(56.0, 88.0);

  double titleFontSize() => (width * 0.07).clamp(22.0, 32.0);

  double sectionSpacing() => height * 0.02;

  // ── icon size — scales with screen width ──────────────────────────────────
  double iconSize() => (width * 0.055).clamp(20.0, 26.0);

  // ── border radius — scales with screen width ──────────────────────────────
  double radius() => (width * 0.03).clamp(AppTheme.radiusSm, AppTheme.radiusMd);
}


 
