import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  MediaQueryData get mq => MediaQuery.of(this);

  // Use granular accessors so widgets only rebuild when the value they use
  // changes. MediaQuery.of() subscribes to everything (incl. keyboard
  // viewInsets), which rebuilds the page on every keyboard animation frame.
  Size get size => MediaQuery.sizeOf(this);

  double get width => size.width;
  double get height => size.height;

  TextTheme get textTheme => theme.textTheme;

  Orientation get orientation => MediaQuery.orientationOf(this);

  void unfocus() => FocusScope.of(this).unfocus();
}
