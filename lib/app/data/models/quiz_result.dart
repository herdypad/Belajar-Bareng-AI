import 'package:hive/hive.dart';

part 'quiz_result.g.dart';

@HiveType(typeId: 2)
class QuizResult extends HiveObject {
  @HiveField(0)
  final String quizId;

  @HiveField(1)
  final List<int> userAnswers; // -1 menandakan tidak dijawab

  @HiveField(2)
  final int score; // persentase 0-100

  @HiveField(3)
  final int timeUsedSec;

  @HiveField(4)
  final DateTime completedAt;

  QuizResult({
    required this.quizId,
    required this.userAnswers,
    required this.score,
    required this.timeUsedSec,
    required this.completedAt,
  });
}
