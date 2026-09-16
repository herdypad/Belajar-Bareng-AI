import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/quiz.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/services/quiz_import_service.dart';
import '../../data/services/settings_service.dart';
import '../../core/widgets/quiz_action_sheet.dart';
import '../../routes/app_routes.dart';
import 'widgets/import_quiz_sheet.dart';

class QuizSummary {
  final String id;
  final String title;
  final int totalQuestions;
  final int durationMinutes;
  final int? lastScore;
  final String createdLabel;

  QuizSummary({
    required this.id,
    required this.title,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.lastScore,
    required this.createdLabel,
  });
}

class PickedQuizResult {
  final String fileName;
  final ParsedQuizData data;

  PickedQuizResult({required this.fileName, required this.data});
}

class HomeController extends GetxController {
  final QuizRepository _repo = Get.find<QuizRepository>();
  final SettingsService settings = Get.find<SettingsService>();
  final QuizImportService importService = QuizImportService();

  final quizzes = <QuizSummary>[].obs;

  @override
  void onReady() {
    super.onReady();
    refreshQuizzes();
  }

  void refreshQuizzes() {
    quizzes.value = _repo.getAllQuizzes().map(_toSummary).toList();
  }

  QuizSummary _toSummary(Quiz q) {
    final result = _repo.getResult(q.id);
    return QuizSummary(
      id: q.id,
      title: q.title,
      totalQuestions: q.totalQuestions,
      durationMinutes: q.durationMinutes,
      lastScore: result?.score,
      createdLabel: _formatDate(result?.completedAt ?? q.createdAt),
    );
  }

  int get totalQuiz => quizzes.length;

  int? get averageScore {
    final scored = quizzes.where((q) => q.lastScore != null).toList();
    if (scored.isEmpty) return null;
    final sum = scored.fold<int>(0, (a, q) => a + (q.lastScore ?? 0));
    return (sum / scored.length).round();
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> goCreate() async {
    await Get.toNamed(AppRoutes.create);
    refreshQuizzes();
  }

  Future<void> goHistory() async {
    await Get.toNamed(AppRoutes.history);
    refreshQuizzes();
  }

  Future<void> goSettings() async {
    await Get.toNamed(AppRoutes.settings);
  }

  Future<void> openQuiz(String id) async {
    await Get.toNamed(AppRoutes.runner, arguments: id);
    refreshQuizzes();
  }

  Future<void> openReview(String id) async {
    await Get.toNamed(AppRoutes.review, arguments: id);
    refreshQuizzes();
  }

  Future<void> openResult(String id) async {
    await Get.toNamed(AppRoutes.result, arguments: id);
    refreshQuizzes();
  }

  void onQuizTap(BuildContext context, QuizSummary q) {
    if (q.lastScore != null) {
      QuizActionSheet.show(
        context,
        title: q.title,
        totalQuestions: q.totalQuestions,
        durationMinutes: q.durationMinutes,
        score: q.lastScore,
        onReview: () {
          Navigator.of(context).pop();
          openReview(q.id);
        },
        onResult: () {
          Navigator.of(context).pop();
          openResult(q.id);
        },
        onRetry: () {
          Navigator.of(context).pop();
          openQuiz(q.id);
        },
      );
    } else {
      openQuiz(q.id);
    }
  }

  /// Membuka modal bottom sheet import soal
  void openImportDialog(BuildContext context) {
    ImportQuizSheet.show(context, this);
  }

  /// Memilih file JSON dari storage perangkat dan mem-parsing isinya
  Future<PickedQuizResult?> pickAndParseJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'txt'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    String content = '';

    if (file.bytes != null) {
      content = utf8.decode(file.bytes!);
    } else if (!kIsWeb && file.path != null) {
      final fileObj = File(file.path!);
      content = await fileObj.readAsString();
    }

    if (content.trim().isEmpty) {
      throw ImportException('File kosong atau tidak dapat dibaca.');
    }

    final baseName = file.name.replaceAll(RegExp(r'\.[^.]+$'), '');
    final data = importService.parse(content, defaultTitle: baseName);
    return PickedQuizResult(fileName: file.name, data: data);
  }

  /// Mem-parsing string teks JSON yang ditempel
  ParsedQuizData parseJsonText(String text, {String? defaultTitle}) {
    return importService.parse(text, defaultTitle: defaultTitle);
  }

  /// Menyimpan kuis yang berhasil diimport ke repository
  Future<void> saveImportedQuiz(
    ParsedQuizData data, {
    required String title,
    required int durationMinutes,
    bool startImmediately = false,
  }) async {
    final quiz = importService.buildQuiz(
      data: data,
      fallbackTitle: title,
      defaultDurationMinutes: durationMinutes,
    );

    await _repo.saveQuiz(quiz);
    refreshQuizzes();

    Get.snackbar(
      'Berhasil',
      'Kuis "${quiz.title}" (${quiz.totalQuestions} soal) berhasil diimpor.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    if (startImmediately) {
      await Get.toNamed(AppRoutes.runner, arguments: quiz.id);
      refreshQuizzes();
    }
  }
}

