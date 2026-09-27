# Spec: Import Bank Soal (JSON)

| | |
|---|---|
| **Status** | Done (v1.0.0) |
| **Modul** | `lib/app/data/services/quiz_import_service.dart`, `lib/app/modules/home/widgets/import_quiz_sheet.dart`, `HomeController` |
| **Route** | Bottom sheet dari `/home` (bukan route). "Mulai" → `/runner` dengan `quizId` |
| **Terkait** | PRD §4.2 |
| **Test** | `test/quiz_import_test.dart` |

## Tujuan
Menambah kuis tanpa AI dengan file `.json`/`.txt` atau teks JSON yang ditempel. Bekerja 100% offline.

## Acceptance Criteria
- [x] Sheet punya 3 tab: pilih file, tempel teks, panduan format (`QuizImportService.sampleTemplate`).
- [x] Menerima objek `{title?, description?, durationMinutes?, questions: [...]}` maupun array langsung `[...]`.
- [x] Menghapus code fence ```` ```json ```` dan teks pembungkus sebelum decode.
- [x] Pengguna bisa mengubah judul & durasi sebelum simpan; bisa "Simpan" atau "Simpan & Mulai".
- [x] Soal tidak valid dilewati; jika tidak ada satu pun yang valid → `ImportException`.
- [x] Sukses → snackbar hijau "Kuis "<judul>" (<n> soal) berhasil diimpor."

## Alias Field yang Diterima

| Makna | Key (urutan prioritas) |
|---|---|
| Judul | `title`, `judul`, `name` |
| Deskripsi | `description`, `deskripsi` |
| Durasi | `durationMinutes`, `duration`, `durasi` (angka atau string angka) |
| Daftar soal | `questions`, `soal`, `data`, `items`, `list_soal` |
| Teks soal | `question`, `soal`, `pertanyaan`, `teks`, `prompt` |
| Opsi | `options`, `pilihan`, `opsi`, `choices`, `jawaban_opsi` — `List` atau `Map` (diurutkan berdasarkan key) |
| Kunci | `correctIndex`, `correct_index`, `kunci`, `jawaban`, `jawabanBenar`, `kunciIndex`, `answer` |
| Pembahasan | `explanation`, `penjelasan`, `pembahasan`, `alasan` |

Kunci jawaban: angka (0-based), huruf `A`–`Z` (→ 0..25), string angka, atau teks yang sama dengan salah satu opsi (case-insensitive). Di luar rentang → `0`.

## Aturan Validasi Soal
- Teks soal tidak kosong.
- Minimal 2 opsi non-kosong.

## Default
- Judul: dari JSON → input pengguna → nama file tanpa ekstensi → `'Kuis Hasil Import'`.
- Durasi: dari JSON (jika > 0) → input pengguna → 15 menit.
- Deskripsi: dari JSON → `'Diimpor dari file/teks JSON'`.

## Known Issues
- Kunci berupa angka 1-based (mis. `"kunci": 1` untuk opsi pertama) akan dianggap 0-based. Tidak ada deteksi otomatis.
- Kunci huruf untuk opsi `Map` bergantung pada urutan sort key; key non-huruf (`"1"`, `"2"`) diurutkan leksikografis (`"10"` sebelum `"2"`).
