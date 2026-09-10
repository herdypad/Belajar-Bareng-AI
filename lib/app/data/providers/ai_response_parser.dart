import 'dart:convert';
import '../models/question.dart';
import 'ai_provider.dart';

/// Mengekstrak dan mem-parsing JSON soal dari respons mentah AI.
/// Tahan terhadap teks pembungkus / code fence di sekitar JSON.
List<Question> parseQuestions(String raw) {
  final jsonStr = _extractJson(raw);
  if (jsonStr == null) {
    throw AiException('Respons AI tidak berisi JSON yang valid.');
  }
  try {
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    final list = (decoded['questions'] as List<dynamic>? ?? []);
    final questions = list
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .where((q) => q.options.length >= 2)
        .toList();
    if (questions.isEmpty) {
      throw AiException('AI tidak menghasilkan soal apa pun.');
    }
    return questions;
  } on FormatException {
    throw AiException('Gagal mem-parsing JSON dari AI.');
  }
}

String? _extractJson(String raw) {
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start == -1 || end == -1 || end <= start) return null;
  return raw.substring(start, end + 1);
}
