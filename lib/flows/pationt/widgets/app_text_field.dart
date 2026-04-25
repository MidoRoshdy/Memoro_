import 'package:flutter/material.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/theme/app_color_palette.dart';
import '../../../l10n/app_localizations.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.hintStyle,
    this.obscureText = false,
    this.showPasswordVisibilityToggle = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.autofillHints,
    this.focusNode,
    this.labelAbove = false,
    this.labelAboveStyle,
    this.fillColor,
    this.minLines,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;

  final String? hintText;

  final TextStyle? hintStyle;

  final bool obscureText;

  /// When [obscureText] is true, shows an eye icon to show/hide the value.
  final bool showPasswordVisibilityToggle;

  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;

  /// Puts [label] above the box instead of a floating label inside the field.
  final bool labelAbove;

  /// Style for the above-label line (e.g. white on a blue gradient).
  final TextStyle? labelAboveStyle;

  /// When set, the field uses a solid fill (e.g. white).
  final Color? fillColor;
  final int? minLines;
  final int maxLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscurePassword = true;

  static const double _radius = 12;

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_radius),
    borderSide: BorderSide(color: color, width: 1.2),
  );

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obscureText && !oldWidget.obscureText) {
      _obscurePassword = true;
    }
    if (!widget.obscureText && oldWidget.obscureText) {
      _obscurePassword = true;
    }
  }

  InputDecoration _decoration(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final filled = widget.fillColor != null;
    final defaultHintStyle = theme.textTheme.bodyLarge?.copyWith(
      color: Colors.grey.shade600,
    );

    final showToggle =
        widget.obscureText && widget.showPasswordVisibilityToggle;
    final effectiveObscure = widget.obscureText && _obscurePassword;

    Widget? suffixIcon;
    if (showToggle) {
      suffixIcon = IconButton(
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        tooltip: effectiveObscure
            ? (l10n?.passwordVisibilityShow ?? 'Show password')
            : (l10n?.passwordVisibilityHide ?? 'Hide password'),
        icon: Icon(
          effectiveObscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColorPalette.blueSteel,
        ),
      );
    }

    return InputDecoration(
      labelText: widget.labelAbove ? null : widget.label,
      hintText: widget.hintText,
      hintStyle: widget.hintStyle ?? defaultHintStyle,
      floatingLabelStyle: const TextStyle(
        color: AppColorPalette.blueSteel,
        fontWeight: FontWeight.w500,
      ),
      filled: filled,
      fillColor: widget.fillColor,
      border: _border(Colors.grey.shade400),
      enabledBorder: _border(Colors.grey.shade400),
      focusedBorder: _border(AppColorPalette.blueSteel),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
      suffixIconConstraints: showToggle
          ? const BoxConstraints(minWidth: 48, minHeight: 48)
          : null,
    );
  }

  Widget _field(BuildContext context) {
    final effectiveObscure = widget.obscureText && _obscurePassword;

    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: effectiveObscure,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      autofillHints: widget.autofillHints,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColorPalette.black),
      cursorColor: AppColorPalette.blueSteel,
      decoration: _decoration(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.labelAbove) {
      return _field(context);
    }

    final theme = Theme.of(context);
    final aboveStyle =
        widget.labelAboveStyle ??
        theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: aboveStyle),
        shortVerticalSpace,
        _field(context),
      ],
    );
  }
}
