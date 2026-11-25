// [Änderung 0.2.11] Tastatur-Wächter: kein hängender Tastaturbereich nach
// Bildschirm aus / App-Wechsel; Tipp daneben schliesst die Tastatur.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingsapp/ui/tastatur_waechter.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;

  Future<int Function()> baue(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(bottom: 144);
    tester.view.viewPadding = const FakeViewPadding(bottom: 144);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    var gedrueckt = 0;
    await tester.pumpWidget(MaterialApp(
      builder: (context, kind) => TastaturWaechter(child: kind!),
      home: Scaffold(
        body: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Wdh')),
            FilledButton(
              onPressed: () => gedrueckt++,
              child: const Text('Speichern'),
            ),
            const Expanded(child: SizedBox.expand()),
          ],
        ),
      ),
    ));
    return () => gedrueckt;
  }

  bool feldAktiv(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;

  List<String> befehle(WidgetTester tester) =>
      tester.testTextInput.log.map((c) => c.method).toList();

  testWidgets('Hintergrund: Feld abgewählt, Tastatur zu; Rückkehr: Tastatur zu',
      (tester) async {
    await baue(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(feldAktiv(tester), isTrue);

    tester.testTextInput.log.clear();
    for (final s in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pump();
    expect(feldAktiv(tester), isFalse);
    expect(befehle(tester), contains('TextInput.hide'));

    tester.testTextInput.log.clear();
    for (final s in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pump();
    expect(befehle(tester), contains('TextInput.hide'));
    expect(feldAktiv(tester), isFalse);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('Tipp daneben schliesst die Tastatur, Knöpfe gehen weiter',
      (tester) async {
    final gedrueckt = await baue(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(feldAktiv(tester), isTrue);

    // Knopf: wird ausgelöst (der Wächter nimmt ihm den Tipp nicht weg)
    await tester.tap(find.text('Speichern'));
    await tester.pump();
    expect(gedrueckt(), 1);

    // Leere Fläche unten: Feld abgewählt
    await tester.tapAt(const Offset(180, 600));
    await tester.pump();
    expect(feldAktiv(tester), isFalse);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
