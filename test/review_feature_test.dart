import 'package:belajar_bareng_ai/app/core/theme/app_theme.dart';
import 'package:belajar_bareng_ai/app/core/widgets/quiz_action_sheet.dart';
import 'package:belajar_bareng_ai/app/data/models/question.dart';
import 'package:belajar_bareng_ai/app/data/models/quiz.dart';
import 'package:belajar_bareng_ai/app/data/models/quiz_result.dart';
import 'package:belajar_bareng_ai/app/data/repositories/quiz_repository.dart';
import 'package:belajar_bareng_ai/app/modules/result/result_controller.dart';
import 'package:belajar_bareng_ai/app/modules/review/review_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeQuizRepository extends GetxService implements QuizRepository {
  final Map<String, Quiz> quizzes = {};
  final Map<String, QuizResult> results = {};

  @override
  List<Quiz> getAllQuizzes() => quizzes.values.toList();

  @override
  Quiz? getQuiz(String id) => quizzes[id];

  @override
  Future<void> saveQuiz(Quiz quiz) async => quizzes[quiz.id] = quiz;

  @override
  QuizResult? getResult(String quizId) => results[quizId];

  @override
  Future<void> saveResult(QuizResult result) async =>
      results[result.quizId] = result;

  @override
  Future<void> deleteQuiz(String id) async {
    quizzes.remove(id);
    results.remove(id);
  }

  @override
  Future<void> init() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Review Feature Tests', () {
    late FakeQuizRepository fakeRepo;

    final testQuiz = Quiz(
      id: 'quiz-1',
      title: 'Kuis IPA',
      description: 'Latihan IPA',
      totalQuestions: 2,
      durationMinutes: 10,
      createdAt: DateTime(2026, 1, 1),
      questions: [
        Question(
          question: 'Apa ibukota Indonesia?',
          options: ['Jakarta', 'Bandung', 'Surabaya', 'Medan'],
          correctIndex: 0,
          explanation: 'Ibukota adalah Jakarta.',
        ),
        Question(
          question: '2 + 2 = ?',
          options: ['3', '4', '5'],
          correctIndex: 1,
          explanation: '2 + 2 = 4.',
        ),
      ],
    );

    final testResult = QuizResult(
      quizId: 'quiz-1',
      userAnswers: [0, 2], // 1st correct, 2nd wrong
      score: 50,
      timeUsedSec: 120,
      completedAt: DateTime(2026, 1, 1, 10, 0),
    );

    setUp(() {
      Get.reset();
      fakeRepo = FakeQuizRepository();
      fakeRepo.saveQuiz(testQuiz);
      fakeRepo.saveResult(testResult);
      Get.put<QuizRepository>(fakeRepo);
    });

    test('ReviewController initializes correctly with quizId string', () {
      Get.parameters = {};
      Get.routing.args = 'quiz-1';

      final reviewController = ReviewController();
      reviewController.onInit();

      expect(reviewController.quiz.id, 'quiz-1');
      expect(reviewController.result.score, 50);
      expect(reviewController.totalQuestions, 2);

      // First question review
      expect(reviewController.currentIndex.value, 0);
      expect(reviewController.currentUserAnswer, 0);
      expect(reviewController.isAnswerCorrect, true);
      expect(reviewController.isUnanswered, false);

      // Navigate to second question
      reviewController.next();
      expect(reviewController.currentIndex.value, 1);
      expect(reviewController.currentUserAnswer, 2);
      expect(reviewController.isAnswerCorrect, false);
      expect(reviewController.isUnanswered, false);
    });

    test('ResultController loads existing saved result by quizId string without error', () {
      Get.routing.args = 'quiz-1';

      final resultController = ResultController();
      resultController.onInit();

      expect(resultController.quiz.id, 'quiz-1');
      expect(resultController.percentage, 50);
      expect(resultController.correct, 1);
      expect(resultController.wrong, 1);
      expect(resultController.timeUsedSec, 120);
    });

    testWidgets('QuizActionSheet renders options and triggers callbacks', (tester) async {
      bool reviewPressed = false;
      bool resultPressed = false;
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: QuizActionSheet(
              title: 'Kuis IPA',
              totalQuestions: 2,
              durationMinutes: 10,
              score: 50,
              onReview: () => reviewPressed = true,
              onResult: () => resultPressed = true,
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Kuis IPA'), findsOneWidget);
      expect(find.text('Skor: 50%'), findsOneWidget);
      expect(find.text('Review Jawaban'), findsOneWidget);
      expect(find.text('Lihat Ringkasan Nilai'), findsOneWidget);
      expect(find.text('Kerjakan Ulang'), findsOneWidget);

      await tester.tap(find.text('Review Jawaban'));
      await tester.pump();
      expect(reviewPressed, true);

      await tester.tap(find.text('Lihat Ringkasan Nilai'));
      await tester.pump();
      expect(resultPressed, true);

      await tester.tap(find.text('Kerjakan Ulang'));
      await tester.pump();
      expect(retryPressed, true);
    });
  });
}
