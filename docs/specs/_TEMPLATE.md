# Spec: <Nama Fitur>

| | |
|---|---|
| **Status** | Draft / In Progress / Done |
| **Modul** | `lib/app/modules/<nama>/` |
| **Route** | `/<nama>` — arguments: `<tipe>` |
| **Terkait** | PRD §x, spec lain |

## Tujuan
Satu-dua kalimat: masalah apa yang diselesaikan dan untuk siapa.

## User Story
- Sebagai <persona>, saya ingin <aksi> agar <manfaat>.

## Acceptance Criteria
- [ ] KETIKA <kondisi>, MAKA sistem <perilaku yang bisa diuji>.
- [ ] KETIKA <input tidak valid>, MAKA sistem menampilkan snackbar "<pesan>".

## Desain Teknis
- **File baru / diubah:**
  - `lib/app/...` — alasan
- **State controller:** `field.obs` — arti
- **Data:** model/field Hive baru? (kalau ya, perbarui `docs/database-schema.md`)
- **Dependency baru:** tidak ada / nama package + alasan

## Edge Case
- Offline:
- Data kosong:
- Layar tablet (≥600px):

## Test
- `test/<nama>_test.dart`: kasus yang diuji

## Di Luar Cakupan
- Hal yang sengaja tidak dikerjakan.

## Known Issues
- 
