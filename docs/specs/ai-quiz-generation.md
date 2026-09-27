# Spec: Pembuatan Kuis dengan AI

| | |
|---|---|
| **Status** | Done (v1.0.0) |
| **Modul** | `lib/app/modules/create_quiz/`, `lib/app/data/providers/` |
| **Route** | `/create` — tanpa arguments. Sukses → `Get.offNamed('/runner', arguments: quizId)` |
| **Terkait** | PRD §4.1, [settings.md](settings.md) |

## Tujuan
Pengguna membuat kuis pilihan ganda dari topik teks dan/atau file materi, dihasilkan oleh LLM.

## Acceptance Criteria
- [x] Tombol generate aktif hanya jika (`topic.trim().length > 3` **atau** ada konten file) **dan** `1 <= count <= 50` **dan** `minutes >= 1`.
- [x] Chip saran mengisi field topik (`CreateQuizController.suggestions`).
- [x] Upload file menerima `.txt`, `.md`, `.pdf`; konten digabung ke prompt sebagai konteks.
- [x] Saat loading, tombol dinonaktifkan (`loading.value`), generate ganda diabaikan.
- [x] Hasil disimpan ke Hive (`QuizRepository.saveQuiz`) lalu langsung membuka Quiz Runner.
- [x] Judul kuis = topik; jika kosong pakai nama file; jika tidak ada, `'Quiz dari File'`.
- [x] Error `AiException` ditampilkan sebagai snackbar merah "Gagal".

## Desain Teknis
- `AiProvider` (abstrak): `generateQuestions({topic, count})`, `testConnection()`.
- `buildPrompt()` di `ai_provider.dart` — prompt bersama, meminta JSON `{"questions":[{question, options[4], correctIndex, explanation}]}`.
- `parseQuestions()` di `ai_response_parser.dart` — ambil substring `{ ... }` terluar, decode, buang soal dengan opsi < 2.
- `OpenAiProvider`: `POST {baseUrl}/chat/completions`, header `Authorization: Bearer`, `response_format: json_object`. Menangani respons `Map` maupun `String` (SSE/teks).
- `AnthropicProvider`: `POST {baseUrl}/messages`, header `x-api-key`, `anthropic-version: 2023-06-01`, `max_tokens: 4096`.
- Provider dipilih lewat `SettingsService.buildProvider()`.

### Menambah provider AI baru
1. Buat `lib/app/data/providers/<nama>_provider.dart` yang `implements AiProvider`.
2. Pakai `buildPrompt()` dan `parseQuestions()` agar format konsisten.
3. Tambah nilai enum `AiVendor`, cabang di `buildProvider()`, `selectProvider()` (default model/baseUrl), serta `load()`/`save()` di `SettingsService`.
4. Tambah opsi di `settings_view.dart`.

## Edge Case
- API key kosong → `AiException('API key ... belum diatur. Buka Pengaturan.')`.
- Web → request langsung ke API diblokir CORS (lihat README).
- AI mengembalikan soal lebih sedikit dari `count` → diterima apa adanya; `totalQuestions = questions.length`.

## Known Issues
- File `.pdf` dibaca dengan `File.readAsString()` (mobile) / `String.fromCharCodes` (web) sehingga PDF biner menghasilkan teks rusak atau error. Butuh parser PDF.
- Tidak ada batas ukuran konten file; materi panjang bisa melebihi context window model.
- `AnthropicProvider.generateQuestions` tidak me-`rethrow` `AiException`, sehingga pesan dari parser terbungkus menjadi "Terjadi kesalahan: ...".
- `CreateQuizController._showError` memanggil `print` di luar `kDebugMode`.
