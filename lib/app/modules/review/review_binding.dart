import 'package:get/get.dart';
import 'review_controller.dart';

class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewController>(() => ReviewController());
  }
}
