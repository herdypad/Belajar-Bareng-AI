import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/ai_provider.dart';
import '../providers/anthropic_provider.dart';
import '../providers/openai_provider.dart';

enum AiVendor { anthropic, openai }

enum AppThemeSetting { light, dark, system }

/// Menyimpan & menyediakan pengaturan AI & tampilan. API key disimpan di secure storage.
class SettingsService extends GetxService {
  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  final provider = AiVendor.openai.obs;
  final model = 'gpt-4o-mini'.obs;
  final baseUrl = 'https://api.openai.com/v1'.obs;
  final apiKey = ''.obs;
  final themeSetting = AppThemeSetting.dark.obs;
  final darkMode = true.obs;
  final isTestingConnection = false.obs;

  static const _kProvider = 'provider';
  static const _kModel = 'model';
  static const _kBaseUrl = 'baseUrl';
  static const _kApiKey = 'apiKey';
  static const _kDark = 'darkMode';
  static const _kTheme = 'themeSetting';

  ThemeMode get currentThemeMode {
    switch (themeSetting.value) {
      case AppThemeSetting.light:
        return ThemeMode.light;
      case AppThemeSetting.dark:
        return ThemeMode.dark;
      case AppThemeSetting.system:
        return ThemeMode.system;
    }
  }

  bool get isDarkModeActive {
    if (themeSetting.value == AppThemeSetting.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return themeSetting.value == AppThemeSetting.dark;
  }

  void toggleDarkMode() {
    if (isDarkModeActive) {
      setTheme(AppThemeSetting.light);
    } else {
      setTheme(AppThemeSetting.dark);
    }
  }

  void setTheme(AppThemeSetting setting) {
    themeSetting.value = setting;
    darkMode.value = setting == AppThemeSetting.dark;
    save();
    Get.changeThemeMode(currentThemeMode);
  }

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    
    final p = await _read(_kProvider);
    if (p == 'openai') {
      provider.value = AiVendor.openai;
    } else if (p == 'anthropic') {
      provider.value = AiVendor.anthropic;
    }
    // Preserve defaults if nothing saved
    model.value = await _read(_kModel) ?? model.value;
    baseUrl.value = await _read(_kBaseUrl) ?? baseUrl.value;
    apiKey.value = await _read(_kApiKey) ?? apiKey.value;

    final t = await _read(_kTheme);
    if (t == 'light') {
      themeSetting.value = AppThemeSetting.light;
      darkMode.value = false;
    } else if (t == 'system') {
      themeSetting.value = AppThemeSetting.system;
      darkMode.value = false;
    } else if (t == 'dark') {
      themeSetting.value = AppThemeSetting.dark;
      darkMode.value = true;
    } else {
      final d = await _read(_kDark);
      if (d != null) {
        final isDark = d == 'true';
        darkMode.value = isDark;
        themeSetting.value = isDark ? AppThemeSetting.dark : AppThemeSetting.light;
      }
    }
    Get.changeThemeMode(currentThemeMode);
  }

  Future<void> save() async {
    await _write(_kProvider, provider.value == AiVendor.openai ? 'openai' : 'anthropic');
    await _write(_kModel, model.value);
    await _write(_kBaseUrl, baseUrl.value);
    await _write(_kApiKey, apiKey.value);
    await _write(_kDark, (themeSetting.value == AppThemeSetting.dark).toString());
    await _write(_kTheme, themeSetting.value.name);
  }
  
  Future<String?> _read(String key) async {
    if (kIsWeb) {
      return _prefs?.getString(key);
    }
    return await _secureStorage.read(key: key);
  }
  
  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      await _prefs?.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  void selectProvider(AiVendor v) {
    provider.value = v;
    if (v == AiVendor.anthropic) {
      model.value = 'claude-3-5-sonnet';
      baseUrl.value = 'https://api.anthropic.com/v1';
    } else {
      model.value = 'gpt-4o-mini';
      baseUrl.value = 'https://api.openai.com/v1';
    }
  }

  /// Membangun provider AI aktif berdasarkan pengaturan saat ini.
  AiProvider buildProvider() {
    if (provider.value == AiVendor.openai) {
      return OpenAiProvider(
          apiKey: apiKey.value, model: model.value, baseUrl: baseUrl.value);
    }
    return AnthropicProvider(
        apiKey: apiKey.value, model: model.value, baseUrl: baseUrl.value);
  }

  Future<void> testConnection() async {
    isTestingConnection.value = true;
    try {
      final ai = buildProvider();
      final success = await ai.testConnection();
      if (success) {
        Get.snackbar(
          'Berhasil',
          'Koneksi ke AI Provider sukses!',
          backgroundColor: const Color(0xFF34D399),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
        );
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (kDebugMode) {
        print('Test connection error: $errorMsg');
      }
      // Limit error message to 200 chars to prevent overflow
      final displayMsg = errorMsg.length > 200
          ? '${errorMsg.substring(0, 200)}...'
          : errorMsg;
      Get.snackbar(
        'Gagal',
        displayMsg,
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        maxWidth: 400,
      );
    } finally {
      isTestingConnection.value = false;
    }
  }
}
