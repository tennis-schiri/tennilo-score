import XCTest
@testable import ScoreCore

final class ScoreCoreTests: XCTestCase {
    func winGame(_ side: Side, in state: inout MatchState) {
        for _ in 0..<4 { state.awardPoint(to: side) }
    }

    func testStandardGameAndServeRotation() {
        var m = MatchState(firstServer: .a)
        XCTAssertEqual(m.currentServer, .a)
        m.awardPoint(to: .a)
        XCTAssertEqual(m.pointLabel(for: .a), "15")
        for _ in 0..<3 { m.awardPoint(to: .a) }
        XCTAssertEqual(m.games, [1, 0])
        XCTAssertEqual(m.currentServer, .b)
        XCTAssertEqual(m.notice, .changeEnds)
    }

    func testDeuceAdvantageAndUndo() {
        var session = MatchSession()
        for _ in 0..<3 { session.awardPoint(to: .a); session.awardPoint(to: .b) }
        session.awardPoint(to: .a)
        XCTAssertEqual(session.match.pointLabel(for: .a), "AD")
        session.awardPoint(to: .b)
        XCTAssertEqual(session.match.points, [3, 3])
        XCTAssertTrue(session.undo())
        XCTAssertEqual(session.match.points, [4, 3])
        session.awardPoint(to: .a)
        XCTAssertEqual(session.match.games, [1, 0])
    }

    func testNoAdDecidingPoint() {
        var m = MatchState(rules: MatchRules(noAd: true))
        for _ in 0..<3 { m.awardPoint(to: .a); m.awardPoint(to: .b) }
        XCTAssertEqual(m.notice, .decidingPoint)
        m.awardPoint(to: .b)
        XCTAssertEqual(m.games, [0, 1])
    }

    func testTiebreakWithActualPointsAndCorrectServer() {
        var m = MatchState(rules: MatchRules(bestOfSets: 1))
        for _ in 0..<6 { winGame(.a, in: &m); winGame(.b, in: &m) }
        XCTAssertEqual(m.games, [6, 6])
        XCTAssertEqual(m.phase, .tiebreak)
        XCTAssertEqual(m.currentServer, .a)
        m.awardPoint(to: .a)
        XCTAssertEqual(m.currentServer, .b)
        m.awardPoint(to: .b)
        XCTAssertEqual(m.currentServer, .b)
        m.awardPoint(to: .a)
        XCTAssertEqual(m.currentServer, .a)
        // 1:1 then another 6 points for A, so 7:1.
        for _ in 0..<5 { m.awardPoint(to: .a) }
        XCTAssertTrue(m.isFinished)
        XCTAssertEqual(m.completed[0].games, [7, 6])
        XCTAssertEqual(m.completed[0].tiebreakPoints, [7, 1])
        XCTAssertEqual(m.notice, .matchFinished)
    }

    func testDecidingMatchTiebreakAndUnendingWinByTwo() {
        let rules = MatchRules(bestOfSets: 3, decidingMatchTiebreak: true)
        var m = MatchState(rules: rules)
        for _ in 0..<6 { winGame(.a, in: &m) }
        for _ in 0..<6 { winGame(.b, in: &m) }
        XCTAssertEqual(m.phase, .matchTiebreak)
        for _ in 0..<9 { m.awardPoint(to: .a); m.awardPoint(to: .b) }
        XCTAssertFalse(m.isFinished)
        m.awardPoint(to: .a)
        XCTAssertFalse(m.isFinished) // 10:9 is not enough
        m.awardPoint(to: .a)
        XCTAssertEqual(m.completed.last?.games, [11, 9])
        XCTAssertEqual(m.completed.last?.isMatchTiebreak, true)
        XCTAssertEqual(m.winner, .a)
        XCTAssertEqual(m.notice, .matchFinished)
    }

    func testUndoRestoresLastSetAndFinish() {
        var session = MatchSession(rules: MatchRules(bestOfSets: 1))
        for _ in 0..<5 { for _ in 0..<4 { session.awardPoint(to: .a) } }
        for _ in 0..<3 { session.awardPoint(to: .a) }
        session.awardPoint(to: .a)
        XCTAssertTrue(session.match.isFinished)
        XCTAssertNotNil(session.finishedAt)
        XCTAssertTrue(session.undo())
        XCTAssertFalse(session.match.isFinished)
        XCTAssertEqual(session.match.games, [5, 0])
        XCTAssertEqual(session.match.points, [3, 0])
    }

    func testJSONRoundTripPreservesUndoAndMatch() throws {
        var session = MatchSession()
        session.awardPoint(to: .b)
        session.awardPoint(to: .a)
        let copy = try JSONDecoder().decode(MatchSession.self, from: JSONEncoder().encode(session))
        XCTAssertEqual(session, copy)
        var resumed = copy
        XCTAssertTrue(resumed.undo())
        XCTAssertEqual(resumed.match.points, [0, 1])
    }
}
