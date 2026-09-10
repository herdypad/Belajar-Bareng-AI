import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/mobile_shell.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.surfaces;
    return Scaffold(
      body: SafeArea(
        child: MobileShell(
          child: Obx(
            () => ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                _header(context),
                const SizedBox(height: 24),
                _heroCta(context),
                const SizedBox(height: 24),
                _stats(context),
                const SizedBox(height: 24),
                _recentHeader(context),
                const SizedBox(height: 12),
                if (controller.quizzes.isEmpty)
                  _emptyState(context, s.muted)
                else
                  ...controller.quizzes
                      .take(4)
                      .map((q) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _quizTile(context, q),
                          )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final s = context.surfaces;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, selamat belajar',
                  style: TextStyle(fontSize: 13, color: s.muted)),
              const SizedBox(height: 4),
              const Text('Belajar Bareng AI ✨',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5)),
            ],
          ),
        ),
        Obx(() {
          final isDark = controller.settings.isDarkModeActive;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleIconButton(
                icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                onTap: controller.settings.toggleDarkMode,
              ),
              const SizedBox(width: 8),
              CircleIconButton(
                  icon: Icons.settings_outlined, onTap: controller.goSettings),
            ],
          );
        }),
      ],
    );
  }

  Widget _heroCta(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_outlined,
                    size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text('AI Generator',
                  style: TextStyle(
                      fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Buat kuis pintar\ndari topik apa saja',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.25,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Tulis topik, atur waktu, lalu mulai latihan.',
              style: TextStyle(
                  fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.goCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDeep,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Buat Kuis Baru',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _stats(BuildContext context) {
    final s = context.surfaces;
    final avg = controller.averageScore;
    return Row(
      children: [
        Expanded(
          child: _statCard(context, Icons.menu_book_outlined, s.accent,
              'Total Kuis', '${controller.totalQuiz}'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(context, Icons.emoji_events_outlined,
              AppColors.warning, 'Skor Rata-rata', avg == null ? '—' : '$avg%'),
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context, IconData icon, Color iconColor,
      String label, String value) {
    final s = context.surfaces;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12, color: s.muted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _recentHeader(BuildContext context) {
    final s = context.surfaces;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Kuis Terbaru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        TextButton.icon(
          onPressed: controller.goHistory,
          style: TextButton.styleFrom(foregroundColor: s.accent),
          icon: const Icon(Icons.history, size: 16),
          label: const Text('Riwayat', style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context, Color muted) {
    final s = context.surfaces;
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, size: 24, color: s.accent),
          const SizedBox(height: 8),
          Text('Belum ada kuis. Mulai buat satu sekarang!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: muted)),
        ],
      ),
    );
  }

  Widget _quizTile(BuildContext context, QuizSummary q) {
    final s = context.surfaces;
    return AppCard(
      onTap: () => controller.openQuiz(q.id),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.menu_book_outlined,
                size: 20, color: s.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${q.totalQuestions} soal',
                        style: TextStyle(fontSize: 11, color: s.muted)),
                    const SizedBox(width: 12),
                    Icon(Icons.schedule, size: 12, color: s.muted),
                    const SizedBox(width: 4),
                    Text('${q.durationMinutes}m',
                        style: TextStyle(fontSize: 11, color: s.muted)),
                    if (q.lastScore != null) ...[
                      const SizedBox(width: 12),
                      Text('${q.lastScore}%',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.success)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: s.muted),
        ],
      ),
    );
  }
}
