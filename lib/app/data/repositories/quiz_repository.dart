import 'package:hive/hive.dart';

import '../models/quiz.dart';
import '../models/quiz_result.dart';

/// Penyimpanan lokal offline-first menggunakan Hive.
class QuizRepository {
  static const _quizBox = 'quizzes';
  static const _resultBox = 'results';

  late Box<Quiz> _quizzes;
  late Box<QuizResult> _results;

  Future<void> init() async {
    _quizzes = await Hive.openBox<Quiz>(_quizBox);
    _results = await Hive.openBox<QuizResult>(_resultBox);
  }

  List<Quiz> getAllQuizzes() {
    final list = _quizzes.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Quiz? getQuiz(String id) {
    try {
      return _quizzes.values.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveQuiz(Quiz quiz) async => _quizzes.put(quiz.id, quiz);

  Future<void> deleteQuiz(String id) async {
    await _quizzes.delete(id);
    await _results.delete(id);
  }

  QuizResult? getResult(String quizId) => _results.get(quizId);

  Future<void> saveResult(QuizResult result) async =>
      _results.put(result.quizId, result);
}
