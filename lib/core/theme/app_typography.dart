import 'package:flutter/material.dart';

abstract class AppTypography {
  // Display (히어로 섹션)
  static TextStyle displayLarge(Color color) => TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
        color: color,
      );

  // Headline (섹션 제목)
  static TextStyle headlineLarge(Color color) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: color,
      );

  static TextStyle headlineMedium(Color color) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: color,
      );

  // Title (카드 제목)
  static TextStyle titleLarge(Color color) => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
        color: color,
      );

  static TextStyle titleMedium(Color color) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.24,
        color: color,
      );

  // Body (본문)
  static TextStyle bodyLarge(Color color) => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.41,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium(Color color) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.24,
        height: 1.4,
        color: color,
      );

  // Caption (부가 정보)
  static TextStyle caption(Color color) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.08,
        color: color,
      );

  static TextStyle captionSmall(Color color) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.07,
        color: color,
      );
}
