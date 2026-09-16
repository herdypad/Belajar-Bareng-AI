import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/quiz.dart';
import '../../data/models/quiz_result.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../routes/app_routes.dart';

class ResultController extends GetxController {
  final QuizRepository _repo = Get.find<QuizRepository>();

  late final Quiz quiz;
  late final List<int> answers;
  late final int timeUsedSec;

  int correct = 0;
  int wrong = 0;
  int percentage = 0;

  @override
  void onInit() {
    super.onInit();
    final rawArgs = Get.arguments;
    String quizId;
    bool isNewSubmission = false;

    if (rawArgs is String) {
      quizId = rawArgs;
    } else if (rawArgs is Map<String, dynamic>) {
      quizId = rawArgs['quizId'] as String;
      if (rawArgs.containsKey('answers') && rawArgs.containsKey('timeUsedSec')) {
        answers = List<int>.from(rawArgs['answers'] as List);
        timeUsedSec = rawArgs['timeUsedSec'] as int;
        isNewSubmission = true;
      }
    } else {
      _handleError('Data kuis tidak valid.');
      return;
    }

    final loadedQuiz = _repo.getQuiz(quizId);
    if (loadedQuiz == null) {
      _handleError('Kuis tidak ditemukan.');
      return;
    }
    quiz = loadedQuiz;

    if (!isNewSubmission) {
      final savedResult = _repo.getResult(quizId);
      if (savedResult != null) {
        answers = List<int>.from(savedResult.userAnswers);
        timeUsedSec = savedResult.timeUsedSec;
        percentage = savedResult.score;
        correct = 0;
        for (var i = 0; i < quiz.questions.length; i++) {
          if (i < answers.length && answers[i] == quiz.questions[i].correctIndex) {
            correct++;
          }
        }
        wrong = quiz.questions.length - correct;
        return;
      } else {
        _handleError('Kuis ini belum pernah dikerjakan.');
        return;
      }
    }

    _calculate();
    _persist();
  }

  void _handleError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
        Get.back();
      }
      Get.back();
      Get.snackbar(
        'Perhatian',
        message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    });
  }

  void _calculate() {
    for (var i = 0; i < quiz.questions.length; i++) {
      if (i < answers.length && answers[i] == quiz.questions[i].correctIndex) {
        correct++;
      }
    }
    final total = quiz.questions.length;
    wrong = total - correct;
    percentage = total == 0 ? 0 : ((correct / total) * 100).round();
  }

  Future<void> _persist() async {
    await _repo.saveResult(QuizResult(
      quizId: quiz.id,
      userAnswers: answers,
      score: percentage,
      timeUsedSec: timeUsedSec,
      completedAt: DateTime.now(),
    ));
  }

  String get verdict {
    if (percentage >= 80) return 'Luar biasa! 🎉';
    if (percentage >= 60) return 'Bagus, terus belajar!';
    return 'Yuk coba lagi, kamu pasti bisa!';
  }

  Color get ringColor {
    if (percentage >= 80) return const Color(0xFF34D399);
    if (percentage >= 60) return const Color(0xFFFBBF24);
    return const Color(0xFFEF4444);
  }

  String get timeLabel {
    final m = timeUsedSec ~/ 60;
    final s = (timeUsedSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void goReview() {
    final result = _repo.getResult(quiz.id) ??
        QuizResult(
          quizId: quiz.id,
          userAnswers: answers,
          score: percentage,
          timeUsedSec: timeUsedSec,
          completedAt: DateTime.now(),
        );

    Get.toNamed(AppRoutes.review, arguments: {
      'quiz': quiz,
      'result': result,
    });
  }

  void goHome() => Get.until((route) => route.settings.name == AppRoutes.home);

  void retry() => Get.offNamed(AppRoutes.runner, arguments: quiz.id);
}
