import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/quiz.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../routes/app_routes.dart';

class QuizRunnerController extends GetxController {
  final QuizRepository _repo = Get.find<QuizRepository>();

  late final Quiz quiz;

  final currentIndex = 0.obs;
  final answers = <int>[].obs; // -1 = belum dijawab
  final flagged = <int>{}.obs;
  final remainingSec = 0.obs;

  Timer? _timer;
  bool _submitted = false;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments as String;
    final loaded = _repo.getQuiz(id);
    if (loaded == null) {
      // Kuis tidak ditemukan: kembali ke beranda.
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
      quiz = Quiz(
        id: id,
        title: '',
        description: '',
        totalQuestions: 0,
        durationMinutes: 0,
        createdAt: DateTime.now(),
        questions: const [],
      );
      return;
    }
    quiz = loaded;
    answers.value = List<int>.filled(quiz.questions.length, -1);
    remainingSec.value = quiz.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSec.value <= 1) {
        remainingSec.value = 0;
        submit(auto: true);
      } else {
        remainingSec.value--;
      }
    });
  }

  int get total => quiz.questions.length;
  int get answeredCount => answers.where((a) => a >= 0).length;
  double get progress => total == 0 ? 0 : (currentIndex.value + 1) / total;
  bool get isLast => currentIndex.value == total - 1;
  bool get isFirst => currentIndex.value == 0;

  String get timeLabel {
    final m = (remainingSec.value ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSec.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get timeLow => remainingSec.value < 60;

  void choose(int optionIndex) {
    answers[currentIndex.value] = optionIndex;
    answers.refresh();
  }

  void toggleFlag() {
    final i = currentIndex.value;
    if (flagged.contains(i)) {
      flagged.remove(i);
    } else {
      flagged.add(i);
    }
  }

  void next() {
    if (!isLast) currentIndex.value++;
  }

  void prev() {
    if (!isFirst) currentIndex.value--;
  }

  Future<void> submit({bool auto = false}) async {
    if (_submitted) return;
    _submitted = true;
    _timer?.cancel();

    final timeUsed = auto
        ? quiz.durationMinutes * 60
        : quiz.durationMinutes * 60 - remainingSec.value;

    Get.offNamed(
      AppRoutes.result,
      arguments: {
        'quizId': quiz.id,
        'answers': answers.toList(),
        'timeUsedSec': timeUsed,
      },
    );
  }

  Future<bool> confirmExit() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Keluar dari kuis?'),
        content: const Text('Progres jawaban kamu tidak akan disimpan.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Keluar')),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
