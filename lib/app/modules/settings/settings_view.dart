import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/mobile_shell.dart';
import '../../data/services/settings_service.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MobileShell(
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _themeSection(context),
                    const SizedBox(height: 24),
                    _aiSection(context),
                    const SizedBox(height: 24),
                    _saveButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          CircleIconButton(icon: Icons.arrow_back, onTap: Get.back),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Pengaturan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _themeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TAMPILAN',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.dark_mode_outlined, size: 24),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('Mode Gelap', style: TextStyle(fontSize: 16)),
              ),
              Obx(() => Switch(
                value: controller.settings.darkMode.value,
                activeThumbColor: AppColors.primary,
                onChanged: (val) {
                  controller.settings.darkMode.value = val;
                  controller.settings.save();
                },
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _aiSection(BuildContext context) {
    final s = context.surfaces;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PENGATURAN AI',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Provider AI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: _providerBtn(
                      context, 
                      'Anthropic', 
                      controller.settings.provider.value == AiVendor.anthropic,
                      () => controller.changeProvider(AiVendor.anthropic),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _providerBtn(
                      context, 
                      'OpenAI', 
                      controller.settings.provider.value == AiVendor.openai,
                      () => controller.changeProvider(AiVendor.openai),
                    ),
                  ),
                ],
              )),
              
              const SizedBox(height: 24),
              const Text('API Key', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Obx(() {
                final isAnthropic = controller.settings.provider.value == AiVendor.anthropic;
                return TextField(
                  controller: controller.apiKeyCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: isAnthropic ? 'sk-ant-...' : 'sk-...',
                    filled: true,
                    fillColor: s.input,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              const Text('URL AI (Base URL)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.baseUrlCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: s.input,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              const Text('Model', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.modelCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: s.input,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'API Key disimpan secara lokal di perangkat Anda.',
                        style: TextStyle(fontSize: 12, color: s.muted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final isTesting = controller.settings.isTestingConnection.value;
                  return ElevatedButton.icon(
                    onPressed: isTesting ? null : () async {
                      // Sync nilai dari field sebelum test
                      controller.settings.apiKey.value = controller.apiKeyCtrl.text;
                      controller.settings.baseUrl.value = controller.baseUrlCtrl.text;
                      controller.settings.model.value = controller.modelCtrl.text;
                      await controller.settings.testConnection();
                    },
                    icon: isTesting 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.wifi),
                    label: Text(isTesting ? 'Menguji...' : 'Test Koneksi'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.save,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Simpan Pengaturan'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF34D399),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _providerBtn(BuildContext context, String label, bool active, VoidCallback onTap) {
    final s = context.surfaces;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.1) : s.border,
          border: Border.all(
            color: active ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.primary : context.theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
