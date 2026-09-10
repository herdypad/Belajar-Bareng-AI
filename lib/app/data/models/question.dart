import 'package:hive/hive.dart';

part 'question.g.dart';

@HiveType(typeId: 0)
class Question extends HiveObject {
  @HiveField(0)
  final String question;

  @HiveField(1)
  final List<String> options;

  @HiveField(2)
  final int correctIndex;

  @HiveField(3)
  final String explanation;

  Question({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        question: (json['question'] ?? '').toString(),
        options: (json['options'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
        explanation: (json['explanation'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}
