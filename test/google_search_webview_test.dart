import 'package:belajar_bareng_ai/app/core/theme/app_theme.dart';
import 'package:belajar_bareng_ai/app/core/widgets/google_search_webview_sheet.dart';
import 'package:belajar_bareng_ai/app/data/models/question.dart';
import 'package:belajar_bareng_ai/app/data/models/quiz.dart';
import 'package:belajar_bareng_ai/app/data/models/quiz_result.dart';
import 'package:belajar_bareng_ai/app/data/repositories/quiz_repository.dart';
import 'package:belajar_bareng_ai/app/modules/review/review_controller.dart';
import 'package:belajar_bareng_ai/app/modules/review/review_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeRepo extends GetxService implements QuizRepository {
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
  group('Google Search WebView and Text Selection Tests', () {
    test('cleanQuery strips JSON structure and extracts clean sentence', () {
      // Normal sentence
      expect(
        GoogleSearchWebViewSheet.cleanQuery('Hukum Newton 1 tentang kelembaman'),
        'Hukum Newton 1 tentang kelembaman',
      );

      // JSON object with question key
      expect(
        GoogleSearchWebViewSheet.cleanQuery(
          '{"question": "Berapakah massa jenis air murni?", "options": ["1000 kg/m3"]}',
        ),
        'Berapakah massa jenis air murni?',
      );

      // JSON array
      expect(
        GoogleSearchWebViewSheet.cleanQuery(
          '[{"question": "Siapa penemu gaya gravitasi?"}]',
        ),
        'Siapa penemu gaya gravitasi?',
      );

      // Quoted string
      expect(
        GoogleSearchWebViewSheet.cleanQuery('"Proses respirasi aerob"'),
        'Proses respirasi aerob',
      );
    });

    testWidgets('GoogleSearchWebViewSheet renders search query and controls',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: GoogleSearchWebViewSheet(query: 'Hukum Gravitasi Newton'),
          ),
        ),
      );

      expect(find.text('Pencarian Google'), findsOneWidget);
      expect(find.text('Hukum Gravitasi Newton'), findsWidgets);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
    });

    testWidgets('ReviewView includes SelectionArea for text blocking and search',
        (tester) async {
      Get.reset();
      final repo = FakeRepo();
      final quiz = Quiz(
        id: 'q1',
        title: 'Fisika SMA',
        description: 'Soal Fisika',
        totalQuestions: 1,
        durationMinutes: 10,
        createdAt: DateTime.now(),
        questions: [
          Question(
            question: 'Apa rumus gaya gravitasi?',
            options: ['F = G(m1.m2)/r^2', 'F = m.a', 'E = mc^2'],
            correctIndex: 0,
            explanation: 'Rumus gravitasi universal ditemukan oleh Newton.',
          ),
        ],
      );
      final result = QuizResult(
        quizId: 'q1',
        userAnswers: [0],
        score: 100,
        timeUsedSec: 60,
        completedAt: DateTime.now(),
      );
      repo.saveQuiz(quiz);
      repo.saveResult(result);
      Get.put<QuizRepository>(repo);

      Get.routing.args = 'q1';
      Get.put<ReviewController>(ReviewController());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const ReviewView(),
        ),
      );

      // Verify SelectionArea is present in ReviewView
      expect(find.byType(SelectionArea), findsOneWidget);
      expect(find.text('Apa rumus gaya gravitasi?'), findsOneWidget);
      expect(find.text('Pembahasan'), findsOneWidget);
      expect(find.text('Cari Topik'), findsOneWidget);
    });
  });
}
