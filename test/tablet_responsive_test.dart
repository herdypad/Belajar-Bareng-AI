import 'package:belajar_bareng_ai/app/core/theme/app_theme.dart';
import 'package:belajar_bareng_ai/app/core/widgets/mobile_shell.dart';
import 'package:belajar_bareng_ai/app/core/widgets/quiz_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tablet Responsive Tests', () {
    testWidgets('ResponsiveBreakpoints correctly identifies mobile vs tablet',
        (tester) async {
      bool? isMobile;
      bool? isTablet;
      bool? isTabletOrLarger;

      Widget buildWidget() {
        return MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) {
              isMobile = ResponsiveBreakpoints.isMobile(context);
              isTablet = ResponsiveBreakpoints.isTablet(context);
              isTabletOrLarger = ResponsiveBreakpoints.isTabletOrLarger(context);
              return const SizedBox.shrink();
            },
          ),
        );
      }

      // Mobile screen size (390 x 844)
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildWidget());
      expect(isMobile, true);
      expect(isTablet, false);
      expect(isTabletOrLarger, false);

      // Tablet screen size (800 x 1280)
      tester.view.physicalSize = const Size(800, 1280);
      await tester.pumpWidget(buildWidget());
      expect(isMobile, false);
      expect(isTablet, true);
      expect(isTabletOrLarger, true);
    });

    testWidgets('MobileShell adapts maxWidth on mobile vs tablet', (tester) async {
      Widget buildShell({double? customMaxWidth}) {
        return MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: MobileShell(
              maxWidth: customMaxWidth,
              child: const Text('Hello Responsive'),
            ),
          ),
        );
      }

      // Test mobile size
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildShell());
      ConstrainedBox box = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(MobileShell),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(box.constraints.maxWidth, 480.0);

      // Test tablet size
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpWidget(buildShell());
      box = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(MobileShell),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(box.constraints.maxWidth, 860.0);

      // Test custom maxWidth on tablet
      await tester.pumpWidget(buildShell(customMaxWidth: 680));
      box = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(MobileShell),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(box.constraints.maxWidth, 680.0);
      // Test tablet landscape size
      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpWidget(buildShell());
      box = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(MobileShell),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(box.constraints.maxWidth, 1040.0);
    });

    testWidgets('ResponsiveBreakpoints identifies tablet landscape and desktop',
        (tester) async {
      bool? isLandscape;

      Widget buildWidget() {
        return MaterialApp(
          home: Builder(
            builder: (context) {
              isLandscape = ResponsiveBreakpoints.isTabletLandscapeOrDesktop(context);
              return const SizedBox.shrink();
            },
          ),
        );
      }

      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildWidget());
      expect(isLandscape, false);

      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpWidget(buildWidget());
      expect(isLandscape, true);
    });

    testWidgets('QuizActionSheet on tablet stays centered and constrained',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: QuizActionSheet(
              title: 'Kuis Geografi',
              totalQuestions: 5,
              durationMinutes: 10,
              score: 85,
              onReview: () {},
              onResult: () {},
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Kuis Geografi'), findsOneWidget);
      expect(find.text('Review Jawaban'), findsOneWidget);
    });
  });
}
