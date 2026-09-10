import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/mobile_shell.dart';
import 'result_controller.dart';

class ResultView extends GetView<ResultController> {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.surfaces;
    return Scaffold(
      body: SafeArea(
        child: MobileShell(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            children: [
              _scoreRing(context),
              const SizedBox(height: 16),
              Text(controller.verdict,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(controller.quiz.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: s.muted)),
              const SizedBox(height: 20),
              _statsRow(context),
              const SizedBox(height: 24),
              _actions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreRing(BuildContext context) {
    final s = context.surfaces;
    return Center(
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: controller.percentage / 100,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                backgroundColor: s.input,
                valueColor:
                    AlwaysStoppedAnimation<Color>(controller.ringColor),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${controller.percentage}%',
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1)),
                Text('Skor kamu',
                    style: TextStyle(fontSize: 12, color: s.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _statCard(context, Icons.check_circle_outline,
              AppColors.success, '${controller.correct}', 'Benar'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(context, Icons.cancel_outlined, AppColors.danger,
              '${controller.wrong}', 'Salah'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(context, Icons.schedule, AppColors.lilac,
              controller.timeLabel, 'Waktu'),
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context, IconData icon, Color color,
      String value, String label) {
    final s = context.surfaces;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(label, style: TextStyle(fontSize: 11, color: s.muted)),
        ],
      ),
    );
  }

  Widget _actions() {
    final s = Get.context!.surfaces;
    return Column(
      children: [
        SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.goReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
            ),
            icon: const Icon(Icons.menu_book_outlined, size: 18),
            label: const Text('Review Jawaban',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: controller.retry,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: s.card,
                    side: BorderSide(color: s.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Coba Lagi'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: controller.goHome,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: s.card,
                    side: BorderSide(color: s.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                  ),
                  icon: const Icon(Icons.home_outlined, size: 18),
                  label: const Text('Beranda'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
