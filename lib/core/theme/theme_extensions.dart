import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

extension ThemeExtensions on BuildContext {
  // 색상 접근 헬퍼
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  DarkColors get darkColors => AppColors.dark;
  LightColors get lightColors => AppColors.light;

  // 현재 테마에 맞는 색상
  Color get backgroundColor =>
      isDark ? darkColors.background : lightColors.background;
  Color get surfaceColor => isDark ? darkColors.surface : lightColors.surface;
  Color get surfaceVariantColor =>
      isDark ? darkColors.surfaceVariant : lightColors.surfaceVariant;
  Color get textPrimaryColor =>
      isDark ? darkColors.textPrimary : lightColors.textPrimary;
  Color get textSecondaryColor =>
      isDark ? darkColors.textSecondary : lightColors.textSecondary;
  Color get textTertiaryColor =>
      isDark ? darkColors.textTertiary : lightColors.textTertiary;
  Color get accentColor => isDark ? darkColors.accent : lightColors.accent;
  Color get errorColor => isDark ? darkColors.error : lightColors.error;
  Color get overlayColor => isDark ? darkColors.overlay : lightColors.overlay;
  Color get dividerColor => isDark ? darkColors.divider : lightColors.divider;

  // 타이포그래피 헬퍼
  TextStyle get displayLarge => AppTypography.displayLarge(textPrimaryColor);
  TextStyle get headlineLarge => AppTypography.headlineLarge(textPrimaryColor);
  TextStyle get headlineMedium =>
      AppTypography.headlineMedium(textPrimaryColor);
  TextStyle get titleLarge => AppTypography.titleLarge(textPrimaryColor);
  TextStyle get titleMedium => AppTypography.titleMedium(textPrimaryColor);
  TextStyle get bodyLarge => AppTypography.bodyLarge(textPrimaryColor);
  TextStyle get bodyMedium => AppTypography.bodyMedium(textPrimaryColor);
  TextStyle get caption => AppTypography.caption(textSecondaryColor);
  TextStyle get captionSmall => AppTypography.captionSmall(textTertiaryColor);
}
