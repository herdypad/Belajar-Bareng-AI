import 'package:get/get.dart';

import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/create_quiz/create_quiz_binding.dart';
import '../modules/create_quiz/create_quiz_view.dart';
import '../modules/quiz_runner/quiz_runner_binding.dart';
import '../modules/quiz_runner/quiz_runner_view.dart';
import '../modules/result/result_binding.dart';
import '../modules/result/result_view.dart';
import '../modules/review/review_binding.dart';
import '../modules/review/review_view.dart';
import '../modules/history/history_binding.dart';
import '../modules/history/history_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.create,
      page: () => const CreateQuizView(),
      binding: CreateQuizBinding(),
    ),
    GetPage(
      name: AppRoutes.runner,
      page: () => const QuizRunnerView(),
      binding: QuizRunnerBinding(),
    ),
    GetPage(
      name: AppRoutes.result,
      page: () => const ResultView(),
      binding: ResultBinding(),
    ),
    GetPage(
      name: AppRoutes.review,
      page: () => const ReviewView(),
      binding: ReviewBinding(),
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
