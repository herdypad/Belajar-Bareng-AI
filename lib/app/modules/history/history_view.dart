import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/mobile_shell.dart';
import 'history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MobileShell(
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: Obx(() {
                  if (controller.historyList.isEmpty) {
                    return _emptyState(context);
                  }
                  final isTablet = MediaQuery.of(context).size.width >= 600;

                  if (isTablet) {
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 88,
                      ),
                      itemCount: controller.historyList.length,
                      itemBuilder: (_, i) =>
                          _historyTile(context, controller.historyList[i]),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    itemCount: controller.historyList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _historyTile(context, controller.historyList[i]),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return Padding(
      padding: EdgeInsets.fromLTRB(isTablet ? 28 : 20, 24, isTablet ? 28 : 20, 8),
      child: Row(
        children: [
          CircleIconButton(icon: Icons.arrow_back, onTap: Get.back),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Riwayat Kuis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final s = context.surfaces;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: s.muted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('Belum ada riwayat kuis',
                style: TextStyle(fontSize: 16, color: s.muted)),
          ],
        ),
      ),
    );
  }

  Widget _historyTile(BuildContext context, HistoryItem item) {
    final s = context.surfaces;
    final isDone = item.score != null;

    return AppCard(
      onTap: () => controller.onItemTap(context, item),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDone ? Icons.done_all : Icons.pending_actions,
              size: 24,
              color: isDone ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('${item.totalQuestions} soal',
                        style: TextStyle(fontSize: 12, color: s.muted)),
                    const SizedBox(width: 12),
                    Icon(Icons.schedule, size: 12, color: s.muted),
                    const SizedBox(width: 4),
                    Text('${item.durationMinutes}m',
                        style: TextStyle(fontSize: 12, color: s.muted)),
                  ],
                ),
              ],
            ),
          ),
          if (isDone) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('${item.score}%',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success)),
            ),
            const SizedBox(width: 6),
            TextButton.icon(
              onPressed: () => controller.openReview(item.id),
              icon: const Icon(Icons.rate_review_outlined, size: 14),
              label: const Text('Review',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 20, color: s.muted),
            onSelected: (value) {
              if (value == 'review') {
                controller.openReview(item.id);
              } else if (value == 'result') {
                controller.openResult(item.id);
              } else if (value == 'retry') {
                controller.retryQuiz(item.id);
              } else if (value == 'delete') {
                controller.deleteQuiz(item.id);
              }
            },
            itemBuilder: (context) => [
              if (isDone) ...[
                const PopupMenuItem(
                  value: 'review',
                  child: Row(
                    children: [
                      Icon(Icons.rate_review_outlined,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Review Jawaban'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'result',
                  child: Row(
                    children: [
                      Icon(Icons.insights_outlined,
                          color: AppColors.success, size: 20),
                      SizedBox(width: 8),
                      Text('Lihat Hasil'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'retry',
                  child: Row(
                    children: [
                      Icon(Icons.replay_rounded, color: s.accent, size: 20),
                      const SizedBox(width: 8),
                      const Text('Kerjakan Ulang'),
                    ],
                  ),
                ),
              ] else ...[
                const PopupMenuItem(
                  value: 'retry',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow_outlined,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Mulai Kerjakan'),
                    ],
                  ),
                ),
              ],
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        color: AppColors.danger, size: 20),
                    SizedBox(width: 8),
                    Text('Hapus Kuis',
                        style: TextStyle(color: AppColors.danger)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
