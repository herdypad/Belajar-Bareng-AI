import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/google_search_webview_sheet.dart';
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
    final isTablet = ResponsiveBreakpoints.isTabletOrLarger(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(isTablet ? 32 : 20, 16, isTablet ? 32 : 20, 8),
      child: Row(
        children: [
          CircleIconButton(icon: Icons.close, onTap: Get.back),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Review Jawaban',
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress(BuildContext context) {
    final s = context.surfaces;
    final isTablet = ResponsiveBreakpoints.isTabletOrLarger(context);
    return Obx(() {
      final cur = controller.currentIndex.value + 1;
      final tot = controller.totalQuestions;
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32 : 20,
          vertical: 8,
        ),
        child: Row(
          children: [
            Text(
              'Soal $cur dari $tot',
              style: TextStyle(fontSize: isTablet ? 14 : 13, color: s.muted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: tot == 0 ? 0 : cur / tot,
                  backgroundColor: s.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: isTablet ? 8 : 6,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _questionArea(BuildContext context) {
    final isTablet = ResponsiveBreakpoints.isTabletOrLarger(context);
    final isTwoColumn = ResponsiveBreakpoints.isTabletLandscapeOrDesktop(context);

    return Obx(() {
      final question = controller.currentQuestion;
      final userAnswer = controller.currentUserAnswer;
      final isCorrect = controller.isAnswerCorrect;
      final isUnanswered = controller.isUnanswered;

      return SelectionArea(
        onSelectionChanged: (content) {
          controller.updateSelectedText(content?.plainText);
        },
        contextMenuBuilder: (context, selectableRegionState) {
          final buttonItems = selectableRegionState.contextMenuButtonItems;
          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: selectableRegionState.contextMenuAnchors,
            buttonItems: [
              ...buttonItems,
              ContextMenuButtonItem(
                onPressed: () {
                  selectableRegionState.hideToolbar();
                  final text = controller.selectedText.trim();
                  if (text.isNotEmpty && context.mounted) {
                    GoogleSearchWebViewSheet.show(context, query: text);
                  }
                },
                label: 'Cari di Google 🔍',
              ),
            ],
          );
        },
        child: isTwoColumn
            ? ListView(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column: Question + Options
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppCard(
                              padding: const EdgeInsets.all(22),
                              child: Text(
                                question.question,
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...List.generate(
                              question.options.length,
                              (optIdx) => _optionItem(
                                context,
                                question,
                                optIdx,
                                userAnswer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right column: Status badge + Explanation
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _statusBadge(
                              isCorrect: isCorrect,
                              isUnanswered: isUnanswered,
                            ),
                            const SizedBox(height: 16),
                            if (question.explanation.isNotEmpty)
                              _explanationCard(context, question),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : ListView(
                padding: EdgeInsets.all(isTablet ? 28 : 20),
                children: [
                  // Status Badge (Benar / Salah / Tidak Dijawab)
                  _statusBadge(
                      isCorrect: isCorrect, isUnanswered: isUnanswered),
                  const SizedBox(height: 12),

                  AppCard(
                    padding: EdgeInsets.all(isTablet ? 24 : 20),
                    child: Text(
                      question.question,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 17,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Options List
                  ...List.generate(
                    question.options.length,
                    (optIdx) =>
                        _optionItem(context, question, optIdx, userAnswer),
                  ),

                  const SizedBox(height: 8),

                  // Explanation Section
                  if (question.explanation.isNotEmpty)
                    _explanationCard(context, question),
                ],
              ),
      );
    });
  }

  Widget _optionItem(
    BuildContext context,
    dynamic question,
    int optIdx,
    int? userAnswer,
  ) {
    final isOptCorrect = optIdx == question.correctIndex;
    final isUserSelected = optIdx == userAnswer;

    Color bgColor = context.surfaces.card;
    Color borderColor = context.surfaces.border;
    Color textColor = context.surfaces.muted;
    IconData? trailingIcon;
    String? badgeText;

    if (isOptCorrect) {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      borderColor = AppColors.success;
      textColor = AppColors.success;
      trailingIcon = Icons.check_circle;
      badgeText = isUserSelected ? 'Jawaban Kamu (Benar)' : 'Kunci Jawaban';
    } else if (isUserSelected) {
      bgColor = AppColors.danger.withValues(alpha: 0.1);
      borderColor = AppColors.danger;
      textColor = AppColors.danger;
      trailingIcon = Icons.cancel;
      badgeText = 'Jawaban Kamu (Salah)';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: (isOptCorrect || isUserSelected) ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isOptCorrect || isUserSelected
                    ? textColor
                    : context.surfaces.border,
                shape: BoxShape.circle,
              ),
              child: Text(
                String.fromCharCode(65 + optIdx),
                style: TextStyle(
                  color: isOptCorrect || isUserSelected
                      ? Colors.white
                      : context.surfaces.muted,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.options[optIdx],
                    style: TextStyle(
                      fontSize: 15,
                      color: context.theme.colorScheme.onSurface,
                      fontWeight: (isOptCorrect || isUserSelected)
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (badgeText != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingIcon != null)
              Icon(trailingIcon, color: textColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _explanationCard(BuildContext context, dynamic question) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Pembahasan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => GoogleSearchWebViewSheet.show(
                  context,
                  query: question.question,
                ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Cari Topik',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.explanation,
            style: const TextStyle(fontSize: 14, height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge({required bool isCorrect, required bool isUnanswered}) {
    Color bg;
    Color fg;
    IconData icon;
    String text;

    if (isUnanswered) {
      bg = AppColors.warning.withValues(alpha: 0.12);
      fg = AppColors.warning;
      icon = Icons.help_outline_rounded;
      text = 'Kamu tidak menjawab soal ini';
    } else if (isCorrect) {
      bg = AppColors.success.withValues(alpha: 0.12);
      fg = AppColors.success;
      icon = Icons.check_circle_outline_rounded;
      text = 'Jawaban Kamu Benar 🎉';
    } else {
      bg = AppColors.danger.withValues(alpha: 0.12);
      fg = AppColors.danger;
      icon = Icons.highlight_off_rounded;
      text = 'Jawaban Kamu Kurang Tepat';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaces.card,
        border: Border(top: BorderSide(color: context.surfaces.border)),
      ),
      child: Obx(() {
        final cur = controller.currentIndex.value + 1;
        final tot = controller.totalQuestions;
        final isLast = cur >= tot;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: cur > 1 ? controller.prev : null,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Sebelumnya'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.surfaces.border,
                foregroundColor: context.theme.colorScheme.onSurface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            ElevatedButton(
              onPressed: isLast ? Get.back : controller.next,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? AppColors.success : AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isLast ? 'Selesai Review' : 'Selanjutnya'),
                  const SizedBox(width: 8),
                  Icon(
                    isLast ? Icons.check_circle_outline : Icons.arrow_forward,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
