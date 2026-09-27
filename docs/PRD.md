# PRD: Aplikasi Latihan Soal dengan AI (Belajar Bareng AI)

Dokumen Spesifikasi Kebutuhan Produk (*Product Requirements Document*) untuk aplikasi **Belajar Bareng AI** (*AI Quiz Trainer*), diperbarui sesuai dengan implementasi kode terkini.

---

## 1. Ringkasan Produk

| Item | Keterangan |
|------|-----------|
| **Nama Produk** | Belajar Bareng AI (AI Quiz Trainer) |
| **Platform** | Cross-platform: Mobile (Android & iOS) dan Web via Flutter |
| **Arsitektur & State Management** | GetX (Pola *View*, *Controller*, *Binding*, dan *GetPage Routing*) |
| **Database Lokal** | Hive (NoSQL *offline-first* dengan TypeAdapter terkompilasi) |
| **Secure Storage** | `flutter_secure_storage` (Mobile) / `shared_preferences` (Web fallback) |
| **HTTP Client** | `dio` untuk komunikasi API AI |
| **Web & Media** | `webview_flutter` (In-App Search WebView) & `url_launcher` (Akses eksternal & update) |
| **File Handling** | `file_picker` (Upload dokumen materi kuis & import file JSON) |
| **Autentikasi** | Tanpa autentikasi / tanpa login (privasi terjaga, data tersimpan di perangkat) |
| **Koneksi Internet** | *Offline-first*: Hanya butuh internet saat generate soal via AI, membuka pencarian WebView Google, dan memeriksa tautan update. Riwayat, pengerjaan kuis, review pembahasan, dan import soal bekerja 100% offline |
| **Dukungan Tema** | Terang (*Light*), Gelap (*Dark*), dan Otomatis (*Follow System*) |

---

## 2. Tujuan & Latar Belakang

**Masalah:** 
- Pelajar, mahasiswa, dan peserta ujian sertifikasi kesulitan menemukan bank soal latihan pilihan ganda yang relevan dan spesifik dengan materi atau silabus belajar mereka.
- Sumber soal latihan sering kali terkunci di balik login berbayar, memerlukan koneksi internet stabil, atau tidak menyediakan penjelasan pembahasan yang memadai.
- Sulit membedah istilah baru saat mempelajari kunci jawaban tanpa harus keluar dari aplikasi.

**Solusi:**
Aplikasi latihan soal berbasis AI yang cepat, privat, dan *offline-first*. Pengguna dapat:
1. Menghasilkan soal secara instan dari topik teks ataupun ringkasan file/dokumen materi (`.txt`, `.md`, `.pdf`).
2. Mengimpor bank soal pilihan ganda sendiri secara bebas menggunakan file atau teks JSON.
3. Mengerjakan kuis dalam lingkungan simulasi ujian dengan timer global dan sistem penandaan soal (*flagging*).
4. Melakukan review komprehensif atas jawaban benar/salah beserta penjelasan AI, dilengkapi fitur pencarian istilah ke Google langsung di dalam aplikasi melalui *in-app* WebView modal.
5. Menyimpan seluruh bank kuis dan hasil nilai secara offline di database lokal.

---

## 3. Persona Pengguna

1. **Pelajar / Mahasiswa:** Membutuhkan latihan soal mandiri untuk ujian sekolah, SBMPTN/UTBK, atau kuis kuliah dengan topik spesifik.
2. **Peserta Ujian / Sertifikasi Profesional:** Butuh simulasi latihan dengan manajemen waktu ujian (timer countdown) dan analisis evaluasi jawaban.
3. **Pengajar / Tutor:** Ingin membuat bank soal cepat atau mengimpor soal yang sudah ada untuk latihan murid tanpa kendala server.
4. **Pembelajar Mandiri (Autodidak):** Ingin menguji pemahaman materi baru dengan cepat, membaca penjelasan kunci jawaban, dan langsung mencari referensi istilah yang belum dipahami via Google.

---

## 4. Fitur Utama (Functional Requirements)

### 4.1 Pembuatan Kuis dengan AI (AI Quiz Generation)
Pengguna membuat kuis baru dengan bantuan Large Language Model (LLM) melalui integrasi API.

- **Input Pengguna:**
  - **Topik / Deskripsi Soal:** Input teks terbuka (misal: "Sejarah Perang Dunia ke-2 di Asia Pasifik").
  - **Rekomendasi Topik Cepat (*Suggestion Chips*):** Tombol cepat untuk topik populer (misal: *Sejarah Indonesia kemerdekaan*, *Matematika dasar SMA*, *Bahasa Inggris TOEFL*, *Pemrograman JavaScript*).
  - **Unggah Dokumen / File Materi:** Pengguna dapat mengunggah file materi berformat `.txt`, `.md`, atau `.pdf`. Konten teks file otomatis dibaca dan digabungkan menjadi konteks materi pembuatan soal bagi AI.
  - **Jumlah Soal:** Integer antara 1 hingga 50 (default: 10 soal).
  - **Waktu Pengerjaan:** Durasi kuis keseluruhan dalam menit (default: 15 menit).
- **Pemrosesan & Integrasi AI Provider:**
  - Prompt terstruktur menginstruksikan AI menghasilkan respon murni JSON berisi daftar pertanyaan, 4 opsi jawaban, indeks jawaban benar, dan pembahasan (*explanation*).
  - Parser cerdas (`AiResponseParser`) yang tangguh mengekstrak JSON dari pembungkus teks bebas atau blok *markdown code fence* (```` ```json ````), serta memvalidasi kelayakan opsi jawaban.
  - Menangani format streaming SSE maupun respons JSON reguler.
  - Setelah selesai digenerate, data kuis langsung disimpan ke Hive dan aplikasi otomatis membuka layar pengerjaan kuis (*Quiz Runner*).

### 4.2 Import Bank Soal Mandiri (Quiz Import Service)
Pengguna dapat menambahkan bank soal latihan tanpa menggunakan kuota atau token API AI.

- **Metode Import:**
  - **Pilih File JSON:** Memilih file `.json` atau `.txt` dari media penyimpanan perangkat menggunakan `file_picker`.
  - **Tempel Teks JSON (*Paste Text*):** Menempelkan teks JSON mentah secara langsung ke kolom input.
  - **Tab Panduan Format:** Contoh format JSON bawaan yang dapat disalin sebagai referensi struktur data.
- **Toleransi & Fleksibilitas Parser (`QuizImportService`):**
  - Mendukung struktur JSON lengkap (`title`, `durationMinutes`, `questions`) maupun array langsung `[{...}]`.
  - Mendukung penamaan field bahasa Indonesia maupun Inggris (contoh: `soal`/`question`, `pilihan`/`options`, `kunci`/`correctIndex`, `pembahasan`/`explanation`).
  - Mendukung penulisan opsi sebagai Array `["A", "B", "C", "D"]` maupun Map objek `{"A": "...", "B": "..."}`.
  - Mendukung kunci jawaban berupa angka index (0–3), abjad huruf (`"A"`, `"B"`, `"C"`, `"D"`), atau pencocokan string teks jawaban.
- **Pratinjau & Aksi:** Pengguna dapat menyesuaikan kembali judul kuis dan durasi menit sebelum menyimpan kuis ke database lokal atau langsung memulainya.

### 4.3 Pengerjaan Kuis (Quiz Runner)
Layar pelaksanaan kuis dengan simulasi ujian yang bersih dan responsif.

- **Timer Global Countdown:** Menghitung mundur total durasi kuis (format MM:SS). Peringatan visual warna merah aktif ketika waktu tersisa di bawah 60 detik.
- **Penyelesaian Otomatis (*Auto-Submit*):** Kuis otomatis diserahkan (*submitted*) begitu waktu habis.
- **Penandaan Soal (*Flagging*):** Tombol bendera di bilah atas untuk menandai nomor soal yang ragu-ragu dengan aksen visual kuning/oranye.
- **Bilah Progres:** Menampilkan status nomor soal aktif ("Soal X dari Y"), jumlah soal yang telah dijawab, dan *linear progress bar*.
- **Interaksi Jawaban:** Pilihan ganda interaktif dengan indikator visual dinamis saat dipilih (lingkaran abjad berganti menjadi centang terisi).
- **Navigasi Soal:** Tombol navigasi mundur (*Sebelumnya*), maju (*Selanjutnya*), dan tombol penyerahan hijau (*Submit Jawaban*) pada nomor soal terakhir.
- **Konfirmasi Keluar:** Proteksi dialog peringatan jika pengguna menekan tombol kembali agar progres pengerjaan tidak hilang tanpa sengaja.
- **Responsif:** Tampilan otomatis mengadaptasi pilihan ganda menjadi grid dua kolom pada tablet / layar lebar.

### 4.4 Hasil & Skor Kuis (Quiz Result)
Layar ringkasan pencapaian yang muncul setelah kuis diserahkan atau waktu habis.

- **Skor Akhir:** Dihitung dalam skala persentase 0–100%.
- **Indikator Cincin / Badge Dinamis:**
  - Skor ≥ 80%: Aksen hijau sukses (*"Luar biasa! 🎉"*).
  - Skor ≥ 60%: Aksen kuning peringatan (*"Bagus, terus belajar!"*).
  - Skor < 60%: Aksen merah (*"Yuk coba lagi, kamu pasti bisa!"*).
- **Statistik Rinci:** Menampilkan jumlah jawaban benar, jumlah jawaban salah, dan total waktu yang dihabiskan dalam menit dan detik.
- **Navigasi & Aksi Lanjutan:**
  - Tombol **Review Jawaban** untuk memeriksa pembahasan setiap nomor soal.
  - Tombol **Ulangi Kuis** (*Retry*) untuk mengerjakan kembali kuis dari awal.
  - Tombol **Beranda** untuk kembali ke halaman utama.
- **Penyimpanan Nilai:** Hasil kuis (`QuizResult`) otomatis diperbarui dan disimpan ke database lokal Hive.

### 4.5 Review Soal & Riset Google Terintegrasi (Quiz Review)
Modul pembahasan komprehensif pasca-ujian untuk evaluasi belajar.

- **Daftar Soal & Opsi Berwarna:**
  - Opsi jawaban benar ditandai dengan latar belakang dan bingkai hijau serta badge *"Kunci Jawaban"* atau *"Jawaban Kamu (Benar)"*.
  - Opsi salah yang dipilih pengguna ditandai dengan latar belakang dan bingkai merah serta badge *"Jawaban Kamu (Salah)"*.
  - Badge status per soal: Benar, Salah, atau Tidak Dijawab.
- **Kartu Pembahasan (*Explanation*):** Menampilkan penjelasan ilmiah/alasan jawaban benar dari AI atau dokumen soal.
- **Pencarian Google Terintegrasi via In-App WebView (`GoogleSearchWebViewSheet`):**
  - Seluruh teks soal, opsi, dan pembahasan didukung oleh widget `SelectionArea`.
  - Pengguna dapat memblok/menyeleksi kata kunci atau kalimat yang ingin dipelajari lebih dalam, lalu memilih menu **"Cari di Google 🔍"** pada toolbar seleksi teks.
  - Aplikasi membuka *modal bottom sheet* interaktif yang memuat hasil pencarian Google menggunakan `webview_flutter`.
  - Dilengkapi fitur: bilah loading progress, tombol *refresh*, tombol navigasi web (*back* & *forward*), serta tombol untuk membuka tautan di browser eksternal via `url_launcher`.
- **Tata Letak Adaptif:** Pada layar tablet landscape / desktop, halaman membagi tampilan menjadi dua kolom (kolom kiri: pertanyaan & opsi; kolom kanan: status & pembahasan).

### 4.6 Beranda & Riwayat Kuis (Home & History)
Pusat manajemen dan arsip kuis pengguna.

- **Beranda (Home):**
  - Kartu ucapan, tombol toggle tema instan (Terang/Gelap), dan pintasan ke Pengaturan.
  - Banner CTA hero (*Hero Gradient*) dengan opsi "Buat Kuis Baru" dan "Import Soal".
  - Kartu statistik performa: Total Kuis yang dimiliki dan Nilai Rata-rata (*Average Score*).
  - Daftar "Kuis Terbaru" dengan informasi judul, jumlah soal, estimasi menit, nilai terakhir, serta tombol review cepat.
- **Riwayat Lengkap (History):**
  - Menampilkan seluruh arsip kuis yang diurutkan dari yang paling baru dibuat.
  - Menyertakan tanggal pembuatan, jumlah soal, durasi waktu, dan skor terakhir.
- **Lembar Aksi Kuis Terpadu (`QuizActionSheet`):**
  - Mengetuk kuis yang sudah pernah dikerjakan memunculkan bottom sheet opsi:
    1. **Review Jawaban** (buka evaluasi pembahasan).
    2. **Lihat Hasil** (buka layar skor).
    3. **Kerjakan Ulang** (reset dan mulai runner baru).
    4. **Hapus Kuis** (menghapus data kuis dan riwayat nilainya dari database Hive).

### 4.7 Pengaturan Aplikasi (Settings)
Pusat konfigurasi sistem, AI provider, dan pembaruan aplikasi.

- **Pengaturan Tema Tampilan:** Pilihan 3 opsi tema: **Terang** (*Light*), **Gelap** (*Dark*), dan **Sistem** (*Follow System*). Perubahan tema langsung diterapkan ke seluruh aplikasi secara reaktif.
- **Manajemen AI Provider:**
  - Pilihan Vendor: **OpenAI** (termasuk OpenAI-compatible endpoints) atau **Anthropic**.
  - **Base URL:** Dapat diubah sesuai kebutuhan (misalnya proxy endpoint, OpenRouter, LiteLLM, atau server lokal Ollama dengan kompatibilitas OpenAI).
  - **Model:** Dapat ditentukan secara bebas (default: `gpt-4o-mini` untuk OpenAI, `claude-3-5-sonnet` untuk Anthropic).
  - **API Key:** Kunci otentikasi disimpan aman menggunakan `flutter_secure_storage` (dienkripsi pada Keychain/Keystore perangkat).
- **Pengujian Koneksi (*Test Connection*):** Tombol untuk memverifikasi kevalidan API key, model, dan base URL sebelum membuat kuis. Dilengkapi pesan umpan balik (berhasil/gagal).
- **Pembaruan Aplikasi (*App Update*):** Kartu informasi pembaruan sistem yang terhubung langsung ke halaman rilis GitHub Actions untuk mengunduh APK versi terbaru secara mudah.

---

## 5. Kebutuhan Non-Fungsional (Non-Functional Requirements)

1. **Desain Visual & Estetika (Material 3 & ThemeExtension):**
   - Menggunakan tema Material 3 modern dengan palet warna ungu premium (*Lilac* `#C4B5FD`, *Primary* `#7C3AED`, *Dark BG* `#0F0B1E`, *Dark Card* `#1A1530`).
   - Ekstensi tema kustom `AppSurfaces` untuk konsistensi warna kartu, border, input field, dan teks *muted*.
2. **Desain Responsif & Multi-device:**
   - Menggunakan utilitas `ResponsiveBreakpoints` dan `MobileShell`:
     - *Mobile (< 600px):* Konten dibatasi hingga lebar maksimal ~480px untuk ergonomi genggaman satu tangan.
     - *Tablet Portrait (600px–899px):* Lebar konten diperluas hingga ~860px dengan tata letak grid untuk kartu kuis dan opsi jawaban.
     - *Tablet Landscape / Desktop (≥ 900px):* Lebar konten hingga ~1040px dengan pembagian tata letak dua kolom (misal: review soal dan pengaturan).
3. **Offline-First & Kinerja Cepat:**
   - Semua operasi baca/tulis kuis, jawaban, dan hasil nilai dieksekusi secara lokal via Hive tanpa ketergantungan jaringan.
4. **Keamanan & Privasi Data:**
   - Tanpa analitik pihak ketiga yang merekam isi soal atau identitas pengguna.
   - API key tersimpan di secure storage lokal dan tidak pernah dibagikan atau diunggah ke repositori.
5. **Robust Error Handling:**
   - Menangani kegagalan JSON parsing, kegagalan jaringan HTTP, CORS restriction pada web, format dokumen tidak valid, dan status timeout secara visual melalui notifikasi Snackbar GetX.

---

## 6. Arsitektur Teknis

### 6.1 Diagram Alur Data

```
┌────────────────────────────────────────────────────────┐
│                      PENGGUNA                          │
└──────────────┬─────────────────────────┬───────────────┘
               │                         │
       [Buat Kuis Baru]           [Import Soal]
               │                         │
               ▼                         ▼
┌──────────────────────────────┐ ┌──────────────────────┐
│  CreateQuizController        │ │  QuizImportService   │
│  - Topik Teks                │ │  - File JSON (.json) │
│  - File Materi (txt/md/pdf)  │ │  - Paste Teks JSON   │
└──────────────┬───────────────┘ └──────────┬───────────┘
               │                            │
               ▼                            │
┌──────────────────────────────┐            │
│  AiProvider (Dio)            │            │
│  - OpenAiProvider            │            │
│  - AnthropicProvider         │            │
└──────────────┬───────────────┘            │
               │ (Parse JSON)               │
               ▼                            ▼
┌────────────────────────────────────────────────────────┐
│           QuizRepository (Hive Local Storage)          │
│               - Box<Quiz>                              │
│               - Box<QuizResult>                        │
└──────────────┬─────────────────────────┬───────────────┘
               │                         │
               ▼                         ▼
┌──────────────────────────────┐ ┌──────────────────────┐
│  QuizRunnerController        │ │  HomeController      │
│  - Timer Countdown           │ │  - Daftar Kuis       │
│  - Jawaban & Flagging        │ │  - Riwayat & Skor    │
└──────────────┬───────────────┘ └──────────────────────┘
               │
               ▼
┌──────────────────────────────┐
│  ResultController            │
│  - Skor, Ringkasan Nilai     │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐      ┌─────────────────────────┐
│  ReviewController            │ ───▶ │ GoogleSearchWebView     │
│  - Kunci vs Jawaban User     │      │ (In-App Search WebView) │
│  - Penjelasan AI             │      └─────────────────────────┘
└──────────────────────────────┘
```

### 6.2 Struktur Folder Proyek

```
lib/
├── main.dart                          # Inisialisasi Hive, Repository, Settings, Root App
└── app/
    ├── core/
    │   ├── theme/
    │   │   ├── app_colors.dart        # Palet warna primer, surface, gradien
    │   │   └── app_theme.dart         # Material 3 Theme, AppSurfaces ThemeExtension
    │   └── widgets/
    │       ├── app_card.dart          # Komponen kartu konsisten
    │       ├── circle_icon_button.dart# Tombol ikon melingkar
    │       ├── google_search_webview_sheet.dart # In-app WebView modal pencarian Google
    │       ├── mobile_shell.dart      # Breakpoint & pembatas kontainer responsif
    │       └── quiz_action_sheet.dart # Bottom sheet aksi kuis (Review, Skor, Retry, Hapus)
    ├── data/
    │   ├── models/
    │   │   ├── question.dart          # Model Question (+ TypeAdapter Hive typeId: 0)
    │   │   ├── quiz.dart              # Model Quiz (+ TypeAdapter Hive typeId: 1)
    │   │   └── quiz_result.dart       # Model QuizResult (+ TypeAdapter Hive typeId: 2)
    │   ├── providers/
    │   │   ├── ai_provider.dart       # Kontrak abstrak AiProvider & prompt builder
    │   │   ├── ai_response_parser.dart# Ekstraksi dan sanitasi JSON dari respon AI
    │   │   ├── anthropic_provider.dart# Implementasi API Anthropic Messages
    │   │   └── openai_provider.dart   # Implementasi API OpenAI Chat Completions & SSE
    │   ├── repositories/
    │   │   └── quiz_repository.dart   # CRUD Hive Box untuk Quiz & QuizResult
    │   └── services/
    │       ├── quiz_import_service.dart # Parser file/teks JSON untuk import kuis
    │       └── settings_service.dart    # Service reactive GetX untuk tema, AI vendor & API key
    ├── modules/
    │   ├── create_quiz/               # Form buat kuis AI, upload file, chip saran
    │   ├── history/                   # Daftar riwayat kuis & manajemen hapus
    │   ├── home/                      # Beranda, statistik ringkas, hero CTA, import sheet
    │   ├── quiz_runner/               # Pelaksanaan kuis, timer countdown, navigasi, flag
    │   ├── result/                    # Skor persentase, benar/salah, durasi waktu
    │   ├── review/                    # Pembahasan soal & seleksi teks pencarian Google
    │   └── settings/                  # Konfigurasi tema, vendor AI, API key, test koneksi, update APK
    └── routes/
        ├── app_pages.dart             # Konfigurasi GetPage & Bindings
        └── app_routes.dart            # Konstanta rute aplikasi (/home, /create, /runner, dll.)
```

---

## 7. Model Data

### 7.1 Model Hive (Persisten)

#### 1. `Question` (typeId: 0)
```dart
class Question {
  final String question;           // Teks pertanyaan
  final List<String> options;      // Daftar pilihan jawaban (biasanya 4 opsi)
  final int correctIndex;          // Indeks jawaban benar (0-based)
  final String explanation;       // Pembahasan / alasan jawaban benar
}
```

#### 2. `Quiz` (typeId: 1)
```dart
class Quiz {
  final String id;                 // ID unik kuis (misal: 'q1727000000000')
  final String title;              // Judul / topik kuis
  final String description;        // Deskripsi kuis
  final int totalQuestions;        // Total butir soal
  final int durationMinutes;       // Alokasi durasi pengerjaan (menit)
  final DateTime createdAt;        // Waktu pembuatan kuis
  final List<Question> questions;  // Daftar objek Question
}
```

#### 3. `QuizResult` (typeId: 2)
```dart
class QuizResult {
  final String quizId;             // Relasi ke Quiz.id
  final List<int> userAnswers;     // Pilihan jawaban user (-1 = tidak dijawab)
  final int score;                 // Skor akhir persentase (0–100)
  final int timeUsedSec;           // Waktu pengerjaan yang terpakai (detik)
  final DateTime completedAt;      // Waktu selesai kuis
}
```

### 7.2 Model Layanan & Tampilan

- **`ParsedQuizData`**: Data kuis hasil parsing dari service import sebelum disimpan.
- **`QuizSummary`**: DTO untuk menampilkan ringkasan kuis dan nilai terakhir pada Beranda.
- **`HistoryItem`**: DTO untuk menampilkan item pada daftar Riwayat kuis.

---

## 8. Format Data JSON yang Diharapkan

### 8.1 Format Standar Respon AI & Import
```json
{
  "title": "Kuis Sejarah Indonesia",
  "durationMinutes": 15,
  "questions": [
    {
      "question": "Siapakah proklamator kemerdekaan Indonesia?",
      "options": [
        "Soekarno dan Mohammad Hatta",
        "Sutan Sjahrir dan Agus Salim",
        "Sudirman dan Ahmad Yani",
        "Ki Hajar Dewantara dan Wahid Hasyim"
      ],
      "correctIndex": 0,
      "explanation": "Soekarno dan Mohammad Hatta adalah proklamator kemerdekaan Indonesia yang membacakan naskah proklamasi pada 17 Agustus 1945."
    }
  ]
}
```

---

## 9. Alur Pengguna (User Journey)

1. **Alur Kuis AI:**
   `Beranda` ➔ Tap *"Buat Kuis Baru"* ➔ Isi topik atau unggah dokumen materi (`.txt`/`.md`/`.pdf`) ➔ Tentukan jumlah soal & durasi ➔ Tap *"Generate Kuis"* ➔ Masuk otomatis ke `Quiz Runner`.
2. **Alur Import Soal:**
   `Beranda` ➔ Tap *"Import Soal"* ➔ Pilih file JSON atau tempel teks JSON ➔ Review hasil parsing (judul, durasi, jumlah soal) ➔ Simpan kuis atau langsung mulai.
3. **Alur Pengerjaan & Penilaian:**
   `Quiz Runner` ➔ Jawab soal, gunakan navigasi & tanda ragu-ragu (*Flag*) ➔ Selesai atau waktu habis (*Auto-submit*) ➔ Layar `Result` menampilkan skor dan statistik waktu.
4. **Alur Evaluasi & Riset:**
   Layar `Result` / `Riwayat` ➔ Tap *"Review Jawaban"* ➔ Pelajari kunci jawaban dan penjelasan ➔ Blok teks yang belum dipahami ➔ Tap menu *"Cari di Google 🔍"* ➔ Pelajari materi via WebView tanpa meninggalkan aplikasi.
5. **Alur Manajemen Kuis:**
   Tap kuis pada `Beranda` atau `Riwayat` ➔ Muncul menu `QuizActionSheet` ➔ Pilih Review, Lihat Hasil, Kerjakan Ulang (*Retry*), atau Hapus Kuis.

---

## 10. Status Implementasi & Roadmap Pengembangan

### 10.1 Fitur yang Sudah Terimplementasi Penuh (v1.0.0)
- [x] Generator kuis pilihan ganda berbasis AI (OpenAI & Anthropic).
- [x] Pembuatan kuis dari dokumen materi (`.txt`, `.md`, `.pdf`).
- [x] Import kuis dari file atau teks JSON dengan parser fleksibel.
- [x] Database lokal NoSQL *offline-first* dengan Hive.
- [x] Manajemen timer countdown global dan auto-submit saat habis.
- [x] Sistem penandaan soal (*flagging*) saat pengerjaan.
- [x] Evaluasi nilai persentase, kalkulasi jawaban benar/salah, dan waktu pengerjaan.
- [x] Layar review detail dengan penanda visual status jawaban.
- [x] In-app Google Search WebView dari seleksi teks pada review soal.
- [x] Lembar aksi kuis (*QuizActionSheet*) dengan opsi Kerjakan Ulang dan Hapus Kuis.
- [x] Tema aplikasi: Terang, Gelap, dan Otomatis mengikuti sistem.
- [x] Tata letak responsif untuk Mobile, Tablet Portrait, dan Tablet Landscape/Desktop.
- [x] Uji koneksi AI (*Test Connection*) di menu Pengaturan.
- [x] Integrasi tautan pembaruan APK via GitHub Actions.

### 10.2 Roadmap Masa Depan (Future Work)
- [ ] Pengaturan opsi timer per soal (selain timer global kuis).
- [ ] Dukungan tipe soal non-pilihan ganda (isian singkat, benar/salah).
- [ ] Ekspor bank kuis yang ada ke dalam file JSON untuk dibagikan antar pengguna.
- [ ] Grafik analitik progres belajar dan statistik ketuntasan materi per kategori/topik.
- [ ] Integrasi *Speech-to-Text* untuk pembuatan soal dari rekaman audio perkuliahan.
