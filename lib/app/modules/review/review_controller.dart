import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/question.dart';
import '../../data/models/quiz.dart';
import '../../data/models/quiz_result.dart';
import '../../data/repositories/quiz_repository.dart';

class ReviewController extends GetxController {
  final QuizRepository _repo = Get.find<QuizRepository>();

  late Quiz quiz;
  late QuizResult result;

  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final rawArgs = Get.arguments;

    if (rawArgs is Map<String, dynamic>) {
      if (rawArgs['quiz'] is Quiz && rawArgs['result'] is QuizResult) {
        quiz = rawArgs['quiz'] as Quiz;
        result = rawArgs['result'] as QuizResult;
        return;
      } else if (rawArgs['quizId'] is String) {
        _loadByQuizId(rawArgs['quizId'] as String);
        return;
      }
    } else if (rawArgs is String) {
      _loadByQuizId(rawArgs);
      return;
    }

    _handleError('Data kuis tidak ditemukan. Silakan coba lagi.');
  }

  void _loadByQuizId(String quizId) {
    final loadedQuiz = _repo.getQuiz(quizId);
    final loadedResult = _repo.getResult(quizId);

    if (loadedQuiz == null) {
      _handleError('Kuis tidak ditemukan.');
      return;
    }

    if (loadedResult == null) {
      _handleError('Kuis ini belum pernah dikerjakan.');
      return;
    }

    quiz = loadedQuiz;
    result = loadedResult;
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

  int get totalQuestions => quiz.questions.length;

  Question get currentQuestion => quiz.questions[currentIndex.value];

  int get currentUserAnswer =>
      currentIndex.value < result.userAnswers.length
          ? result.userAnswers[currentIndex.value]
          : -1;

  bool get isUnanswered => currentUserAnswer == -1;

  bool get isAnswerCorrect =>
      !isUnanswered && currentUserAnswer == currentQuestion.correctIndex;

  void next() {
    if (currentIndex.value < totalQuestions - 1) {
      currentIndex.value++;
    }
  }

  void prev() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  String selectedText = '';

  void updateSelectedText(String? text) {
    selectedText = text?.trim() ?? '';
  }
}
