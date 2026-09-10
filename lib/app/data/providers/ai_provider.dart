import '../models/question.dart';

/// Kontrak abstrak untuk provider AI generator soal.
abstract class AiProvider {
  /// Menghasilkan [count] soal pilihan ganda tentang [topic].
  Future<List<Question>> generateQuestions({
    required String topic,
    required int count,
  });

  /// Menguji koneksi dengan API.
  Future<bool> testConnection();
}

class AiException implements Exception {
  final String message;
  AiException(this.message);
  @override
  String toString() => message;
}

/// Prompt terstruktur bersama untuk semua provider.
String buildPrompt({required String topic, required int count}) {
  return '''
Buat $count soal pilihan ganda dalam Bahasa Indonesia tentang topik: "$topic".
Setiap soal harus punya tepat 4 opsi jawaban dan satu jawaban benar.
Balas HANYA dengan JSON valid tanpa teks lain, dengan format:
{"questions":[{"question":"...","options":["A","B","C","D"],"correctIndex":0,"explanation":"..."}]}
''';
}
