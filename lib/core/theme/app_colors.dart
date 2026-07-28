import 'package:flutter/material.dart';

abstract class AppColors {
  static const dark = DarkColors();
  static const light = LightColors();
}

class DarkColors {
  const DarkColors();

  // 배경
  Color get background => const Color(0xFF000000);
  Color get surface => const Color(0xFF1C1C1E);
  Color get surfaceVariant => const Color(0xFF2C2C2E);

  // 텍스트
  Color get textPrimary => const Color(0xFFFFFFFF);
  Color get textSecondary => const Color(0xFF8E8E93);
  Color get textTertiary => const Color(0xFF636366);

  // 액센트
  Color get accent => const Color(0xFFFFFFFF);
  Color get accentSecondary => const Color(0xFF8E8E93);

  // 상태
  Color get error => const Color(0xFFFF453A);

  // 오버레이
  Color get overlay => const Color(0x99000000);
  Color get overlayLight => const Color(0x4D000000);

  // 구분선
  Color get divider => const Color(0xFF38383A);
}

class LightColors {
  const LightColors();

  // 배경
  Color get background => const Color(0xFFFFFFFF);
  Color get surface => const Color(0xFFF2F2F7);
  Color get surfaceVariant => const Color(0xFFE5E5EA);

  // 텍스트
  Color get textPrimary => const Color(0xFF000000);
  Color get textSecondary => const Color(0xFF8E8E93);
  Color get textTertiary => const Color(0xFFAEAEB2);

  // 액센트
  Color get accent => const Color(0xFF000000);
  Color get accentSecondary => const Color(0xFF8E8E93);

  // 상태
  Color get error => const Color(0xFFFF3B30);

  // 오버레이
  Color get overlay => const Color(0x99FFFFFF);
  Color get overlayLight => const Color(0x4DFFFFFF);

  // 구분선
  Color get divider => const Color(0xFFD1D1D6);
}
