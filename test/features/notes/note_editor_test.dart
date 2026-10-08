import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:offline_bible/core/controllers/app_controller.dart';
import 'package:offline_bible/features/notes/widgets/note_editor_sheet.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.put(AppController());
  });

  group('NoteEditorSheet layout tests', () {
    testWidgets('Renders properly without overflow on small screen with keyboard', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
      });

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Get.bottomSheet(
                    const NoteEditorSheet(verseKeys: ['GEN.1.1', 'GEN.1.2']),
                    isScrollControlled: true,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Simulate keyboard open (280px keyboard on 640px screen)
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final tfAfter = tester.getSize(find.byType(TextField));
      expect(tfAfter.height, greaterThan(100.0));
    });

    testWidgets('Provides plenty of multiline room on standard phone with keyboard', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
      });

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Get.bottomSheet(
                    const NoteEditorSheet(verseKeys: ['GEN.1.1']),
                    isScrollControlled: true,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final tfBefore = tester.getSize(find.byType(TextField));
      expect(tfBefore.height, greaterThan(450.0));

      // Simulate keyboard open (350px keyboard)
      tester.view.viewInsets = const FakeViewPadding(bottom: 350);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final tfAfter = tester.getSize(find.byType(TextField));
      expect(tfAfter.height, greaterThan(200.0));

      // Test multiline text input
      const testText = 'Line 1\nLine 2\nLine 3\nLine 4\nLine 5\nLine 6\nLine 7\nLine 8';
      await tester.enterText(find.byType(TextField), testText);
      await tester.pump();

      expect(find.text(testText), findsOneWidget);
      expect(find.text('Save Note'), findsOneWidget);
    });
  });
}
