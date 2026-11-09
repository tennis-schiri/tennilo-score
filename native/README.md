# TENNILO Score – native Watch-App (Startversion)

**Ziel:** Test auf Apple Watch Series 9 (41 mm), anschließend geschlossener Beta-Pilot am **27.12.2026**. Stand: technischer Entwicklungsstart, **noch keine installierbare/verifizierte Beta**.

## Aufbau

- `Sources/ScoreCore/ScoreCore.swift`: nativer Swift-Zählkern; ohne Gerät, Netzwerk oder UI testbar.
- `Tests/ScoreCoreTests`: automatisierte Tests für Tenniszählung, TB/MTB, No-Ad, Undo, Daten-Roundtrip.
- `Sources/ScoreWatch`: erste native watchOS-SwiftUI-Oberfläche, Zählbuttons, Undo, Ergebnis-/Hinweisbanner, lokale atomare Speicherung nach jedem Punkt. **Deutsch/Englisch** mit umschaltbarem Sprachkatalog in `ScoreLanguage.swift`.
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
5. Auf der Watch Punkte zählen, Undo, Pausenanzeigen und Ergebnisansicht testen. Match wird nach jeder Aktion lokal als JSON gespeichert.
6. Über **DE/EN** oben im Watch-Kopf die App-Sprache jederzeit wechseln. Die Einstellung wird auf der Watch dauerhaft gespeichert und kann von der Systemsprache abweichen.

## Sprachunterstützung

- Erste native Watch-Oberfläche vollständig in **Deutsch und Englisch** beschriftet (Bedienbuttons, Satzbezeichnung, No-Ad-/Seitenwechsel-/Pausenbanner, Siegeranzeige, Fehlermeldungen).
- Ausgangssprache richtet sich beim ersten Start nach der Gerätesprache; über **DE/EN** jederzeit umschaltbar, ohne das laufende Match zurückzusetzen.
- Namen sind Nutzerdaten und werden nicht übersetzt; lediglich die Platzhalter **ICH/GEGNER** werden als **ME/OPPONENT** angezeigt.
- Für die spätere iPhone-App ist dieselbe Sprachwahl vorgesehen. Noch kein echter iPhone-Build; native Kompilierung/41-mm-Layout stehen weiterhin aus.

## Was diese Startversion bewusst **noch nicht** kann

- iPhone-Begleitapp, Watch↔iPhone-Synchronisation und TestFlight-Build.
- Eingabe von Spielernamen und Matchformat direkt über eine Konfigurationsansicht.
- Doppel-/Mixed-Einzelspieler-Aufstellung und individuelle Aufschlag-/Returnrotation (Kern rechnet derzeit auf **Team-Ebene**).
- Vollständige UI- und Akkutests, Fehlerfalltests, Gerätekompatibilitätsprüfung.
- Einsatz als offizieller Matchzähler im Turnier. Bei Praxistests stets unabhängig mitschreiben.

## Teststrategie bis 27.12.

1. Zählkern vervollständigen und Sonderfälle testen.
2. App auf der Series 9 (41 mm) installieren, im laufenden Match testen und zuverlässig wiederherstellen.
3. iPhone-Konfiguration, Doppel/Mixed-Aufstellung und Watch-Synchronisation ergänzen.
4. TestFlight-Verteilung vorbereiten und internen Qualitätstest abschließen.
5. Nur wenn stabil: geschlossener Pilot am Turnier am 27.12.2026; nächster Testtermin 30.01.2027.
