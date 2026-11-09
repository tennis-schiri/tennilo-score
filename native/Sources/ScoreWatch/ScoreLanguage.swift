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
        }
    }
}
