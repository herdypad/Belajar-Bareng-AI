import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:belajar_bareng_ai/app/data/services/settings_service.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String>{};

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == 'write') {
        final args = call.arguments as Map<dynamic, dynamic>;
        storage[args['key'] as String] = args['value'] as String;
        return null;
      }
      if (call.method == 'read') {
        final args = call.arguments as Map<dynamic, dynamic>;
        return storage[args['key'] as String];
      }
      return null;
    });
  });

  group('SettingsService Theme Tests', () {
    test('Initial theme defaults to dark mode', () {
      final settings = SettingsService();
      expect(settings.themeSetting.value, AppThemeSetting.dark);
      expect(settings.darkMode.value, isTrue);
      expect(settings.currentThemeMode, ThemeMode.dark);
    });

    test('setTheme switches to light and system properly', () {
      final settings = SettingsService();
      
      settings.setTheme(AppThemeSetting.light);
      expect(settings.themeSetting.value, AppThemeSetting.light);
      expect(settings.darkMode.value, isFalse);
      expect(settings.currentThemeMode, ThemeMode.light);

      settings.setTheme(AppThemeSetting.system);
      expect(settings.themeSetting.value, AppThemeSetting.system);
      expect(settings.darkMode.value, isFalse);
      expect(settings.currentThemeMode, ThemeMode.system);
    });

    test('toggleDarkMode toggles between dark and light', () {
      final settings = SettingsService();
      expect(settings.isDarkModeActive, isTrue);

      settings.toggleDarkMode();
      expect(settings.themeSetting.value, AppThemeSetting.light);
      expect(settings.isDarkModeActive, isFalse);

      settings.toggleDarkMode();
      expect(settings.themeSetting.value, AppThemeSetting.dark);
      expect(settings.isDarkModeActive, isTrue);
    });

    test('load restores persisted theme setting', () async {
      storage['themeSetting'] = 'light';
      final settings = SettingsService();
      await settings.load();
      expect(settings.themeSetting.value, AppThemeSetting.light);
      expect(settings.darkMode.value, isFalse);
      expect(settings.currentThemeMode, ThemeMode.light);

      storage['themeSetting'] = 'system';
      final settings2 = SettingsService();
      await settings2.load();
      expect(settings2.themeSetting.value, AppThemeSetting.system);
      expect(settings2.currentThemeMode, ThemeMode.system);
    });
  });
}
