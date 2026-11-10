import 'package:flutter/material.dart';

import 'package:campusfix/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.matcha,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.matchaMist,
      onPrimaryContainer: AppColors.matchaDeep,
      secondary: AppColors.matchaBright,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.matchaSoft,
      onSecondaryContainer: AppColors.matchaDeep,
      error: AppColors.danger,
      onError: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkMuted,
      surfaceContainerHighest: AppColors.matchaMist,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final radius12 = BorderRadius.circular(12);
    final radius14 = BorderRadius.circular(14);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius12,
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.white,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceTint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: inputBorder(AppColors.border),
        enabledBorder: inputBorder(AppColors.border),
        focusedBorder: inputBorder(AppColors.matcha, 1.6),
        errorBorder: inputBorder(AppColors.danger),
        focusedErrorBorder: inputBorder(AppColors.danger, 1.6),
        labelStyle: const TextStyle(color: AppColors.inkMuted),
        hintStyle: const TextStyle(color: AppColors.inkMuted),
        prefixIconColor: AppColors.inkMuted,
        suffixIconColor: AppColors.inkMuted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.matcha,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.matchaSoft,
          disabledForegroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radius14),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.matcha,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.matcha),
          shape: RoundedRectangleBorder(borderRadius: radius14),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.matcha,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.matchaMist,
        disabledColor: AppColors.surfaceTint,
        checkmarkColor: AppColors.matchaDeep,
        side: const BorderSide(color: AppColors.border),
        labelStyle: const TextStyle(color: AppColors.ink, fontSize: 13),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.matchaMist
                : AppColors.white,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.matchaDeep
                : AppColors.inkMuted,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.border),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.matchaMist,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.matchaDeep
                : AppColors.inkMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.matchaDeep
                : AppColors.inkMuted,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.matcha,
        foregroundColor: AppColors.white,
        elevation: 2,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.white
              : AppColors.inkMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.matcha
              : AppColors.matchaMist,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.matchaDeep,
        contentTextStyle: TextStyle(color: AppColors.white),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.matcha,
        linearTrackColor: AppColors.matchaMist,
      ),
    );
  }
}
