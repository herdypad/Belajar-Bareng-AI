import 'dart:convert';
import '../models/question.dart';
import '../models/quiz.dart';

class ImportException implements Exception {
  final String message;
  ImportException(this.message);

  @override
  String toString() => message;
}

class ParsedQuizData {
  final String? title;
  final String? description;
  final int? durationMinutes;
  final List<Question> questions;

  ParsedQuizData({
    this.title,
    this.description,
    this.durationMinutes,
    required this.questions,
  });
}

class QuizImportService {
  /// Mem-parsing string JSON menjadi ParsedQuizData.
  /// Mendukung format lengkap (dengan title & duration), objek {questions: [...]},
  /// maupun array langsung [{...}].
  ParsedQuizData parse(String rawJson, {String? defaultTitle}) {
    final cleanJson = _cleanJsonString(rawJson);
    if (cleanJson.isEmpty) {
      throw ImportException('Teks JSON kosong atau tidak valid.');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(cleanJson);
    } catch (e) {
      throw ImportException('Sintaks JSON tidak valid: pastikan tanda kurung dan petik sesuai.');
    }

    String? parsedTitle;
    String? parsedDesc;
    int? parsedDuration;
    List<dynamic> rawQuestions = [];

    if (decoded is List) {
      rawQuestions = decoded;
    } else if (decoded is Map<String, dynamic>) {
      // Periksa judul
      parsedTitle = (decoded['title'] ?? decoded['judul'] ?? decoded['name'])?.toString();
      parsedDesc = (decoded['description'] ?? decoded['deskripsi'])?.toString();
      
      final dur = decoded['durationMinutes'] ?? decoded['duration'] ?? decoded['durasi'];
      if (dur is num) {
        parsedDuration = dur.toInt();
      } else if (dur is String) {
        parsedDuration = int.tryParse(dur);
      }

      // Cari list soal
      final questionsList = decoded['questions'] ??
          decoded['soal'] ??
          decoded['data'] ??
          decoded['items'] ??
          decoded['list_soal'];

      if (questionsList is List) {
        rawQuestions = questionsList;
      } else {
        throw ImportException('JSON tidak memiliki array "questions" atau "soal".');
      }
    } else {
      throw ImportException('Format data JSON harus berupa objek {} atau list [].');
    }

    if (rawQuestions.isEmpty) {
      throw ImportException('Tidak ditemukan data soal di dalam JSON.');
    }

    final questions = <Question>[];
    for (int i = 0; i < rawQuestions.length; i++) {
      final item = rawQuestions[i];
      if (item is! Map) {
        continue;
      }
      final map = Map<String, dynamic>.from(item);
      final q = _parseSingleQuestion(map, i + 1);
      if (q != null) {
        questions.add(q);
      }
    }

    if (questions.isEmpty) {
      throw ImportException('Tidak ada soal valid yang berhasil diekstrak (setiap soal butuh pertanyaan, minimal 2 opsi, dan kunci jawaban).');
    }

    return ParsedQuizData(
      title: parsedTitle ?? defaultTitle,
      description: parsedDesc,
      durationMinutes: parsedDuration,
      questions: questions,
    );
  }

  /// Membentuk objek [Quiz] lengkap siap simpan dari [ParsedQuizData].
  Quiz buildQuiz({
    required ParsedQuizData data,
    String? fallbackTitle,
    int defaultDurationMinutes = 15,
  }) {
    final title = (data.title != null && data.title!.trim().isNotEmpty)
        ? data.title!.trim()
        : (fallbackTitle?.trim().isNotEmpty == true ? fallbackTitle!.trim() : 'Kuis Hasil Import');

    final duration = (data.durationMinutes != null && data.durationMinutes! > 0)
        ? data.durationMinutes!
        : defaultDurationMinutes;

    return Quiz(
      id: 'q${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: data.description ?? 'Diimpor dari file/teks JSON',
      totalQuestions: data.questions.length,
      durationMinutes: duration,
      createdAt: DateTime.now(),
      questions: data.questions,
    );
  }

  Question? _parseSingleQuestion(Map<String, dynamic> map, int number) {
    // 1. Teks Soal
    final questionText = (map['question'] ??
            map['soal'] ??
            map['pertanyaan'] ??
            map['teks'] ??
            map['prompt'])
        ?.toString()
        .trim();

    if (questionText == null || questionText.isEmpty) {
      return null;
    }

    // 2. Opsi / Pilihan
    final rawOptions = map['options'] ??
        map['pilihan'] ??
        map['opsi'] ??
        map['choices'] ??
        map['jawaban_opsi'];

    List<String> options = [];
    if (rawOptions is List) {
      options = rawOptions.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    } else if (rawOptions is Map) {
      // Contoh: {"A": "Opsi 1", "B": "Opsi 2"}
      final sortedKeys = rawOptions.keys.toList()..sort();
      options = sortedKeys
          .map((k) => rawOptions[k].toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (options.length < 2) {
      return null;
    }

    // 3. Kunci Jawaban
    final rawCorrect = map['correctIndex'] ??
        map['correct_index'] ??
        map['kunci'] ??
        map['jawaban'] ??
        map['jawabanBenar'] ??
        map['kunciIndex'] ??
        map['answer'];

    int correctIndex = 0;
    if (rawCorrect is num) {
      correctIndex = rawCorrect.toInt();
    } else if (rawCorrect is String) {
      final str = rawCorrect.trim().toUpperCase();
      // Cek huruf: A -> 0, B -> 1, C -> 2, D -> 3, dst.
      if (str.length == 1 && str.codeUnitAt(0) >= 65 && str.codeUnitAt(0) <= 90) {
        correctIndex = str.codeUnitAt(0) - 65;
      } else {
        final parsed = int.tryParse(str);
        if (parsed != null) {
          correctIndex = parsed;
        } else {
          // Cari apakah teks kunci sama dengan salah satu opsi
          final matchIdx = options.indexWhere((opt) => opt.toLowerCase() == rawCorrect.trim().toLowerCase());
          if (matchIdx != -1) {
            correctIndex = matchIdx;
          }
        }
      }
    }

    // Koreksi jika index di luar jangkauan opsi
    if (correctIndex < 0 || correctIndex >= options.length) {
      correctIndex = 0;
    }

    // 4. Pembahasan
    final explanation = (map['explanation'] ??
            map['penjelasan'] ??
            map['pembahasan'] ??
            map['alasan'])
        ?.toString()
        .trim() ??
        '';

    return Question(
      question: questionText,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
    );
  }

  /// Menghilangkan wrapper teks atau markdown code fence (```json ... ```)
  String _cleanJsonString(String raw) {
    String str = raw.trim();
    if (str.startsWith('```')) {
      final firstLineBreak = str.indexOf('\n');
      if (firstLineBreak != -1) {
        str = str.substring(firstLineBreak + 1);
      }
      if (str.endsWith('```')) {
        str = str.substring(0, str.length - 3);
      }
      str = str.trim();
    }

    final startObj = str.indexOf('{');
    final startArr = str.indexOf('[');

    int start = -1;
    int end = -1;

    if (startObj != -1 && (startArr == -1 || startObj < startArr)) {
      start = startObj;
      end = str.lastIndexOf('}');
    } else if (startArr != -1) {
      start = startArr;
      end = str.lastIndexOf(']');
    }

    if (start != -1 && end != -1 && end > start) {
      return str.substring(start, end + 1);
    }
    return str;
  }

  /// Contoh template JSON untuk panduan pengguna
  static const String sampleTemplate = '''{
  "title": "Kuis Pengetahuan Umum",
  "durationMinutes": 15,
  "questions": [
    {
      "question": "Apa ibu kota negara Indonesia?",
      "options": ["Jakarta", "Surabaya", "Bandung", "Medan"],
      "correctIndex": 0,
      "explanation": "Ibu kota Indonesia saat ini adalah Jakarta."
    },
    {
      "question": "Berapakah hasil dari 10 + 25?",
      "options": ["30", "35", "40", "45"],
      "correctIndex": 1,
      "explanation": "10 + 25 = 35"
    }
  ]
}''';
}
