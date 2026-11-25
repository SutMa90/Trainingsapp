import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// [Änderung 0.2.11] Verhindert einen „hängenden“ Tastaturbereich
/// (Handy-Test 22.11.2026): Nach Bildschirm aus oder App-Wechsel meldete
/// Android unten noch Platz für die Tastatur, obwohl sie zu war. Folge:
/// Inhalt verdeckt, „Session beenden“ unter den Android-Tasten, Speicherknopf
/// nach oben geschoben.
///
/// - Geht Gymi in den Hintergrund: Feldauswahl aufheben, Tastatur schliessen.
/// - Kommt Gymi zurück: Tastatur schliessen, falls kein Feld angewählt ist –
///   Android meldet dann den Tastaturbereich neu (leer).
/// - Tipp neben ein Eingabefeld schliesst die Tastatur.
class TastaturWaechter extends StatefulWidget {
  const TastaturWaechter({super.key, required this.child});

  final Widget child;

  @override
  State<TastaturWaechter> createState() => _TastaturWaechterState();
}

class _TastaturWaechterState extends State<TastaturWaechter>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  static bool get _feldAngewaehlt {
    final fokus = FocusManager.instance.primaryFocus;
    return fokus?.context?.findAncestorStateOfType<EditableTextState>() != null ||
        fokus?.context?.widget is EditableText;
  }

  static void _schliesseTastatur() =>
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (_feldAngewaehlt) FocusManager.instance.primaryFocus?.unfocus();
        _schliesseTastatur();
      case AppLifecycleState.resumed:
        if (!_feldAngewaehlt) _schliesseTastatur();
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tipp ins Leere schliesst die Tastatur. Knöpfe und Felder darunter
    // gewinnen den Tipp selbst, dieser Erkenner greift nur daneben.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (_feldAngewaehlt) FocusManager.instance.primaryFocus?.unfocus();
      },
      child: widget.child,
    );
  }
}
