import 'package:flutter/material.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class CreateAlbumDialog extends StatefulWidget {
  final void Function(String name) onCreate;

  const CreateAlbumDialog({super.key, required this.onCreate});

  @override
  State<CreateAlbumDialog> createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<CreateAlbumDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppThemeMetrics.radiusLg),
      ),
      title: Text(
        'Create Album',
        style: tt.titleLarge?.copyWith(
          color: context.colors.primaryText,
        ),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: 50,
          style: tt.bodyLarge?.copyWith(
            color: context.colors.primaryText,
          ),
          decoration: InputDecoration(
            hintText: 'Album name',
            hintStyle: tt.bodyLarge?.copyWith(
              color: context.colors.hintText,
            ),
            filled: true,
            fillColor: context.colors.inputFill,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppThemeMetrics.radiusMd),
              borderSide: BorderSide(
                color: context.colors.inputBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppThemeMetrics.radiusMd),
              borderSide: BorderSide(
                color: context.colors.inputBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppThemeMetrics.radiusMd),
              borderSide: BorderSide(
                color: cs.primary,
                width: AppThemeMetrics.borderFocus,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an album name';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: tt.bodyMedium?.copyWith(
              color: context.colors.secondaryText,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onCreate(_controller.text.trim());
              Navigator.of(context).pop();
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppThemeMetrics.radiusMd),
            ),
          ),
          child: Text('Create'),
        ),
      ],
    );
  }
}
