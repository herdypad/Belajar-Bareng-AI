# PRD: Aplikasi Latihan Soal dengan AI (Belajar Bareng AI)

## 1. Ringkasan Produk

| Item | Keterangan |
|------|-----------|
| Nama Produk | Belajar Bareng AI (AI Quiz Trainer) |
| Platform | Mobile (Android & iOS) via Flutter |
| State Management | GetX |
| Database | Lokal (offline) |
| Autentikasi | Tidak ada |
| Koneksi Internet | Hanya saat generate soal (panggil AI). Riwayat & review offline |

## 2. Tujuan & Latar Belakang

**Masalah:** Pelajar/peserta ujian kesulitan menemukan soal latihan yang sesuai dengan topik spesifik mereka.

**Solusi:** Aplikasi yang men-generate soal pilihan ganda secara instan dari deskripsi topik menggunakan AI, lalu menyimpannya secara lokal agar bisa dikerjakan ulang kapan saja secara offline.

**Tujuan:**
- Generate soal latihan dalam hitungan detik
- Pengalaman ujian dengan timer realistis
- Belajar dari kesalahan lewat fitur review
- Privasi terjaga (data tersimpan lokal, tanpa login)

## 3. Persona Pengguna

- Pelajar/Mahasiswa yang ingin latihan soal untuk topik tertentu
- Peserta ujian/sertifikasi yang butuh simulasi waktu pengerjaan
- Pengajar yang ingin membuat bank soal cepat

## 4. Fitur Utama (Functional Requirements)

### 4.1 Pembuatan Kuis (AI Generation)

User mengisi form input lalu AI menghasilkan soal.

**Input dari user:**
- Deskripsi soal / topik (text, wajib)
- Jumlah soal (integer, misal 1-50)
- Waktu pengerjaan (menit, untuk keseluruhan kuis, bukan per soal)

**Proses:**
- Aplikasi mengirim prompt terstruktur ke provider AI terpilih
- AI mengembalikan soal dalam format Pilihan Ganda (JSON terstruktur)
- Setiap soal punya: pertanyaan, 4 opsi jawaban, 1 jawaban benar, dan penjelasan (untuk review)
- Soal disimpan ke database lokal

**Format JSON yang diharapkan dari AI:**
```json
{
  "questions": [
    {
      "question": "Teks pertanyaan",
      "options": ["A", "B", "C", "D"],
      "correctIndex": 2,
      "explanation": "Penjelasan jawaban benar"
    }
  ]
}
```

### 4.2 Pengerjaan Kuis (Quiz Runner)

- Menampilkan soal satu per satu (atau scrollable)
- Timer global (countdown total waktu kuis, bukan per soal)
- Kuis otomatis selesai (auto-submit) saat waktu habis
- User bisa submit manual sebelum waktu habis
- Navigasi antar soal (next/previous), tandai soal

### 4.3 Hasil & Skor

- Menampilkan skor (jumlah benar, persentase)
- Waktu yang digunakan
- Ringkasan benar/salah

### 4.4 Review Soal

- Setelah selesai, user bisa melihat tiap soal
- Menampilkan jawaban user, jawaban benar, dan penjelasan dari AI
- Penanda visual benar (hijau) / salah (merah)

### 4.5 Riwayat Kuis (History)

- Daftar semua kuis yang pernah dibuat & dikerjakan
- Tersimpan offline di database lokal
- Bisa dikerjakan ulang atau dilihat review-nya
- Informasi: judul/topik, tanggal, skor terakhir, jumlah soal

### 4.6 Pengaturan (Settings)

- Pilih AI Provider: OpenAI atau Anthropic
- Input API Key (disimpan aman di local secure storage)
- Pilih model (opsional, misal `gpt-4o-mini` / `claude-3-5-sonnet`)
- Tema (light/dark) - opsional

## 5. Kebutuhan Non-Fungsional

- **UI Modern:** Material 3, animasi halus, desain bersih, dukungan dark mode
- **Offline-first:** Semua data (kecuali generate) berfungsi tanpa internet
- **Keamanan:** API key disimpan via `flutter_secure_storage`
- **Performa:** Generate soal dengan loading state & error handling
- **Responsif:** Mendukung berbagai ukuran layar

## 6. Arsitektur Teknis (Saran)

| Layer | Teknologi |
|-------|-----------|
| UI | Flutter, Material 3 |
| State Management | GetX (`GetxController`, `Obx`, `Get.to`) |
| Routing | GetX Routing (`GetPage`) |
| Database Lokal | `Hive` atau `Isar` (cepat, NoSQL, cocok untuk offline) |
| HTTP Client | `dio` (untuk panggil API AI) |
| Secure Storage | `flutter_secure_storage` (API key) |

**Struktur folder (pola GetX):**
```
lib/
├── app/
│   ├── data/
│   │   ├── models/        # QuizModel, QuestionModel, ResultModel
│   │   ├── providers/     # AiProvider (OpenAI, Anthropic)
│   │   └── repositories/  # QuizRepository (Hive/Isar)
│   ├── modules/
│   │   ├── home/          # daftar + buat kuis
│   │   ├── create_quiz/   # form input
│   │   ├── quiz_runner/   # pengerjaan + timer
│   │   ├── result/        # skor & review
│   │   ├── history/       # riwayat
│   │   └── settings/      # pilih provider & API key
│   ├── routes/            # app_pages.dart, app_routes.dart
│   └── core/              # theme, constants, utils
└── main.dart
```

## 7. Model Data (Lokal)

- **Quiz:** `id, title, description, totalQuestions, durationMinutes, createdAt, List<Question>`
- **Question:** `question, options[], correctIndex, explanation`
- **QuizResult:** `quizId, userAnswers[], score, timeUsed, completedAt`

## 8. Alur Pengguna (User Flow)

1. **Home** -> tombol "Buat Kuis Baru"
2. **Create Quiz** -> isi deskripsi, jumlah soal, waktu -> tap "Generate"
3. AI generate -> simpan ke lokal -> **Quiz Runner** dimulai (timer global jalan)
4. User kerjakan -> submit / waktu habis -> **Result** (skor)
5. Dari Result -> tap "Review" -> lihat pembahasan tiap soal
6. **History** -> akses semua kuis lama, kerjakan ulang / review

## 9. Out of Scope (Versi 1)

- Login / akun pengguna
- Sinkronisasi cloud
- Tipe soal selain pilihan ganda (essay, isian)
- Sharing kuis antar pengguna
- Timer per soal

## 10. Success Metrics

- Waktu generate soal < 15 detik
- Kuis dapat dikerjakan & direview sepenuhnya offline
- Tingkat keberhasilan parsing JSON dari AI > 95%
