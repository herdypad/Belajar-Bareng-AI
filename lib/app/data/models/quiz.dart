import 'package:hive/hive.dart';
import 'question.dart';

part 'quiz.g.dart';

@HiveType(typeId: 1)
class Quiz extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int totalQuestions;

  @HiveField(4)
  final int durationMinutes;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.createdAt,
    required this.questions,
  });
}
