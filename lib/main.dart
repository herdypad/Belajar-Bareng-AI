import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/core/theme/app_theme.dart';
import 'app/data/models/question.dart';
import 'app/data/models/quiz.dart';
import 'app/data/models/quiz_result.dart';
import 'app/data/repositories/quiz_repository.dart';
import 'app/data/services/settings_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(QuestionAdapter());
  Hive.registerAdapter(QuizAdapter());
  Hive.registerAdapter(QuizResultAdapter());

  final repo = QuizRepository();
  await repo.init();
  Get.put<QuizRepository>(repo, permanent: true);

  final settings = SettingsService();
  await settings.load();
  Get.put<SettingsService>(settings, permanent: true);

  runApp(const BelajarBarengAiApp());
}

class BelajarBarengAiApp extends StatelessWidget {
  const BelajarBarengAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    return Obx(
      () => GetMaterialApp(
        title: 'Belajar Bareng AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.darkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: AppRoutes.home,
        getPages: AppPages.pages,
      ),
    );
  }
}
