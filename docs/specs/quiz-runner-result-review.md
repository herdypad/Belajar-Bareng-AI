# Spec: Pengerjaan, Hasil & Review Kuis

| | |
|---|---|
| **Status** | Done (v1.0.0) |
| **Modul** | `modules/quiz_runner/`, `modules/result/`, `modules/review/`, `core/widgets/google_search_webview_sheet.dart` |
| **Route** | Lihat tabel argumen di [ai-guidelines.md §4](../ai-guidelines.md#4-kontrak-argumen-route) |
| **Terkait** | PRD §4.3–4.5 |
| **Test** | `test/review_feature_test.dart`, `test/google_search_webview_test.dart`, `test/tablet_responsive_test.dart` |

## Alur
```
/runner (quizId) ──submit──▶ /result (Map answers) ──▶ /review (Map quiz+result)
                                  │ retry → /runner      └── seleksi teks → GoogleSearchWebViewSheet
                                  └ home → Get.until('/home')
```

## Quiz Runner — Acceptance Criteria
- [x] Timer global `durationMinutes * 60` detik, label `MM:SS`, merah bila `< 60` detik.
- [x] Waktu habis → `submit(auto: true)`, `timeUsedSec` = durasi penuh.
- [x] `answers` diinisialisasi `-1` untuk setiap soal; `flagged` = `Set<int>` indeks soal.
- [x] Submit hanya sekali (`_submitted`), timer dibatalkan, lalu `Get.offNamed('/result', arguments: {quizId, answers, timeUsedSec})`.
- [x] Tombol back → dialog konfirmasi "Keluar dari kuis?"; progres tidak disimpan.
- [x] Kuis tidak ditemukan → kembali (`Get.back()`).
- [x] Tablet: opsi jawaban grid 2 kolom.

## Result — Acceptance Criteria
- [x] `score = round(correct / total * 100)`.
- [x] Verdict: `>= 80` "Luar biasa! 🎉" (hijau), `>= 60` "Bagus, terus belajar!" (kuning), selain itu "Yuk coba lagi, kamu pasti bisa!" (merah).
- [x] Submission baru → `QuizResult` disimpan (menimpa hasil lama).
- [x] Argumen `String quizId` → tampilkan hasil tersimpan; jika belum pernah dikerjakan → back + snackbar.

## Review — Acceptance Criteria
- [x] Navigasi per soal (`currentIndex`), status Benar / Salah / Tidak Dijawab.
- [x] Opsi benar hijau, pilihan salah pengguna merah, beserta badge.
- [x] Teks dalam `SelectionArea`; menu seleksi "Cari di Google 🔍" membuka WebView bottom sheet (refresh, back/forward, buka di browser).
- [x] Layar `>= 900px`: dua kolom (soal & opsi | status & pembahasan).

## Known Issues
- Progres pengerjaan tidak dipersist; aplikasi ditutup = jawaban hilang.
- Hanya satu `QuizResult` per kuis; riwayat percobaan sebelumnya tertimpa.
- Status `flagged` tidak ikut disimpan ke hasil.
