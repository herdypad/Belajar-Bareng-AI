import 'package:get/get.dart';
import '../../data/models/quiz.dart';
import '../../data/models/quiz_result.dart';

class ReviewController extends GetxController {
  late final Quiz quiz;
  late final QuizResult result;
  
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    
    if (args == null || args['quiz'] == null || args['result'] == null) {
      // If no arguments provided, go back
      Get.back();
      Get.snackbar(
        'Error',
        'Data kuis tidak ditemukan. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    quiz = args['quiz'] as Quiz;
    result = args['result'] as QuizResult;
  }

  void next() {
    if (currentIndex.value < quiz.questions.length - 1) {
      currentIndex.value++;
    }
  }

  void prev() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }
}
