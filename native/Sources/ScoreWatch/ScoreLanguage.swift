import Foundation

/// In-app language selection, independent of watchOS language.
/// The choice is stored via @AppStorage in the Watch view.
enum ScoreLanguage: String {
    case de, en

    static var systemDefault: String {
        Locale.preferredLanguages.first?.lowercased().hasPrefix("de") == true ? "de" : "en"
    }
}

enum ScoreText {
    case set, me, opponent, team, undo, newMatchShort
    case confirmNewMatch, newMatch, cancel
    case saveFailed, saveFailedExplanation
    case noAdExplanation, continueAfterNotice, tapToClose
    case matchEnded, winner, duration, changeEnds, setBreak, changeEndsAndBreak, decidingPoint
    case changeLanguage
    case configure, startMatch, matchType, singles, doubles, mixed
    case playerA, playerB, partnerA, partnerB, partner, firstServer
    case bestOfSets, bestOfThree, oneSet, bestOfFive, gamesPerSet
    case tieBreakTo, advantage, noAd, decidingMTB, genders, genderMismatch
    case configureWithoutPhone, resumeMatch, scoreLabel
    case setupStep, setupTapToContinue, setupReview, setupNameHint, setupMixedHint
    case setupMale, setupFemale, setupYes, setupNo, setupNext, setupBack
}

struct ScoreCopy {
    let code: String

    private var english: Bool { code == ScoreLanguage.en.rawValue }

    func text(_ key: ScoreText) -> String {
        switch key {
        case .set: return english ? "SET" : "SATZ"
        case .me: return english ? "ME" : "ICH"
        case .opponent: return english ? "OPPONENT" : "GEGNER"
        case .team: return "TEAM"
        case .undo: return "↶ UNDO"
        case .newMatchShort: return english ? "NEW" : "NEU"
        case .confirmNewMatch: return english ? "Start a new match?" : "Neues Match starten?"
        case .newMatch: return english ? "New match" : "Neues Match"
        case .cancel: return english ? "Cancel" : "Abbrechen"
        case .saveFailed: return english ? "Save failed" : "Speichern fehlgeschlagen"
        case .saveFailedExplanation:
            return english ? "Please check available storage on your Apple Watch." :
                             "Bitte prüfe den freien Speicher der Watch."
        case .noAdExplanation:
            return english ? "NO-AD · Next point wins" : "NO-AD · Nächster Punkt entscheidet"
        case .continueAfterNotice:
            return english ? "Continue after the notice" : "Weiterzählen nach dem Hinweis"
        case .tapToClose: return english ? "Tap to dismiss" : "Zum Schließen tippen"
        case .matchEnded: return english ? "MATCH FINISHED" : "MATCH BEENDET"
        case .winner: return english ? "🏆 WINNER" : "🏆 SIEGER"
        case .duration: return english ? "Duration" : "Spieldauer"
        case .changeEnds: return english ? "CHANGE ENDS" : "SEITENWECHSEL"
        case .setBreak: return english ? "SET BREAK" : "SATZPAUSE"
        case .changeEndsAndBreak:
            return english ? "CHANGE ENDS\n+ SET BREAK" : "SEITENWECHSEL\n+ SATZPAUSE"
        case .decidingPoint: return english ? "DECIDING POINT" : "ENTSCHEIDUNGSPUNKT"
        case .changeLanguage: return english ? "Change language to German" : "Sprache auf Englisch umstellen"
        case .configure: return english ? "Configure match" : "Match konfigurieren"
        case .startMatch: return english ? "START MATCH" : "MATCH STARTEN"
        case .matchType: return english ? "Match type" : "Matchart"
        case .singles: return english ? "Singles" : "Einzel"
        case .doubles: return english ? "Doubles" : "Doppel"
        case .mixed: return "Mixed"
        case .playerA: return english ? "Player A" : "Spieler A"
        case .playerB: return english ? "Player B" : "Spieler B"
        case .partnerA: return english ? "Partner A" : "Partner A"
        case .partnerB: return english ? "Partner B" : "Partner B"
        case .partner: return english ? "Partner" : "Partner"
        case .firstServer: return english ? "First server" : "Erster Aufschlag"
        case .bestOfSets: return english ? "Match format" : "Matchformat"
        case .bestOfThree: return english ? "Best of 3" : "2 Gewinnsätze"
        case .oneSet: return english ? "One set" : "1 Satz"
        case .bestOfFive: return english ? "Best of 5" : "3 Gewinnsätze"
        case .gamesPerSet: return english ? "Games / set" : "Spiele / Satz"
        case .tieBreakTo: return english ? "Tiebreak to" : "Tiebreak bis"
        case .advantage: return english ? "Advantage" : "Vorteil"
        case .noAd: return "No-Ad"
        case .decidingMTB: return english ? "Final match tiebreak" : "Entscheidungs-Match-Tiebreak"
        case .genders: return english ? "Gender (M/W)" : "Geschlecht (M/W)"
        case .genderMismatch: return english ? "Each mixed team needs one M and one W." : "Jedes Mixed-Team braucht M und W."
        case .configureWithoutPhone: return english ? "Set up on your Watch" : "Direkt auf der Watch einstellen"
        case .resumeMatch: return english ? "Back to match" : "Zurück zum Match"
        case .scoreLabel: return english ? "SCORE" : "SCORE"
        case .setupStep: return english ? "Step" : "Schritt"
        case .setupTapToContinue: return english ? "Tap an option to continue" : "Auswahl antippen – weiter"
        case .setupReview: return english ? "Review match" : "Match prüfen"
        case .setupNameHint: return english ? "Tap to enter a name, or keep the suggestion." : "Namen antippen oder Vorschlag übernehmen."
        case .setupMixedHint: return english ? "Partner is set to the opposite gender." : "Partner wird automatisch gegenteilig gesetzt."
        case .setupMale: return english ? "Male" : "Männlich"
        case .setupFemale: return english ? "Female" : "Weiblich"
        case .setupYes: return english ? "Yes" : "Ja"
        case .setupNo: return english ? "No" : "Nein"
        case .setupNext: return english ? "Next" : "Weiter"
        case .setupBack: return english ? "Back" : "Zurück"
        }
    }
}
