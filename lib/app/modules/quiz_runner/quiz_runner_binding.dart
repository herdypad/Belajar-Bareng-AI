import 'package:get/get.dart';
import 'quiz_runner_controller.dart';

class QuizRunnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizRunnerController>(() => QuizRunnerController());
  }
}
