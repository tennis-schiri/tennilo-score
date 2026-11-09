import SwiftUI

/// Full match setup on Apple Watch – does not depend on an iPhone connection.
/// The scoring engine still handles teams, not individual doubles serve rotations.
struct WatchMatchConfiguration: View {
    @AppStorage("scoreLanguage") private var languageCode = ScoreLanguage.systemDefault

    let canResume: Bool
    let onStart: (MatchSession) -> Void
    let onResume: () -> Void

    @State private var kind: MatchKind
    @State private var nameA: String
    @State private var nameB: String
    @State private var partnerA: String
    @State private var partnerB: String
    @State private var genderA: String
    @State private var genderPartnerA: String
    @State private var genderB: String
    @State private var genderPartnerB: String
    @State private var bestOfSets: Int
    @State private var gamesPerSet: Int
    @State private var tiebreakTo: Int
    @State private var noAd: Bool
    @State private var decidingMTB: Bool
    @State private var firstServer: Int
    @State private var invalidMixed: Bool = false

    private var copy: ScoreCopy { ScoreCopy(code: languageCode) }

    init(previous: MatchSession, canResume: Bool,
         onStart: @escaping (MatchSession) -> Void,
         onResume: @escaping () -> Void) {
        self.canResume = canResume
        self.onStart = onStart
        self.onResume = onResume
        _kind = State(initialValue: previous.matchKind)
        _nameA = State(initialValue: previous.playerNames.first ?? "ICH")
        _nameB = State(initialValue: previous.playerNames.dropFirst().first ?? "GEGNER")
        _partnerA = State(initialValue: previous.partnerNames.first ?? "")
        _partnerB = State(initialValue: previous.partnerNames.dropFirst().first ?? "")
        _genderA = State(initialValue: previous.playerGenders.indices.contains(0) ? previous.playerGenders[0] : "m")
        _genderPartnerA = State(initialValue: previous.playerGenders.indices.contains(1) ? previous.playerGenders[1] : "w")
        _genderB = State(initialValue: previous.playerGenders.indices.contains(2) ? previous.playerGenders[2] : "m")
        _genderPartnerB = State(initialValue: previous.playerGenders.indices.contains(3) ? previous.playerGenders[3] : "w")
        _bestOfSets = State(initialValue: previous.match.rules.bestOfSets)
        _gamesPerSet = State(initialValue: previous.match.rules.gamesPerSet)
        _tiebreakTo = State(initialValue: previous.match.rules.tiebreakPoints)
        _noAd = State(initialValue: previous.match.rules.noAd)
        _decidingMTB = State(initialValue: previous.match.rules.decidingMatchTiebreak)
        _firstServer = State(initialValue: previous.match.gameServer.rawValue)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack(spacing: 6) {
                    Text(copy.text(.configure))
                        .font(.system(size: 15, weight: .heavy))
                        .lineLimit(2)
                    Spacer(minLength: 2)
                    Button(languageCode.uppercased()) {
                        languageCode = languageCode == "de" ? "en" : "de"
                    }
                    .font(.system(size: 10, weight: .bold))
                    .buttonStyle(.bordered)
                    .accessibilityLabel(copy.text(.changeLanguage))
                }
                Text(copy.text(.configureWithoutPhone))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)

                Picker(copy.text(.matchType), selection: $kind) {
                    Text(copy.text(.singles)).tag(MatchKind.single)
                    Text(copy.text(.doubles)).tag(MatchKind.double)
                    Text(copy.text(.mixed)).tag(MatchKind.mixed)
                }

                TextField(copy.text(.playerA), text: $nameA)
                TextField(copy.text(.playerB), text: $nameB)
                if kind != .single {
                    TextField(copy.text(.partnerA), text: $partnerA)
                    TextField(copy.text(.partnerB), text: $partnerB)
                }
                if kind == .mixed {
                    genderPicker(copy.text(.playerA), selection: $genderA)
                    genderPicker(copy.text(.partnerA), selection: $genderPartnerA)
                    genderPicker(copy.text(.playerB), selection: $genderB)
                    genderPicker(copy.text(.partnerB), selection: $genderPartnerB)
                    if invalidMixed {
                        Text(copy.text(.genderMismatch))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.red)
                    }
                }
                Picker(copy.text(.bestOfSets), selection: $bestOfSets) {
                    Text(copy.text(.oneSet)).tag(1)
                    Text(copy.text(.bestOfThree)).tag(3)
                    Text(copy.text(.bestOfFive)).tag(5)
                }
                Picker(copy.text(.gamesPerSet), selection: $gamesPerSet) {
                    Text("4").tag(4)
                    Text("6").tag(6)
                }
                Picker(copy.text(.tieBreakTo), selection: $tiebreakTo) {
                    Text("7").tag(7)
                    Text("10").tag(10)
                }
                Toggle(copy.text(.noAd), isOn: $noAd)
                if bestOfSets > 1 {
                    Toggle(copy.text(.decidingMTB), isOn: $decidingMTB)
                }
                Picker(copy.text(.firstServer), selection: $firstServer) {
                    Text(nameA.isEmpty ? copy.text(.playerA) : nameA).tag(0)
                    Text(nameB.isEmpty ? copy.text(.playerB) : nameB).tag(1)
                }
                Button(action: startMatch) {
                    Text(copy.text(.startMatch))
                        .font(.system(size: 12, weight: .black))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.75, green: 0.96, blue: 0.42))
                if canResume {
                    Button(copy.text(.resumeMatch), action: onResume)
                        .buttonStyle(.bordered)
                        .font(.system(size: 11))
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 8)
        }
    }

    private func genderPicker(_ label: String, selection: Binding<String>) -> some View {
        Picker(label + " · M/W", selection: selection) {
            Text("M").tag("m")
            Text("W").tag("w")
        }
    }

    private func startMatch() {
        if kind == .mixed && (genderA == genderPartnerA || genderB == genderPartnerB) {
            invalidMixed = true
            return
        }
        invalidMixed = false
        func cleaned(_ text: String, fallback: String) -> String {
            let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return value.isEmpty ? fallback : value
        }
        let rules = MatchRules(
            bestOfSets: bestOfSets,
            gamesPerSet: gamesPerSet,
            tiebreakPoints: tiebreakTo,
            noAd: noAd,
            decidingMatchTiebreak: bestOfSets > 1 && decidingMTB
        )
        let session = MatchSession(
            rules: rules,
            names: [
                cleaned(nameA, fallback: copy.text(.me)),
                cleaned(nameB, fallback: copy.text(.opponent))
            ],
            firstServer: firstServer == 0 ? .a : .b,
            matchKind: kind,
            partners: [
                cleaned(partnerA, fallback: copy.text(.partnerA)),
                cleaned(partnerB, fallback: copy.text(.partnerB))
            ],
            genders: [genderA, genderPartnerA, genderB, genderPartnerB]
        )
        onStart(session)
    }
}
