import 'package:flutter/material.dart';

import 'package:campusfix/core/theme/app_colors.dart';

enum AppButtonVariant { filled, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final spinnerColor =
        variant == AppButtonVariant.filled ? AppColors.white : AppColors.matcha;

    final child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: spinnerColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final callback = isLoading ? null : onPressed;

    return switch (variant) {
      AppButtonVariant.filled =>
        FilledButton(onPressed: callback, child: child),
      AppButtonVariant.outlined =>
        OutlinedButton(onPressed: callback, child: child),
      AppButtonVariant.text => TextButton(onPressed: callback, child: child),
    };
  }
}
