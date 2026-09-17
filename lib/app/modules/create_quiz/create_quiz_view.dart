import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/mobile_shell.dart';
import 'create_quiz_controller.dart';

class CreateQuizView extends GetView<CreateQuizController> {
  const CreateQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveBreakpoints.isTabletOrLarger(context);

    return Scaffold(
      body: SafeArea(
        child: MobileShell(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 32 : 20,
              24,
              isTablet ? 32 : 20,
              32,
            ),
            children: [
              Row(
                children: [
                  CircleIconButton(
                      icon: Icons.arrow_back, onTap: Get.back),
                  const SizedBox(width: 12),
                  Text(
                    'Buat Kuis Baru',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _topicCard(context),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _paramsCard(context),
                          const SizedBox(height: 16),
                          _infoBox(context),
                          const SizedBox(height: 20),
                          _generateButton(),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _formCard(context),
                const SizedBox(height: 20),
                _infoBox(context),
                const SizedBox(height: 20),
                _generateButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _topicCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, Icons.auto_awesome, 'Topik / Deskripsi'),
          const SizedBox(height: 8),
          TextField(
            controller: controller.topicCtrl,
            onChanged: controller.setTopic,
            maxLines: 6,
            decoration: _inputDecoration(
                context, 'Contoh: Sejarah perang dunia ke-2 di Asia Pasifik'),
          ),
          const SizedBox(height: 16),
          _fileUploadSection(context),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CreateQuizController.suggestions
                .map((sug) => _suggestionChip(context, sug))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _paramsCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengaturan Kuis',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          _paramsRow(context),
        ],
      ),
    );
  }

  Widget _formCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, Icons.auto_awesome, 'Topik / Deskripsi'),
          const SizedBox(height: 8),
          TextField(
            controller: controller.topicCtrl,
            onChanged: controller.setTopic,
            maxLines: 4,
            decoration: _inputDecoration(
                context, 'Contoh: Sejarah perang dunia ke-2 di Asia Pasifik'),
          ),
          const SizedBox(height: 12),
          _fileUploadSection(context),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CreateQuizController.suggestions
                .map((sug) => _suggestionChip(context, sug))
                .toList(),
          ),
          const SizedBox(height: 20),
          _paramsRow(context),
        ],
      ),
    );
  }

  Widget _paramsRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label(context, Icons.tag, 'Jumlah Soal'),
              const SizedBox(height: 8),
              TextField(
                controller: controller.countCtrl,
                onChanged: controller.setCount,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: _inputDecoration(context, '10'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label(context, Icons.schedule, 'Waktu (menit)'),
              const SizedBox(height: 8),
              TextField(
                controller: controller.minutesCtrl,
                onChanged: controller.setMinutes,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: _inputDecoration(context, '15'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label(BuildContext context, IconData icon, String text) {
    final s = context.surfaces;
    return Row(
      children: [
        Icon(icon, size: 16, color: s.accent),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _fileUploadSection(BuildContext context) {
    final s = context.surfaces;
    return Obx(() {
      final file = controller.uploadedFile.value;
      if (file != null) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.attach_file, size: 18, color: s.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  file.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: controller.clearFile,
                child: Icon(Icons.close, size: 18, color: s.accent),
              ),
            ],
          ),
        );
      }

      return OutlinedButton.icon(
        onPressed: controller.pickFile,
        icon: const Icon(Icons.upload_file, size: 18),
        label: const Text('Upload File (.txt, .md, .pdf)'),
        style: OutlinedButton.styleFrom(
          foregroundColor: s.accent,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    });
  }

  Widget _suggestionChip(BuildContext context, String text) {
    final s = context.surfaces;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => controller.setTopic(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
        ),
        child: Text(text,
            style: TextStyle(fontSize: 11, color: s.accent, fontWeight: FontWeight.w500)),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final s = context.surfaces;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: s.input,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: s.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _infoBox(BuildContext context) {
    final s = context.surfaces;
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
        child: Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 12, color: s.muted),
            children: [
              const TextSpan(text: '💡 AI akan membuat '),
              TextSpan(
                text: '${controller.count.value} soal pilihan ganda',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              const TextSpan(
                  text:
                      ' berdasarkan topik atau file yang kamu upload, lengkap dengan penjelasan untuk review.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _generateButton() {
    return Obx(
      () => SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed:
              (!controller.valid || controller.loading.value) ? null : controller.generate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999)),
          ),
          child: controller.loading.value
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Text('AI sedang membuat soal...',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 18),
                    SizedBox(width: 8),
                    Text('Generate Kuis',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
        ),
      ),
    );
  }
}
