import 'package:flutter/material.dart';

abstract class AppComponents {
  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;

  // 카드 크기
  static const double movieCardWidth = 160.0;
  static const double movieCardHeight = 240.0;
  static const double movieCardAspectRatio = 0.67;

  // 애니메이션
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 450);

  // 스케일 효과
  static const double scalePressed = 0.96;
  static const double scaleNormal = 1.0;

  // 그림자 (Apple TV+: 없음)
  static const List<BoxShadow> cardShadow = [];
}
