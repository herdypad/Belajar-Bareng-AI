import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/mobile_shell.dart';
import 'review_controller.dart';

class ReviewView extends GetView<ReviewController> {
  const ReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MobileShell(
          child: Column(
            children: [
              _header(context),
              _progress(context),
              Expanded(child: _questionArea(context)),
              _bottomNav(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          CircleIconButton(icon: Icons.close, onTap: Get.back),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Review Jawaban',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _progress(BuildContext context) {
    final s = context.surfaces;
    return Obx(() {
      final cur = controller.currentIndex.value + 1;
      final tot = controller.quiz.totalQuestions;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Text('Soal $cur dari $tot',
                style: TextStyle(fontSize: 13, color: s.muted)),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: cur / tot,
                  backgroundColor: s.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _questionArea(BuildContext context) {
    return Obx(() {
      final qIndex = controller.currentIndex.value;
      final question = controller.quiz.questions[qIndex];
      final userAnswer = controller.result.userAnswers[qIndex];
      
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Text(
              question.question,
              style: const TextStyle(
                  fontSize: 18, height: 1.5, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(question.options.length, (optIdx) {
            final isCorrect = optIdx == question.correctIndex;
            final isUserSelected = optIdx == userAnswer;
            
            Color bgColor = context.surfaces.card;
            Color borderColor = context.surfaces.border;
            Color textColor = context.surfaces.muted;
            IconData? trailingIcon;
            
            if (isCorrect) {
              bgColor = AppColors.success.withValues(alpha: 0.1);
              borderColor = AppColors.success;
              textColor = AppColors.success;
              trailingIcon = Icons.check_circle;
            } else if (isUserSelected && !isCorrect) {
              bgColor = AppColors.danger.withValues(alpha: 0.1);
              borderColor = AppColors.danger;
              textColor = AppColors.danger;
              trailingIcon = Icons.cancel;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCorrect || (isUserSelected && !isCorrect) 
                            ? textColor 
                            : context.surfaces.border,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        String.fromCharCode(65 + optIdx),
                        style: TextStyle(
                            color: isCorrect || (isUserSelected && !isCorrect)
                                ? Colors.white
                                : context.surfaces.muted,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        question.options[optIdx],
                        style: TextStyle(
                          fontSize: 15,
                          color: context.theme.colorScheme.onSurface,
                          fontWeight: (isCorrect || isUserSelected) 
                              ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (trailingIcon != null)
                      Icon(trailingIcon, color: textColor, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppColors.warning, size: 20),
                    SizedBox(width: 8),
                    Text('Penjelasan', 
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question.explanation,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _bottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaces.card,
        border: Border(top: BorderSide(color: context.surfaces.border)),
      ),
      child: Obx(() {
        final cur = controller.currentIndex.value;
        final tot = controller.quiz.totalQuestions;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: cur > 0 ? controller.prev : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Sebelumnya'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: context.surfaces.border,
                  foregroundColor: context.theme.colorScheme.onSurface),
            ),
            ElevatedButton(
              onPressed: cur < tot - 1 ? controller.next : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              child: const Row(
                children: [Text('Selanjutnya'), SizedBox(width: 8), Icon(Icons.arrow_forward)],
              ),
            ),
          ],
        );
      }),
    );
  }
}
