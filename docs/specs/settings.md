# Spec: Pengaturan (Tema & AI Provider)

| | |
|---|---|
| **Status** | Done (v1.0.0) |
| **Modul** | `modules/settings/`, `data/services/settings_service.dart` |
| **Route** | `/settings` — tanpa arguments |
| **Terkait** | PRD §4.7, [database-schema.md §4](../database-schema.md#4-key-pengaturan-settingsservice) |
| **Test** | `test/settings_update_test.dart`, `test/theme_test.dart` |

## Acceptance Criteria
- [x] Tema: Terang / Gelap / Sistem, diterapkan langsung (`Get.changeThemeMode`) dan disimpan.
- [x] Toggle cepat di Beranda berpindah antara terang dan gelap (`toggleDarkMode`).
- [x] Pilih vendor mengisi default: OpenAI → `gpt-4o-mini` + `https://api.openai.com/v1`; Anthropic → `claude-3-5-sonnet` + `https://api.anthropic.com/v1`.
- [x] Base URL & model bisa diubah bebas (OpenRouter, LiteLLM, Ollama, dll.).
- [x] API key disimpan lewat `SettingsService` (secure storage di mobile).
- [x] "Test Connection" mengirim prompt `Hello` (`max_tokens: 10`) dan menampilkan snackbar berhasil/gagal (pesan dipotong 200 karakter).
- [x] Kartu update membuka halaman GitHub Actions untuk unduh APK.

## Desain Teknis
- `SettingsService extends GetxService`, didaftarkan permanen di `main.dart`; `load()` dipanggil sebelum `runApp`.
- State reaktif: `provider`, `model`, `baseUrl`, `apiKey`, `themeSetting`, `darkMode` (legacy), `isTestingConnection`.
- `buildProvider()` membuat `AiProvider` baru setiap dipanggil (tidak di-cache).

## Known Issues
- Di web, API key tersimpan **tanpa enkripsi** di SharedPreferences (localStorage).
- `darkMode` hanya dipertahankan untuk kompatibilitas data lama; sumber kebenaran adalah `themeSetting`.
