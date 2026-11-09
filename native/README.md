# TENNILO Score – native Watch-App (Startversion)

**Ziel:** Test auf Apple Watch Series 9 (41 mm), anschließend geschlossener Beta-Pilot am **27.12.2026**. Stand: technischer Entwicklungsstart, **noch keine installierbare/verifizierte Beta**. Eigenständige Watch-Matchkonfiguration und animierter Startbildschirm im Quellcode ergänzt.

## Aufbau

- `Sources/ScoreCore/ScoreCore.swift`: nativer Swift-Zählkern; ohne Gerät, Netzwerk oder UI testbar.
- `Tests/ScoreCoreTests`: automatisierte Tests für Tenniszählung, TB/MTB, No-Ad, Undo, Daten-Roundtrip.
- `Sources/ScoreWatch`: native watchOS-SwiftUI-Oberfläche mit **eigener Watch-Konfiguration** (Einzel/Doppel/Mixed, vier Namen inkl. M/W, Matchformat, No-Ad, erster Aufschlag), Zählbuttons, Undo, Ergebnis-/Hinweisbanner und lokaler Speicherung. **Deutsch/Englisch** mit Sprachkatalog in `ScoreLanguage.swift`.
- `WatchMatchConfiguration.swift`: Matchstart direkt auf der Watch ohne iPhone; die derzeitige Zähllogik erfasst bei Doppel/Mixed weiterhin **Teams**, keine einzelnen Aufschläger/Returnpositionen.
- `ScoreSplashView.swift` und `Assets.xcassets/ScoreBrand`: animierter Start mit freigegebenem originalem TENNILO-Score-Logo. Gemeinsame Komponente für künftiges iOS-Target; aktuell in der nativen Watch eingebunden.
- `Package.swift`: Swift-Package zum Testen des Zählkerns.
- `project.yml`: XcodeGen-Projektbeschreibung für eine Watch-only-Entwicklungs-App.

## Testen des Zählkerns

```sh
cd native
swift test
```

Der Kern läuft auch unter Swift auf Linux. **SwiftUI/watchOS ist dort nicht kompilierbar; die Watch-App muss auf einem Mac mit Xcode gebaut und auf der echten Watch getestet werden.**

## Erstes Watch-Build auf dem Mac

1. Aktuelles Xcode mit passendem watchOS SDK und `xcodegen` installieren (z. B. `brew install xcodegen`).
2. Repository klonen und `cd native && xcodegen generate` ausführen.
3. `TenniloScoreNative.xcodeproj` öffnen, unter **Signing & Capabilities** dein Apple-Development-Team wählen und bei Bedarf die Bundle-ID anpassen.
4. Apple Watch am iPhone koppeln, in Xcode als Run-Ziel auswählen und `TenniloScoreWatch` ausführen.
5. Beim ersten Start zeigt die Watch die animierte TENNILO-Score-Startansicht und danach die **Matchkonfiguration direkt auf der Uhr**. Matchart, Spieler, Regeln und ersten Aufschlag wählen und Match starten.
6. Punkte zählen, Undo, Pausenanzeigen und Ergebnisansicht testen. Match wird nach jeder Aktion lokal als JSON gespeichert.
7. Über **DE/EN** oben in der Watch-Konfiguration oder der Matchansicht die App-Sprache jederzeit wechseln. Die Einstellung wird auf der Watch dauerhaft gespeichert und kann von der Systemsprache abweichen.

## Sprachunterstützung

- Native Watch-Oberfläche und Watch-Matchkonfiguration in **Deutsch und Englisch** beschriftet (Bedienbuttons, Satzbezeichnung, No-Ad-/Seitenwechsel-/Pausenbanner, Siegeranzeige, Fehlermeldungen).
- Ausgangssprache richtet sich beim ersten Start nach der Gerätesprache; über **DE/EN** jederzeit umschaltbar, ohne das laufende Match zurückzusetzen.
- Namen sind Nutzerdaten und werden nicht übersetzt; lediglich die Platzhalter **ICH/GEGNER** werden als **ME/OPPONENT** angezeigt.
- Für die spätere iPhone-App ist dieselbe Sprachwahl vorgesehen. Noch kein echter iPhone-Build; native Kompilierung/41-mm-Layout stehen weiterhin aus.

## Was diese Startversion bewusst **noch nicht** kann

- iPhone-Begleitapp, Watch↔iPhone-Synchronisation und TestFlight-Build.
- Native iPhone-Begleitapp mit eigener animierter Startansicht; aktuell ist die Handy-Animation **in der Web-Demo** umgesetzt, der gemeinsame SwiftUI-Splash für die spätere iPhone-App vorbereitet.
- Doppel-/Mixed-Einzelspieler-Aufstellung und individuelle Aufschlag-/Returnrotation (Kern rechnet derzeit auf **Team-Ebene**).
- Vollständige UI- und Akkutests, Fehlerfalltests, Gerätekompatibilitätsprüfung.
- Einsatz als offizieller Matchzähler im Turnier. Bei Praxistests stets unabhängig mitschreiben.

## Teststrategie bis 27.12.

1. Zählkern vervollständigen und Sonderfälle testen.
2. App auf der Series 9 (41 mm) installieren, im laufenden Match testen und zuverlässig wiederherstellen.
3. iPhone-Konfiguration, Doppel/Mixed-Aufstellung und Watch-Synchronisation ergänzen.
4. TestFlight-Verteilung vorbereiten und internen Qualitätstest abschließen.
5. Nur wenn stabil: geschlossener Pilot am Turnier am 27.12.2026; nächster Testtermin 30.01.2027.
