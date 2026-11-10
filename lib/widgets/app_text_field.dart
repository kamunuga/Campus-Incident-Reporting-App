import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscure = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscure;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _hidden,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      minLines: widget.maxLines > 1 ? 3 : null,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      autofillHints: widget.autofillHints,
      textCapitalization: widget.textCapitalization,
      onFieldSubmitted: widget.onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        alignLabelWithHint: widget.maxLines > 1,
        prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
        suffixIcon: widget.obscure
            ? IconButton(
                tooltip: _hidden ? 'Show password' : 'Hide password',
                icon: Icon(
                  _hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}
