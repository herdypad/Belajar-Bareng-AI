import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

class QuizActionSheet extends StatelessWidget {
  final String title;
  final int totalQuestions;
  final int durationMinutes;
  final int? score;
  final VoidCallback onReview;
  final VoidCallback onResult;
  final VoidCallback onRetry;
  final VoidCallback? onDelete;

  const QuizActionSheet({
    super.key,
    required this.title,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.score,
    required this.onReview,
    required this.onResult,
    required this.onRetry,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required int totalQuestions,
    required int durationMinutes,
    required int? score,
    required VoidCallback onReview,
    required VoidCallback onResult,
    required VoidCallback onRetry,
    VoidCallback? onDelete,
  }) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: isTablet ? 560 : double.infinity,
      ),
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: QuizActionSheet(
            title: title,
            totalQuestions: totalQuestions,
            durationMinutes: durationMinutes,
            score: score,
            onReview: onReview,
            onResult: onResult,
            onRetry: onRetry,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.surfaces;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: s.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: s.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: s.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header with Quiz Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.menu_book_rounded, size: 22, color: s.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$totalQuestions Soal',
                          style: TextStyle(fontSize: 12, color: s.muted),
                        ),
                        const SizedBox(width: 8),
                        Text('•', style: TextStyle(fontSize: 12, color: s.muted)),
                        const SizedBox(width: 8),
                        Text(
                          '$durationMinutes Menit',
                          style: TextStyle(fontSize: 12, color: s.muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (score != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _scoreColor(score!).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: _scoreColor(score!).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Skor: $score%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _scoreColor(score!),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: s.border, height: 1),
          const SizedBox(height: 16),

          Text(
            'Pilih Tindakan',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: s.muted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          // Option 1: Review Jawaban (Highlighted action)
          AppCard(
            onTap: onReview,
            color: AppColors.primary.withValues(alpha: 0.08),
            borderColor: AppColors.primary.withValues(alpha: 0.35),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.rate_review_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review Jawaban',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Lihat pembahasan & evaluasi jawaban kamu',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Option 2: Lihat Hasil
          AppCard(
            onTap: onResult,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.insights_outlined,
                    size: 20,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lihat Ringkasan Nilai',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Skor, akurasi benar/salah, & waktu pengerjaan',
                        style: TextStyle(fontSize: 12, color: s.muted),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: s.muted,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Option 3: Kerjakan Ulang
          AppCard(
            onTap: onRetry,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: s.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.replay_rounded,
                    size: 20,
                    color: s.accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kerjakan Ulang',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mulai mengerjakan kuis ini kembali dari awal',
                        style: TextStyle(fontSize: 12, color: s.muted),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: s.muted,
                ),
              ],
            ),
          ),

          if (onDelete != null) ...[
            const SizedBox(height: 10),
            AppCard(
              onTap: onDelete,
              borderColor: AppColors.danger.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(14),
              child: const Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.danger,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Hapus Kuis',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
