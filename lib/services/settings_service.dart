import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 앱 설정 저장 서비스 (테마 등)
class SettingsService {
  static const String _boxName = 'settings';
  static const String _themeModeKey = 'themeMode';

  late Box<dynamic> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// 저장된 테마 모드 가져오기
  ThemeMode getThemeMode() {
    final value = _box.get(_themeModeKey, defaultValue: 'system');
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// 테마 모드 저장
  Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _box.put(_themeModeKey, value);
  }
}
