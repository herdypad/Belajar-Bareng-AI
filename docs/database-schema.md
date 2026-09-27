# Database Schema — Belajar Bareng AI

Aplikasi tidak memakai database server. Semua data disimpan lokal di perangkat:

| Storage | Isi | Diakses lewat |
|---|---|---|
| Hive box `quizzes` | `Quiz` (berisi `List<Question>`) | `QuizRepository` |
| Hive box `results` | `QuizResult` | `QuizRepository` |
| Secure storage (mobile) / SharedPreferences (web) | Pengaturan AI & tema | `SettingsService` |

Sumber kode: `lib/app/data/models/`, `lib/app/data/repositories/quiz_repository.dart`, `lib/app/data/services/settings_service.dart`.

---

## 1. Registry typeId Hive

| typeId | Class | File |
|---|---|---|
| 0 | `Question` | `lib/app/data/models/question.dart` |
| 1 | `Quiz` | `lib/app/data/models/quiz.dart` |
| 2 | `QuizResult` | `lib/app/data/models/quiz_result.dart` |
| 3+ | *(belum dipakai — ambil nomor berikutnya untuk model baru)* | |

Adapter didaftarkan di `lib/main.dart` (`Hive.registerAdapter(...)`) sebelum box dibuka.

## 2. Model

### `Question` (typeId 0) — embedded di `Quiz.questions`

| HiveField | Nama | Tipe | Keterangan |
|---|---|---|---|
| 0 | `question` | `String` | Teks soal |
| 1 | `options` | `List<String>` | Minimal 2, umumnya 4 |
| 2 | `correctIndex` | `int` | Indeks jawaban benar (0-based), selalu dalam rentang `options` |
| 3 | `explanation` | `String` | Pembahasan; boleh kosong |

Punya `fromJson` / `toJson` dengan key: `question`, `options`, `correctIndex`, `explanation`.

### `Quiz` (typeId 1) — box `quizzes`, key = `id`

| HiveField | Nama | Tipe | Keterangan |
|---|---|---|---|
| 0 | `id` | `String` | Format `'q' + millisecondsSinceEpoch`, mis. `q1727000000000` |
| 1 | `title` | `String` | Judul / topik |
| 2 | `description` | `String` | Deskripsi |
| 3 | `totalQuestions` | `int` | Sama dengan `questions.length` saat dibuat |
| 4 | `durationMinutes` | `int` | Durasi timer global |
| 5 | `createdAt` | `DateTime` | Waktu dibuat |
| 6 | `questions` | `List<Question>` | Daftar soal |

### `QuizResult` (typeId 2) — box `results`, key = `quizId`

| HiveField | Nama | Tipe | Keterangan |
|---|---|---|---|
| 0 | `quizId` | `String` | Relasi ke `Quiz.id` |
| 1 | `userAnswers` | `List<int>` | Indeks per soal; `-1` = tidak dijawab |
| 2 | `score` | `int` | Persentase 0–100 (dibulatkan) |
| 3 | `timeUsedSec` | `int` | Detik terpakai; saat auto-submit = durasi penuh |
| 4 | `completedAt` | `DateTime` | Waktu selesai |

## 3. Relasi & Aturan

```
Quiz (1) ──── (0..1) QuizResult      // key sama: Quiz.id == QuizResult.quizId
 └── questions: List<Question>        // embedded, bukan box terpisah
```

- **Satu hasil per kuis.** Mengerjakan ulang akan menimpa `QuizResult` sebelumnya (tidak ada riwayat percobaan).
- `QuizRepository.deleteQuiz(id)` menghapus kuis **dan** hasilnya.
- `getAllQuizzes()` diurutkan `createdAt` menurun (terbaru dulu).

### API `QuizRepository`

```dart
Future<void> init();
List<Quiz> getAllQuizzes();
Quiz? getQuiz(String id);
Future<void> saveQuiz(Quiz quiz);          // put(quiz.id, quiz)
Future<void> deleteQuiz(String id);        // hapus quiz + result
QuizResult? getResult(String quizId);
Future<void> saveResult(QuizResult r);     // put(r.quizId, r)
```

## 4. Key Pengaturan (`SettingsService`)

Disimpan sebagai `String`. Mobile: `flutter_secure_storage`. Web: `shared_preferences` (**tidak terenkripsi**).

| Key | Nilai | Default |
|---|---|---|
| `provider` | `openai` \| `anthropic` | `openai` |
| `model` | nama model | `gpt-4o-mini` |
| `baseUrl` | URL API | `https://api.openai.com/v1` |
| `apiKey` | API key pengguna | `''` |
| `themeSetting` | `light` \| `dark` \| `system` | `dark` |
| `darkMode` | `true` \| `false` | *(legacy, fallback bila `themeSetting` kosong)* |

## 5. Aturan Migrasi

1. **Jangan** mengubah `typeId` atau nomor `@HiveField` yang sudah ada, dan jangan memakai ulang nomor field yang dihapus.
2. Field baru → nomor `@HiveField` berikutnya, dan harus nullable atau punya `defaultValue` (`@HiveField(7, defaultValue: ...)`) supaya data lama tetap terbaca.
3. Model baru → typeId berikutnya di tabel §1, daftarkan adapter di `main.dart`.
4. Jalankan `dart run build_runner build --delete-conflicting-outputs` dan commit `*.g.dart`.
5. Perbarui dokumen ini di commit yang sama.
