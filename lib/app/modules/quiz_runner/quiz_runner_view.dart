import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/mobile_shell.dart';
import 'quiz_runner_controller.dart';

class QuizRunnerView extends GetView<QuizRunnerController> {
  const QuizRunnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await controller.confirmExit()) Get.back();
      },
      child: Scaffold(
        body: SafeArea(
          child: MobileShell(
            child: Obx(() {
              if (controller.total == 0) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  _topBar(context),
                  Expanded(child: _questionArea(context)),
                  _bottomNav(context),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    final s = context.surfaces;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: s.border)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleIconButton(
                icon: Icons.arrow_back,
                onTap: () async {
                  if (await controller.confirmExit()) Get.back();
                },
              ),
              _timerChip(context),
              CircleIconButton(
                icon: Icons.flag_outlined,
                onTap: controller.toggleFlag,
                background: controller.flagged.contains(controller.currentIndex.value)
                    ? AppColors.warning.withValues(alpha: 0.20)
                    : null,
                foreground: controller.flagged.contains(controller.currentIndex.value)
                    ? AppColors.warning
                    : null,
                borderColor: controller.flagged.contains(controller.currentIndex.value)
                    ? AppColors.warning.withValues(alpha: 0.5)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Soal ${controller.currentIndex.value + 1} dari ${controller.total}',
                  style: TextStyle(fontSize: 12, color: s.muted)),
              Text('${controller.answeredCount}/${controller.total} terjawab',
                  style: TextStyle(fontSize: 12, color: s.accent, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: controller.progress,
              minHeight: 6,
              backgroundColor: s.input,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerChip(BuildContext context) {
    final s = context.surfaces;
    final low = controller.timeLow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: low ? AppColors.danger.withValues(alpha: 0.15) : s.card,
        border: Border.all(
            color: low ? AppColors.danger.withValues(alpha: 0.4) : s.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule,
              size: 16, color: low ? AppColors.dangerSoft : null),
          const SizedBox(width: 6),
          Text(controller.timeLabel,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [],
                  color: low ? AppColors.dangerSoft : null)),
        ],
      ),
    );
  }

  Widget _questionArea(BuildContext context) {
    final q = controller.quiz.questions[controller.currentIndex.value];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Text(q.question,
              style: const TextStyle(
                  fontSize: 16, height: 1.5, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 20),
        ...List.generate(q.options.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _optionTile(context, i, q.options[i]),
            )),
      ],
    );
  }

  Widget _optionTile(BuildContext context, int i, String text) {
    final s = context.surfaces;
    final selected = controller.answers[controller.currentIndex.value] == i;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => controller.choose(i),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? AppColors.primary.withValues(alpha: 0.15) : s.card,
          border: Border.all(
              color: selected ? AppColors.primary : s.border),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                    color: selected ? AppColors.primary : s.border),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(String.fromCharCode(65 + i),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: s.muted)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 14, height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    final s = context.surfaces;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: s.border)),
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: controller.isFirst ? null : controller.prev,
            style: OutlinedButton.styleFrom(
              backgroundColor: s.card,
              side: BorderSide(color: s.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
            child: const Icon(Icons.chevron_left, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 44,
              child: controller.isLast
                  ? ElevatedButton(
                      onPressed: () => controller.submit(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: const Color(0xFF052E21),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                      ),
                      child: const Text('Submit Jawaban',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    )
                  : ElevatedButton(
                      onPressed: controller.next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Selanjutnya',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
