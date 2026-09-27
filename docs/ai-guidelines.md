# AI Guidelines — Belajar Bareng AI

Sumber kebenaran tunggal (*single source of truth*) untuk semua asisten AI (Kiro, Claude Code, Cursor, ChatGPT/Claude Web).
File konfigurasi per-tool (`CLAUDE.md`, `.cursor/rules/`, `.kiro/steering/`, `system-prompt.txt`) hanya merujuk ke sini.
**Kalau aturan berubah, ubah di file ini saja.**

Dokumen terkait:
- [PRD.md](PRD.md) — kebutuhan produk lengkap
- [database-schema.md](database-schema.md) — skema Hive & storage
- [specs/](specs/) — spesifikasi per fitur

---

## 1. Tech Stack

| Area | Pilihan | Catatan |
|---|---|---|
| Framework | Flutter (Dart SDK `>=3.0.0 <4.0.0`) | Target: Android, iOS, Web |
| State, DI, Routing | GetX (`get`) | `GetxController`, `Obx`, `.obs`, `GetPage`, `Bindings` |
| Database lokal | Hive + `hive_generator` | TypeAdapter hasil `build_runner` |
| HTTP | Dio | Hanya dipakai di `data/providers/` |
| Secure storage | `flutter_secure_storage` | Web fallback: `shared_preferences` |
| File | `file_picker` | Import JSON & upload materi |
| Web | `webview_flutter`, `url_launcher` | In-app Google search |
| Lint | `flutter_lints` + `prefer_const_constructors` | Lihat `analysis_options.yaml` |
| Test | `flutter_test` | File di `test/*_test.dart` |

Daftar dependency ada di `pubspec.yaml` (setara `package.json`), aturan analyzer di `analysis_options.yaml` (setara `tsconfig.json`).
**Jangan menambah package baru tanpa persetujuan** dan pakai versi yang di-pin (`^x.y.z`).

## 2. Struktur Folder

```
lib/
├── main.dart               # Init Hive, register adapter, Get.put(QuizRepository & SettingsService)
└── app/
    ├── core/
    │   ├── theme/          # AppColors, AppTheme, AppSurfaces (ThemeExtension)
    │   └── widgets/        # Widget lintas modul (AppCard, MobileShell, QuizActionSheet, ...)
    ├── data/
    │   ├── models/         # Model Hive (+ *.g.dart)
    │   ├── providers/      # AiProvider & implementasinya (satu-satunya tempat HTTP)
    │   ├── repositories/   # QuizRepository (satu-satunya akses Hive box kuis)
    │   └── services/       # SettingsService, QuizImportService
    ├── modules/<fitur>/    # <fitur>_view.dart, <fitur>_controller.dart, <fitur>_binding.dart, widgets/
    └── routes/             # app_routes.dart (konstanta), app_pages.dart (GetPage)
test/                       # Unit & widget test
docs/                       # Dokumentasi untuk manusia & AI
```

## 3. Pola Arsitektur

Alur dependensi satu arah: `View → Controller → Repository/Service/Provider → Hive/Dio`.

- **View** (`GetView<XController>`): hanya UI. Tidak ada logika bisnis, tidak memanggil repository langsung. Bungkus bagian reaktif dengan `Obx`.
- **Controller** (`GetxController`): state reaktif (`.obs`), logika layar, navigasi. Ambil dependency lewat `Get.find<T>()`.
- **Binding**: daftarkan controller dengan `Get.lazyPut(() => XController())`.
- **Repository / Service global**: didaftarkan sekali di `main.dart` dengan `Get.put(..., permanent: true)`.
- **AiProvider**: semua pemanggilan LLM lewat interface `AiProvider`. Provider baru = implementasi baru + daftarkan di `SettingsService.buildProvider()` + tambahkan nilai di enum `AiVendor`.
- DTO khusus tampilan (mis. `QuizSummary`, `HistoryItem`) boleh didefinisikan di file controller modulnya.

### Menambah layar baru (checklist)
1. Buat `lib/app/modules/<nama>/` berisi view, controller, binding.
2. Tambah konstanta di `AppRoutes` dan `GetPage` di `AppPages.pages`.
3. Dokumentasikan argumen route di tabel §4.
4. Bungkus konten dengan `MobileShell` agar responsif.
5. Tulis spec di `docs/specs/` (salin `_TEMPLATE.md`).

## 4. Kontrak Argumen Route

Navigasi memakai `Get.toNamed` / `Get.offNamed` dengan `arguments`. Controller wajib menangani argumen tidak valid dengan `Get.back()` + snackbar (lihat `_handleError` di `ResultController`).

| Route | `arguments` |
|---|---|
| `/home`, `/create`, `/history`, `/settings` | — |
| `/runner` | `String quizId` |
| `/result` | `String quizId` (tampilkan hasil tersimpan) **atau** `Map {quizId: String, answers: List<int>, timeUsedSec: int}` (submission baru, akan disimpan) |
| `/review` | `String quizId` **atau** `Map {quizId: String}` **atau** `Map {quiz: Quiz, result: QuizResult}` |

## 5. Standar Koding

- **Bahasa**: teks UI, pesan error, dan komentar dalam **Bahasa Indonesia**. Nama identifier dalam Bahasa Inggris.
- **Penamaan**: file `snake_case.dart`, class `PascalCase`, variabel/method `camelCase`, konstanta privat `_kNamaKey`.
- **Import**: relatif di dalam `lib/` (gaya yang dipakai sekarang); `package:belajar_bareng_ai/...` di dalam `test/`.
- **Const**: gunakan `const` constructor di mana pun memungkinkan (lint aktif).
- **Warna**: pakai `AppColors.*` dan `context.surfaces` (`AppSurfaces`). Jangan hardcode `Color(0x...)` di view baru.
- **Responsif**: gunakan `ResponsiveBreakpoints` (`<600` mobile, `600–899` tablet, `>=900` wide) dan `MobileShell`.
- **Error handling**:
  - Provider melempar `AiException(pesan)`; import melempar `ImportException(pesan)`.
  - Controller menangkap exception dan menampilkan `Get.snackbar('Gagal', pesan, snackPosition: SnackPosition.BOTTOM, ...)`.
  - Pesan error harus bisa dipahami pengguna awam.
- **Logging**: hanya di dalam `if (kDebugMode)`. **Jangan pernah** mencetak API key atau header Authorization.
- **Dispose**: `TextEditingController`, `Timer`, dan stream ditutup di `onClose()`.
- **Offline-first**: fitur baru tidak boleh mewajibkan internet kecuali memang memanggil AI / web.

## 6. Aturan Keamanan

- API key hanya berasal dari input pengguna dan disimpan via `SettingsService` (secure storage). Jangan hardcode, jangan commit.
- Jangan menambahkan analitik/telemetri pihak ketiga.
- Input dari AI dan file import dianggap tidak tepercaya: selalu validasi (min. 2 opsi, `correctIndex` dalam rentang).

## 7. Perubahan Model Hive

Baca [database-schema.md](database-schema.md) sebelum menyentuh `lib/app/data/models/`. Ringkasnya:
- Jangan ubah `typeId` atau nomor `@HiveField` yang sudah ada; tambah field dengan nomor baru.
- Jalankan `dart run build_runner build --delete-conflicting-outputs` lalu commit file `*.g.dart` (file ini memang ikut di-commit).
- Perbarui `database-schema.md` di commit yang sama.

## 8. Testing

- Letakkan test di `test/<fitur>_test.dart`.
- Untuk controller yang butuh repository, pakai fake yang `implements QuizRepository` lalu `Get.put<QuizRepository>(fake)` (contoh: `test/review_feature_test.dart`). Panggil `Get.reset()` di `tearDown`.
- Logika parsing (import, respons AI) wajib punya unit test untuk format baru.

## 9. Perintah

```bash
flutter pub get
flutter analyze                     # wajib bersih sebelum commit
flutter test
dart format lib test
dart run build_runner build --delete-conflicting-outputs   # setelah ubah model Hive
flutter run -d chrome --web-browser-flag "--disable-web-security"   # web lokal (CORS)
```

## 10. Cara Kerja AI di Repo Ini

1. Baca spec fitur terkait di `docs/specs/` sebelum mengubah kode. Kalau belum ada, buat dulu dari `_TEMPLATE.md`.
2. Ikuti pola yang sudah ada di modul lain; jangan memperkenalkan state management / package baru.
3. Perubahan kecil dan terfokus. Jangan merapikan kode yang tidak terkait.
4. Setelah mengubah kode: `flutter analyze` dan `flutter test` harus lulus.
5. Perbarui spec dan dokumen terkait jika perilaku berubah (termasuk bagian "Known Issues").
