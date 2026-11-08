import Foundation

public enum Side: Int, Codable, Equatable, CaseIterable {
    case a = 0, b = 1
    public var other: Side { self == .a ? .b : .a }
}

public struct MatchRules: Codable, Equatable {
    public var bestOfSets: Int
    public var gamesPerSet: Int
    public var tiebreakPoints: Int
    public var noAd: Bool
    public var decidingMatchTiebreak: Bool

    public init(bestOfSets: Int = 3, gamesPerSet: Int = 6, tiebreakPoints: Int = 7,
                noAd: Bool = false, decidingMatchTiebreak: Bool = true) {
        self.bestOfSets = bestOfSets
        self.gamesPerSet = gamesPerSet
        self.tiebreakPoints = tiebreakPoints
        self.noAd = noAd
        self.decidingMatchTiebreak = decidingMatchTiebreak
    }
    public var setsToWin: Int { bestOfSets / 2 + 1 }
}

public enum MatchPhase: String, Codable { case game, tiebreak, matchTiebreak }
public enum MatchNotice: String, Codable {
    case changeEnds, setBreak, changeEndsAndSetBreak, decidingPoint, matchFinished
}

public struct SetResult: Codable, Equatable {
    public var games: [Int]
    public var tiebreakPoints: [Int]?
    public var isMatchTiebreak: Bool

    public init(games: [Int], tiebreakPoints: [Int]? = nil, isMatchTiebreak: Bool = false) {
        self.games = games
        self.tiebreakPoints = tiebreakPoints
        self.isMatchTiebreak = isMatchTiebreak
    }
}

/// Pure, Codable tennis-scoring engine. No SwiftUI, network or device dependency.
/// One side means one individual (singles) or one team (doubles/mixed).
/// Individual doubles server/return positions are handled by a later roster layer.
public struct MatchState: Codable, Equatable {
    public let rules: MatchRules
    public private(set) var sets: [Int] = [0, 0]
    public private(set) var games: [Int] = [0, 0]
    public private(set) var points: [Int] = [0, 0]
    public private(set) var completed: [SetResult] = []
    public private(set) var phase: MatchPhase = .game
    public private(set) var gameServer: Side
    public private(set) var tiebreakFirstServer: Side?
    public private(set) var winner: Side?
    public private(set) var notice: MatchNotice?
    public private(set) var pointsPlayed: Int = 0

    public init(rules: MatchRules = MatchRules(), firstServer: Side = .a) {
        self.rules = rules
        self.gameServer = firstServer
    }

    public var isFinished: Bool { winner != nil }

    public var currentServer: Side {
        guard phase != .game, let first = tiebreakFirstServer else { return gameServer }
        let played = points[0] + points[1]
        if played == 0 { return first }
        return ((played - 1) / 2) % 2 == 0 ? first.other : first
    }

    public func pointLabel(for side: Side) -> String {
        let n = points[side.rawValue]
        guard phase == .game else { return String(n) }
        return n == 4 ? "AD" : ["0", "15", "30", "40"][min(n, 3)]
    }

    public mutating func awardPoint(to side: Side) {
        guard !isFinished else { return }
        notice = nil
        pointsPlayed += 1
        if phase != .game {
            awardTiebreakPoint(to: side)
            return
        }
        let i = side.rawValue, j = side.other.rawValue
        if rules.noAd {
            if points[i] == 3 && points[j] == 3 { finishGame(winner: side); return }
            points[i] += 1
            if points[i] >= 4 { finishGame(winner: side) }
        } else {
            if points[i] == 4 { finishGame(winner: side); return }
            if points[j] == 4 { points[j] = 3; return }
            if points[i] == 3 && points[j] < 3 { finishGame(winner: side); return }
            points[i] += 1
        }
        if rules.noAd && points == [3, 3] { notice = .decidingPoint }
    }

    private mutating func finishGame(winner side: Side) {
        games[side.rawValue] += 1
        points = [0, 0]
        gameServer = gameServer.other
        let a = games[0], b = games[1]
        let endsChange = (a + b) % 2 == 1
        if max(a, b) >= rules.gamesPerSet && abs(a - b) >= 2 {
            finishSet(result: SetResult(games: games), changeEnds: endsChange)
        } else if a == rules.gamesPerSet && b == rules.gamesPerSet {
            phase = .tiebreak
            tiebreakFirstServer = gameServer
            notice = endsChange ? .changeEnds : nil
        } else if endsChange {
            notice = .changeEnds
        }
    }

    private mutating func awardTiebreakPoint(to side: Side) {
        points[side.rawValue] += 1
        let a = points[0], b = points[1]
        let target = phase == .matchTiebreak ? 10 : rules.tiebreakPoints
        if max(a, b) >= target && abs(a - b) >= 2 {
            if phase == .matchTiebreak {
                finishSet(result: SetResult(games: points, isMatchTiebreak: true), changeEnds: true)
            } else {
                var finalGames = games
                finalGames[side.rawValue] += 1
                gameServer = (tiebreakFirstServer ?? gameServer).other
                finishSet(result: SetResult(games: finalGames, tiebreakPoints: points), changeEnds: true)
            }
        } else if (a + b) % 6 == 0 {
            notice = .changeEnds
        }
    }

    private mutating func finishSet(result: SetResult, changeEnds: Bool) {
        let victorious = result.games[0] > result.games[1] ? Side.a : Side.b
        completed.append(result)
        sets[victorious.rawValue] += 1
        games = [0, 0]
        points = [0, 0]
        tiebreakFirstServer = nil
        if sets[victorious.rawValue] >= rules.setsToWin {
            winner = victorious
            notice = .matchFinished
            return
        }
        let finalSet = rules.bestOfSets > 1 &&
            sets[0] == rules.setsToWin - 1 && sets[1] == rules.setsToWin - 1
        phase = rules.decidingMatchTiebreak && finalSet ? .matchTiebreak : .game
        if phase == .matchTiebreak { tiebreakFirstServer = gameServer }
        notice = changeEnds ? .changeEndsAndSetBreak : .setBreak
    }
}

/// Complete match plus undo snapshots. The whole session can be persisted after each point.
public struct MatchSession: Codable, Equatable {
    public var match: MatchState
    public private(set) var undoHistory: [MatchState] = []
    public var playerNames: [String]
    public var finishedBannerDismissed: Bool = false
    public var startedAt: Date
    public var finishedAt: Date?

    public init(rules: MatchRules = MatchRules(), names: [String] = ["ICH", "GEGNER"],
                firstServer: Side = .a, startedAt: Date = Date()) {
        match = MatchState(rules: rules, firstServer: firstServer)
        playerNames = names
        self.startedAt = startedAt
    }

    public mutating func awardPoint(to side: Side, at now: Date = Date()) {
        guard !match.isFinished else { return }
        undoHistory.append(match)
        match.awardPoint(to: side)
        if match.isFinished { finishedAt = now; finishedBannerDismissed = false }
    }

    @discardableResult public mutating func undo() -> Bool {
        guard let before = undoHistory.popLast() else { return false }
        match = before
        finishedAt = nil
        finishedBannerDismissed = false
        return true
    }
}
