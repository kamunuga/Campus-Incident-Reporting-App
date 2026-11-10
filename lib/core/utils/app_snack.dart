import 'package:flutter/material.dart';

import 'package:campusfix/core/theme/app_colors.dart';

class AppSnack {
  AppSnack._();

  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.matchaDeep, Icons.check_circle_outline);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.danger, Icons.error_outline);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.matcha, Icons.info_outline);

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
