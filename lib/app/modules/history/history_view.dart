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
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    itemCount: controller.historyList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _historyTile(context, controller.historyList[i]),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
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
    return AppCard(
      onTap: () => controller.openQuiz(item.id),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.score != null 
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.score != null ? Icons.done_all : Icons.pending_actions,
              size: 24,
              color: item.score != null ? AppColors.success : AppColors.primary,
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
          if (item.score != null)
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
          PopupMenuButton(
            icon: Icon(Icons.more_vert, size: 20, color: s.muted),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                    SizedBox(width: 8),
                    Text('Hapus Kuis', style: TextStyle(color: AppColors.danger)),
                  ],
                ),
                onTap: () {
                  Future.delayed(
                    const Duration(milliseconds: 100), 
                    () => controller.deleteQuiz(item.id)
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
