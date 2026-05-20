import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return _build(
      brightness: Brightness.light,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      surfaceVariant: AppColors.lightSurfaceVariant,
      border: AppColors.lightBorder,
      primaryText: AppColors.lightTextPrimary,
      secondaryText: AppColors.lightTextSecondary,
      accent: AppColors.lightAccent,
    );
  }

  static ThemeData dark() {
    return _build(
      brightness: Brightness.dark,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      surfaceVariant: AppColors.darkSurfaceVariant,
      border: AppColors.darkBorder,
      primaryText: AppColors.darkTextPrimary,
      secondaryText: AppColors.darkTextSecondary,
      accent: AppColors.darkAccent,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color border,
    required Color primaryText,
    required Color secondaryText,
    required Color accent,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      primary: accent,
      surface: surface,
      surfaceContainerHighest: surfaceVariant,
    );

    final textTheme = Typography.material2021().black.apply(
      bodyColor: primaryText,
      displayColor: primaryText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      dividerColor: border,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: background,
        foregroundColor: primaryText,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
      ),
      extensions: [
        LanggengColors(
          border: border,
          secondaryText: secondaryText,
          surfaceVariant: surfaceVariant,
        ),
      ],
    );
  }
}

class LanggengColors extends ThemeExtension<LanggengColors> {
  const LanggengColors({
    required this.border,
    required this.secondaryText,
    required this.surfaceVariant,
  });

  final Color border;
  final Color secondaryText;
  final Color surfaceVariant;

  @override
  LanggengColors copyWith({
    Color? border,
    Color? secondaryText,
    Color? surfaceVariant,
  }) {
    return LanggengColors(
      border: border ?? this.border,
      secondaryText: secondaryText ?? this.secondaryText,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
    );
  }

  @override
  LanggengColors lerp(ThemeExtension<LanggengColors>? other, double t) {
    if (other is! LanggengColors) {
      return this;
    }

    return LanggengColors(
      border: Color.lerp(border, other.border, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
    );
  }
}
