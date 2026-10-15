import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    this.controller,
    this.focusNode,
    required this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
    this.autofillHints,
    this.onFieldSubmitted,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String label;
  final String? hint;
  final String? helperText;
  final Widget? prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool readOnly;
  final Iterable<String>? autofillHints;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscureText,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofillHints: widget.autofillHints,
      onFieldSubmitted: widget.onFieldSubmitted,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon != null
            ? SizedBox(
                width: Responsive.adapt(48),
                height: Responsive.adapt(48),
                child: widget.prefixIcon,
              )
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: colors.textSecondary,
                  size: Responsive.adapt(24),
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
                tooltip: _obscureText ? 'Show password' : 'Hide password',
              )
            : widget.suffixIcon,
        counterText: '',
      ),
    );
  }
}
