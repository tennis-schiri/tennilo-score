import Foundation

/// Local, atomic snapshot after every scoring action. No cloud or iPhone required.
enum ScoreSessionStore {
    private static var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("tennilo-score-session.json")
    }

    static func load() -> MatchSession {
        guard let data = try? Data(contentsOf: fileURL),
              let match = try? JSONDecoder().decode(MatchSession.self, from: data)
        else { return MatchSession() }
        return match
    }

    static func save(_ match: MatchSession) throws {
        let data = try JSONEncoder().encode(match)
        try data.write(to: fileURL, options: .atomic)
    }
}
