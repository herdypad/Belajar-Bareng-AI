import 'package:get/get.dart';

import '../../data/models/quiz.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../routes/app_routes.dart';

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

class HomeController extends GetxController {
  final QuizRepository _repo = Get.find<QuizRepository>();

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
}
