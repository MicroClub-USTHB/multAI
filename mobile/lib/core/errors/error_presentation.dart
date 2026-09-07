import 'package:flutter/material.dart';

enum ErrorAction { retry, signIn, goBack, none }

class ErrorPresentation {
  final String title;
  final String description;
  final String actionLabel;
  final ErrorAction action;
  final IconData illustration;

  const ErrorPresentation({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.action,
    required this.illustration,
  });
}
