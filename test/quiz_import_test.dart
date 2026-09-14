import 'package:belajar_bareng_ai/app/data/services/quiz_import_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizImportService Tests', () {
    late QuizImportService service;

    setUp(() {
      service = QuizImportService();
    });

    test('Parses full quiz JSON successfully', () {
      const jsonStr = '''
      {
        "title": "Kuis Fisika Dasar",
        "description": "Latihan Fisika SMA",
        "durationMinutes": 20,
        "questions": [
          {
            "question": "Satuan dari gaya adalah?",
            "options": ["Newton", "Joule", "Watt", "Pascal"],
            "correctIndex": 0,
            "explanation": "Satuan gaya dalam SI adalah Newton (N)."
          }
        ]
      }
      ''';

      final parsed = service.parse(jsonStr);
      expect(parsed.title, 'Kuis Fisika Dasar');
      expect(parsed.durationMinutes, 20);
      expect(parsed.questions.length, 1);
      expect(parsed.questions.first.question, 'Satuan dari gaya adalah?');
      expect(parsed.questions.first.options.length, 4);
      expect(parsed.questions.first.correctIndex, 0);

      final quiz = service.buildQuiz(data: parsed);
      expect(quiz.title, 'Kuis Fisika Dasar');
      expect(quiz.durationMinutes, 20);
      expect(quiz.questions.length, 1);
    });

    test('Parses JSON wrapped in markdown code fence', () {
      const rawWithFence = '''
      ```json
      {
        "questions": [
          {
            "question": "1 + 1 = ?",
            "options": ["1", "2", "3"],
            "correctIndex": 1
          }
        ]
      }
      ```
      ''';

      final parsed = service.parse(rawWithFence, defaultTitle: 'Kuis Singkat');
      expect(parsed.title, 'Kuis Singkat');
      expect(parsed.questions.length, 1);
      expect(parsed.questions.first.options[1], '2');
      expect(parsed.questions.first.correctIndex, 1);
    });

    test('Parses direct array of questions and Indonesian keys', () {
      const rawList = '''
      [
        {
          "soal": "Hewan yang bernapas dengan insang adalah?",
          "pilihan": ["Kucing", "Ikan", "Burung", "Sapi"],
          "kunci": "B",
          "pembahasan": "Ikan bernapas menggunakan insang."
        }
      ]
      ''';

      final parsed = service.parse(rawList);
      expect(parsed.questions.length, 1);
      final q = parsed.questions.first;
      expect(q.question, 'Hewan yang bernapas dengan insang adalah?');
      expect(q.options, ['Kucing', 'Ikan', 'Burung', 'Sapi']);
      // 'B' should map to index 1
      expect(q.correctIndex, 1);
      expect(q.explanation, 'Ikan bernapas menggunakan insang.');
    });

    test('Parses Map options format {"A": "...", "B": "..."}', () {
      const rawMapOptions = '''
      {
        "questions": [
          {
            "question": "Warna primer adalah?",
            "options": {
              "A": "Merah",
              "B": "Hijau",
              "C": "Oranye"
            },
            "correctIndex": "A"
          }
        ]
      }
      ''';

      final parsed = service.parse(rawMapOptions);
      expect(parsed.questions.length, 1);
      expect(parsed.questions.first.options, ['Merah', 'Hijau', 'Oranye']);
      expect(parsed.questions.first.correctIndex, 0);
    });

    test('Throws ImportException on invalid JSON', () {
      expect(() => service.parse('not a valid json'), throwsA(isA<ImportException>()));
    });

    test('Throws ImportException when no valid questions found', () {
      const emptyQuestions = '{"questions": []}';
      expect(() => service.parse(emptyQuestions), throwsA(isA<ImportException>()));
    });

    test('buildQuiz applies fallbackTitle and defaultDuration when not provided', () {
      const raw = '[{"question": "Soal 1?", "options": ["A", "B"], "correctIndex": 0}]';
      final parsed = service.parse(raw);
      expect(parsed.title, isNull);
      expect(parsed.durationMinutes, isNull);

      final quiz = service.buildQuiz(
        data: parsed,
        fallbackTitle: 'Kuis Default',
        defaultDurationMinutes: 25,
      );

      expect(quiz.title, 'Kuis Default');
      expect(quiz.durationMinutes, 25);
      expect(quiz.questions.length, 1);
    });
  });
}
