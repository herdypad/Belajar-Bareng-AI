import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/services/quiz_import_service.dart';
import '../home_controller.dart';

class ImportQuizSheet extends StatefulWidget {
  final HomeController controller;

  const ImportQuizSheet({super.key, required this.controller});

  static Future<void> show(BuildContext context, HomeController controller) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: isTablet ? 640 : double.infinity,
      ),
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ImportQuizSheet(controller: controller),
        ),
      ),
    );
  }

  @override
  State<ImportQuizSheet> createState() => _ImportQuizSheetState();
}

class _ImportQuizSheetState extends State<ImportQuizSheet> {
  int _activeTab = 0; // 0: File, 1: Tempel Teks, 2: Contoh Format
  final TextEditingController _jsonCtrl = TextEditingController();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _durationCtrl = TextEditingController(text: '15');

  ParsedQuizData? _parsedData;
  String? _selectedFileName;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _jsonCtrl.dispose();
    _titleCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await widget.controller.pickAndParseJsonFile();
      if (res != null) {
        setState(() {
          _parsedData = res.data;
          _selectedFileName = res.fileName;
          _titleCtrl.text = res.data.title ?? res.fileName;
          _durationCtrl.text = (res.data.durationMinutes ?? 15).toString();
        });
      }
    } on ImportException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Gagal membaca file: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _parsePastedText() {
    final text = _jsonCtrl.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'Silakan tempel teks JSON terlebih dahulu.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final data = widget.controller.parseJsonText(text);
      setState(() {
        _parsedData = data;
        _titleCtrl.text = data.title ?? 'Kuis Hasil Import';
        _durationCtrl.text = (data.durationMinutes ?? 15).toString();
      });
    } on ImportException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Format JSON salah: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _jsonCtrl.text = data.text!;
      _parsePastedText();
    } else {
      Get.snackbar(
        'Clipboard Kosong',
        'Tidak ada teks yang dapat disalin dari clipboard.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _saveQuiz({bool startImmediately = false}) async {
    if (_parsedData == null) return;

    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'Judul kuis tidak boleh kosong.');
      return;
    }

    final duration = int.tryParse(_durationCtrl.text.trim()) ?? 15;
    if (duration <= 0) {
      setState(() => _errorMessage = 'Durasi harus lebih dari 0 menit.');
      return;
    }

    Navigator.of(context).pop();

    await widget.controller.saveImportedQuiz(
      _parsedData!,
      title: title,
      durationMinutes: duration,
      startImmediately: startImmediately,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.surfaces;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + keyboardBottom),
      decoration: BoxDecoration(
        color: s.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: s.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: s.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.file_upload_outlined, size: 20, color: s.accent),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Soal Kuis',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Impor kuis dari file atau teks berformat JSON',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: s.input,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _tabItem(0, 'Pilih File', Icons.file_present_outlined),
                _tabItem(1, 'Tempel Teks', Icons.code_rounded),
                _tabItem(2, 'Contoh Format', Icons.info_outline),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Error notification if any
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 12, color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Main Tab Body
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_activeTab == 0) _buildFileTab(context, s, isDark),
                  if (_activeTab == 1) _buildTextTab(context, s, isDark),
                  if (_activeTab == 2) _buildSampleTab(context, s, isDark),
                  if (_parsedData != null) ...[
                    const SizedBox(height: 16),
                    _buildPreviewCard(context, s),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    final s = context.surfaces;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = index;
            _errorMessage = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? s.card : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? s.accent : s.muted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? s.accent : s.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileTab(BuildContext context, AppSurfaces s, bool isDark) {
    return InkWell(
      onTap: _isLoading ? null : _pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: s.input.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _parsedData != null ? AppColors.success : s.border,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            if (_isLoading)
              const CircularProgressIndicator(strokeWidth: 2)
            else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_parsedData != null ? AppColors.success : AppColors.primary)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _parsedData != null
                      ? Icons.check_circle_outline
                      : Icons.cloud_upload_outlined,
                  size: 32,
                  color: _parsedData != null ? AppColors.success : s.accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedFileName ?? 'Ketuk untuk memilih file .json',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _parsedData != null ? AppColors.success : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _parsedData != null
                    ? '${_parsedData!.questions.length} soal berhasil dimuat'
                    : 'Mendukung format JSON kuis atau daftar pertanyaan',
                style: TextStyle(fontSize: 12, color: s.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextTab(BuildContext context, AppSurfaces s, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Teks JSON:', style: TextStyle(fontSize: 12, color: s.muted)),
            TextButton.icon(
              onPressed: _pasteFromClipboard,
              icon: const Icon(Icons.paste_rounded, size: 14),
              label: const Text('Tempel Clipboard', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: s.accent,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _jsonCtrl,
          maxLines: 5,
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          decoration: InputDecoration(
            hintText: 'Tempel teks JSON kuis di sini...',
            hintStyle: TextStyle(fontSize: 12, color: s.muted.withValues(alpha: 0.6)),
            filled: true,
            fillColor: s.input,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: s.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: s.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _parsePastedText,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: const Icon(Icons.check_circle_outline, size: 16),
          label: const Text('Validasi & Ekstrak Soal',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildSampleTab(BuildContext context, AppSurfaces s, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Struktur JSON yang didukung:',
                style: TextStyle(fontSize: 12, color: s.muted)),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(
                    const ClipboardData(text: QuizImportService.sampleTemplate));
                Get.snackbar(
                  'Tersalin!',
                  'Contoh JSON berhasil disalin ke clipboard.',
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 14),
              label: const Text('Salin Format', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: s.accent,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: s.input,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: s.border),
          ),
          child: const SelectableText(
            QuizImportService.sampleTemplate,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard(BuildContext context, AppSurfaces s) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      '${_parsedData!.questions.length} Soal Terdeteksi',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Edit title
          Text('Judul Kuis', style: TextStyle(fontSize: 12, color: s.muted)),
          const SizedBox(height: 4),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: s.input,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: s.border),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          // Edit duration
          Text('Durasi Pengerjaan (Menit)', style: TextStyle(fontSize: 12, color: s.muted)),
          const SizedBox(height: 4),
          TextField(
            controller: _durationCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: s.input,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: s.border),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _saveQuiz(startImmediately: false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Simpan Kuis',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveQuiz(startImmediately: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Simpan & Mulai',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
