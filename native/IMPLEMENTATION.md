# TENNILO Score – native Übernahme der Demo

Stand: 17.11.2026. Dies ist der verbindliche Umsetzungsrahmen für die private erste iPhone-/Apple-Watch-Testversion. Der aktuelle Build unter `TENNILO-Score-Native-Start` ist nur eine technische Testbasis; **nicht als fertige erste Testversion ausliefern**.

## Quelle der Wahrheit

Die bestehende, lauffähige Datei `prototype/index.html` (derzeitige Demo auf score.tennilo.de) definiert Darstellung, Fachlogik und Funktionsumfang. Sie bleibt bei der App-Entwicklung zunächst unangetastet. Änderungen an der App dürfen keine Demo-Funktionen stillschweigend entfernen.

## Eine App, zwei Zielgeräte

Ein gemeinsames Xcode-Projekt und ein gemeinsamer TENNILO-Score-Produktname, aber zwei Plattform-Targets: iOS und watchOS. Direkte Installation mit kostenlosem Apple Personal Team auf privatem iPhone und gekoppelter Apple Watch; Veröffentlichung nicht nötig.

## iPhone: Funktionsumfang der ersten installierbaren Version

- Match-Konfiguration: Einzel / Doppel / Mixed, Spieler und Partner, Aufschlag, Sätze, Spiele, Zählweise, Tiebreak-Varianten und Aufstellungs-/Aufschlagreihenfolge
- Live-Spielstand mit allen Sätzen, Aufschlagkennzeichnung am jeweiligen Namen
- Matchübersicht mit umschaltbarem Verlauf und Statistiken, Verlauf scrollt zum aktuellen Spiel
- Scoreboard im Querformat
- Matchfunktionen: Punktvergabe, UNDO, Matchende einschließlich Aufgabe
- Match-Archiv mit dauerhafter Offline-Speicherung und Wiederherstellung
- Umschaltbar Deutsch / Englisch
- Dem Design entsprechende Splashscreens, Logos und Einstellungen

Die bestehende HTML-App enthält IndexedDB-Speicherung. Falls die iPhone-Oberfläche zunächst als lokale WebView integriert wird, muss ausdrücklich sichergestellt werden, dass ihre Daten in einem persistenten Datenspeicher liegen. Bestehende Browser-Daten werden nicht automatisch in die App übertragen.

## Apple Watch

Die bisher simulierte rechteckige Apple-Watch-Ansicht (41-mm-Gerät als Referenz) wird als native SwiftUI-Oberfläche umgesetzt. Zwei Punkttasten, Aufschlagkennzeichnung, vollständiger Spielstand, UNDO, Zahnrad-Menü und alle watch-relevanten Funktionen. Die Uhr muss eigenständig ohne ständige Verbindung zum Telefon Punkte zählen können.

## Gemeinsame Match-Logik und Synchronisierung

Eine konsistente Punkt-/Match-Logik für beide Geräte ist zwingend. WatchConnectivity darf nicht nur einen optischen Spielstand übertragen: tatsächliche Match-Ereignisse, Wiederverbindung, Idempotenz, Reihenfolge, UNDO und Konflikte müssen definiert und geprüft sein. Zwischenstände und abgeschlossene Matches müssen offline überdauern.

## Prüfkriterien vor erstem Gerätetest als „Demo-gleichwertig“

1. iPhone-Design gegen aktuellen Prototyp anhand echter Screenshots vergleichen.
2. watchOS-Design auf der realen Apple Watch Series 9 (41 mm) prüfen.
3. Einzel, Doppel, Mixed und Tiebreak-/No-Ad-/Sondervarianten durchspielen.
4. Watch-Punkte, UNDO, Verbindungsabbruch und Wiederverbindung testen.
5. App beenden, neu öffnen, Match und Archiv wiederfinden.
6. Kein vereinfachtes Einzel-only-UI als vollwertige Testversion bezeichnen.

## Verteilung

Keine App-Store-Veröffentlichung und keine Website-Änderung. Nach Xcode-Build Installation auf den persönlichen Geräten mit Personal Team.
