import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/quiz_action_sheet.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../routes/app_routes.dart';

class HistoryItem {
  final String id;
  final String title;
  final int totalQuestions;
  final int durationMinutes;
  final int? score;
  final DateTime createdAt;

  HistoryItem({
    required this.id,
    required this.title,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.score,
    required this.createdAt,
  });
}

class HistoryController extends GetxController {
  final QuizRepository _repo = Get.find<QuizRepository>();

  final historyList = <HistoryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() {
    final quizzes = _repo.getAllQuizzes();
    historyList.value = quizzes.map((q) {
      final result = _repo.getResult(q.id);
      return HistoryItem(
        id: q.id,
        title: q.title,
        totalQuestions: q.totalQuestions,
        durationMinutes: q.durationMinutes,
        score: result?.score,
        createdAt: q.createdAt,
      );
    }).toList();
  }

  Future<void> openReview(String id) async {
    await Get.toNamed(AppRoutes.review, arguments: id);
    loadHistory();
  }

  Future<void> openResult(String id) async {
    await Get.toNamed(AppRoutes.result, arguments: id);
    loadHistory();
  }

  Future<void> retryQuiz(String id) async {
    await Get.toNamed(AppRoutes.runner, arguments: id);
    loadHistory();
  }

  void onItemTap(BuildContext context, HistoryItem item) {
    if (item.score != null) {
      QuizActionSheet.show(
        context,
        title: item.title,
        totalQuestions: item.totalQuestions,
        durationMinutes: item.durationMinutes,
        score: item.score,
        onReview: () {
          Navigator.of(context).pop();
          openReview(item.id);
        },
        onResult: () {
          Navigator.of(context).pop();
          openResult(item.id);
        },
        onRetry: () {
          Navigator.of(context).pop();
          retryQuiz(item.id);
        },
        onDelete: () {
          Navigator.of(context).pop();
          deleteQuiz(item.id);
        },
      );
    } else {
      retryQuiz(item.id);
    }
  }

  Future<void> openQuiz(String id) async {
    final result = _repo.getResult(id);
    if (result != null) {
      await Get.toNamed(AppRoutes.result, arguments: id);
    } else {
      await Get.toNamed(AppRoutes.runner, arguments: id);
    }
    loadHistory();
  }

  Future<void> deleteQuiz(String id) async {
    await _repo.deleteQuiz(id);
    loadHistory();
  }
}
