// [Änderung 0.2.12] Hinweisleiste im Dunkelmodus: dunkel statt hell,
// trotzdem gut lesbar und vom Hintergrund abgehoben.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/main.dart';

double kontrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;

  test('Farben: dunkel, gut lesbar, vom Hintergrund abgehoben', () {
    final t = gymiDunkel();
    final hinweis = t.snackBarTheme.backgroundColor!;
    expect(hinweis.computeLuminance(), lessThan(0.2), reason: 'dunkel, nicht hell');
    expect(kontrast(t.snackBarTheme.contentTextStyle!.color!, hinweis),
        greaterThanOrEqualTo(4.5));
    expect(kontrast(t.snackBarTheme.actionTextColor!, hinweis),
        greaterThanOrEqualTo(4.5));
    expect(hinweis, isNot(t.colorScheme.surface), reason: 'abgehoben');
  });

  testWidgets('Hinweis mit „Wieder aufnehmen“ im Dunkelmodus am Handy',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(bottom: 144);
    tester.view.viewPadding = const FakeViewPadding(bottom: 144);
    // Schrift 100 %: Die Testschrift zeichnet jeden Buchstaben als Quadrat,
    // „Wieder aufnehmen“ wäre bei 130 % breiter als der Bildschirm (am Handy
    // passt es) – wie in geraete_ui_test.dart.
    tester.platformDispatcher.textScaleFactorTestValue = 1.0;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    var aufgenommen = false;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      darkTheme: gymiDunkel(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Session beendet.'),
                  action: SnackBarAction(
                    label: 'Wieder aufnehmen',
                    onPressed: () => aufgenommen = true,
                  ),
                ),
              ),
              child: const Text('Beenden'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Beenden'));
    await tester.pumpAndSettle();

    final leiste = find.byType(SnackBar);
    final material = tester.widget<Material>(
        find.descendant(of: leiste, matching: find.byType(Material)).first);
    expect(material.color, gymiDunkel().snackBarTheme.backgroundColor);
    // schwebt über den Android-Tasten
    expect(tester.getRect(leiste).bottom, lessThanOrEqualTo(780 - 48));
    await tester.tap(find.text('Wieder aufnehmen'));
    expect(aufgenommen, isTrue);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
