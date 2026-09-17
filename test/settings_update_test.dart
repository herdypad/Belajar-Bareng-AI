import 'package:belajar_bareng_ai/app/core/theme/app_theme.dart';
import 'package:belajar_bareng_ai/app/data/services/settings_service.dart';
import 'package:belajar_bareng_ai/app/modules/settings/settings_controller.dart';
import 'package:belajar_bareng_ai/app/modules/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String>{};

  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    storage.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == 'write') {
        final args = call.arguments as Map<dynamic, dynamic>;
        storage[args['key'] as String] = args['value'] as String;
        return null;
      }
      if (call.method == 'read') {
        final args = call.arguments as Map<dynamic, dynamic>;
        return storage[args['key'] as String];
      }
      return null;
    });

    final settingsService = SettingsService();
    Get.put<SettingsService>(settingsService);
    Get.put<SettingsController>(SettingsController());
  });

  tearDown(() {
    Get.reset();
  });

  group('Settings Update App Button Tests', () {
    test('SettingsController has correct updateUrl', () {
      expect(
        SettingsController.updateUrl,
        'https://github.com/herdypad/Belajar-Bareng-AI/actions',
      );
    });

    testWidgets('Renders Update Aplikasi button on Mobile view', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.dark,
          home: const SettingsView(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down in ListView to make sure the update section is visible
      await tester.scrollUntilVisible(
        find.text('PEMBARUAN APLIKASI'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Verify "PEMBARUAN APLIKASI" header and button exist
      expect(find.text('PEMBARUAN APLIKASI'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Update Aplikasi'), findsOneWidget);
    });

    testWidgets('Renders Update Aplikasi button on Tablet view', (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.dark,
          home: const SettingsView(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify "PEMBARUAN APLIKASI" and button exist in tablet layout
      expect(find.text('PEMBARUAN APLIKASI'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Update Aplikasi'), findsOneWidget);
    });
  });
}
