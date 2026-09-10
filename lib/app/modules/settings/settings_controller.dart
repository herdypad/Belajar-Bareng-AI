import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/settings_service.dart';

class SettingsController extends GetxController {
  final SettingsService _settings = Get.find();

  late final TextEditingController apiKeyCtrl;
  late final TextEditingController baseUrlCtrl;
  late final TextEditingController modelCtrl;

  @override
  void onInit() {
    super.onInit();
    apiKeyCtrl = TextEditingController(text: _settings.apiKey.value);
    baseUrlCtrl = TextEditingController(text: _settings.baseUrl.value);
    modelCtrl = TextEditingController(text: _settings.model.value);
  }

  @override
  void onClose() {
    apiKeyCtrl.dispose();
    baseUrlCtrl.dispose();
    modelCtrl.dispose();
    super.onClose();
  }

  SettingsService get settings => _settings;

  void changeProvider(AiVendor vendor) {
    _settings.selectProvider(vendor);
    // Sync text controllers dengan nilai default baru
    baseUrlCtrl.text = _settings.baseUrl.value;
    modelCtrl.text = _settings.model.value;
  }

  Future<void> save() async {
    _settings.apiKey.value = apiKeyCtrl.text;
    _settings.baseUrl.value = baseUrlCtrl.text;
    _settings.model.value = modelCtrl.text;
    await _settings.save();
    Get.snackbar(
      'Tersimpan',
      'Pengaturan berhasil disimpan.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF34D399),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 2),
    );
  }
}
