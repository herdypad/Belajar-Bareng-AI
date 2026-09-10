import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/quiz.dart';
import '../../data/providers/ai_provider.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/services/settings_service.dart';
import '../../routes/app_routes.dart';

class CreateQuizController extends GetxController {
  final QuizRepository _repo = Get.find<QuizRepository>();
  final SettingsService _settings = Get.find<SettingsService>();

  final topic = ''.obs;
  final count = 10.obs;
  final minutes = 15.obs;
  final loading = false.obs;
  final uploadedFile = Rxn<PlatformFile>();
  final fileContent = ''.obs;

  final topicCtrl = TextEditingController();
  final countCtrl = TextEditingController(text: '10');
  final minutesCtrl = TextEditingController(text: '15');

  static const suggestions = [
    'Sejarah Indonesia kemerdekaan',
    'Matematika dasar SMA',
    'Bahasa Inggris TOEFL',
    'Pemrograman JavaScript',
  ];

  bool get valid =>
      (topic.value.trim().length > 3 || fileContent.value.isNotEmpty) &&
      count.value >= 1 &&
      count.value <= 50 &&
      minutes.value >= 1;

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'pdf'],
        withData: kIsWeb,
        withReadStream: !kIsWeb,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      uploadedFile.value = file;

      // Read file content
      String content = '';
      if (kIsWeb) {
        // Web: use bytes
        if (file.bytes != null) {
          content = String.fromCharCodes(file.bytes!);
        }
      } else {
        // Mobile/Desktop: use path
        if (file.path != null) {
          final fileObj = File(file.path!);
          content = await fileObj.readAsString();
        }
      }

      fileContent.value = content;

      Get.snackbar(
        'Berhasil',
        'File "${file.name}" berhasil diunggah',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF34D399),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _showError('Gagal membaca file: $e');
    }
  }

  void clearFile() {
    uploadedFile.value = null;
    fileContent.value = '';
  }

  void setTopic(String v) {
    topic.value = v;
    if (topicCtrl.text != v) {
      topicCtrl.value = TextEditingValue(
        text: v,
        selection: TextSelection.collapsed(offset: v.length),
      );
    }
  }

  void setCount(String v) => count.value = int.tryParse(v) ?? 0;
  void setMinutes(String v) => minutes.value = int.tryParse(v) ?? 0;

  Future<void> generate() async {
    if (!valid || loading.value) return;
    loading.value = true;
    try {
      final provider = _settings.buildProvider();
      
      // Build topic/context from text input and file content
      String contextTopic = topic.value.trim();
      if (fileContent.value.isNotEmpty) {
        if (contextTopic.isEmpty) {
          contextTopic = 'Berdasarkan konten file berikut:\n\n${fileContent.value}';
        } else {
          contextTopic = '$contextTopic\n\nKonten file:\n${fileContent.value}';
        }
      }
      
      final questions = await provider.generateQuestions(
        topic: contextTopic,
        count: count.value,
      );

      final displayTitle = topic.value.trim().isNotEmpty 
          ? topic.value.trim() 
          : uploadedFile.value?.name ?? 'Quiz dari File';

      final quiz = Quiz(
        id: 'q${DateTime.now().millisecondsSinceEpoch}',
        title: displayTitle,
        description: displayTitle,
        totalQuestions: questions.length,
        durationMinutes: minutes.value,
        createdAt: DateTime.now(),
        questions: questions,
      );
      await _repo.saveQuiz(quiz);

      Get.offNamed(AppRoutes.runner, arguments: quiz.id);
    } on AiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Gagal membuat kuis: $e');
    } finally {
      loading.value = false;
    }
  }

  void _showError(String message) {
    print(message);
    Get.snackbar(
      'Gagal',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void onClose() {
    topicCtrl.dispose();
    countCtrl.dispose();
    minutesCtrl.dispose();
    super.onClose();
  }
}
