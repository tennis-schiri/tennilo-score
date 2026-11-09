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
    @State private var step: SetupStep = .matchType

    private enum SetupStep: Equatable {
        case matchType, playerA, partnerA, mixedA, playerB, partnerB, mixedB
        case sets, games, tiebreak, noAd, decidingMTB, firstServer, summary
    }

    private let accent = Color(red: 0.75, green: 0.96, blue: 0.42)
    private var steps: [SetupStep] {
        var result: [SetupStep] = [.matchType, .playerA]
        if kind != .single { result.append(.partnerA) }
        if kind == .mixed { result.append(.mixedA) }
        result.append(.playerB)
        if kind != .single { result.append(.partnerB) }
        if kind == .mixed { result.append(.mixedB) }
        result += [.sets, .games, .tiebreak, .noAd]
        if bestOfSets > 1 { result.append(.decidingMTB) }
        result += [.firstServer, .summary]
        return result
    }
    private var stepIndex: Int { steps.firstIndex(of: step) ?? 0 }

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
                HStack(alignment: .center, spacing: 5) {
                    Text("\(copy.text(.setupStep)) \(stepIndex + 1)/\(steps.count)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 2)
                    Button(languageCode.uppercased()) {
                        languageCode = languageCode == "de" ? "en" : "de"
                    }
                    .buttonStyle(.bordered)
                    .font(.system(size: 10, weight: .bold))
                    .accessibilityLabel(copy.text(.changeLanguage))
                }

                ProgressView(value: Double(stepIndex + 1), total: Double(steps.count))
                    .tint(accent)

                Text(stepTitle)
                    .font(.system(size: 17, weight: .heavy))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)

                stepContent

                if step != .summary && !isNameStep {
                    Text(copy.text(.setupTapToContinue))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                navigation
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
    }

    private var stepTitle: String {
        switch step {
        case .matchType: return copy.text(.matchType)
        case .playerA: return copy.text(.playerA)
        case .partnerA: return copy.text(.partnerA)
        case .mixedA: return "\(copy.text(.playerA)) · \(copy.text(.genders))"
        case .playerB: return copy.text(.playerB)
        case .partnerB: return copy.text(.partnerB)
        case .mixedB: return "\(copy.text(.playerB)) · \(copy.text(.genders))"
        case .sets: return copy.text(.bestOfSets)
        case .games: return copy.text(.gamesPerSet)
        case .tiebreak: return copy.text(.tieBreakTo)
        case .noAd: return copy.text(.noAd)
        case .decidingMTB: return copy.text(.decidingMTB)
        case .firstServer: return copy.text(.firstServer)
        case .summary: return copy.text(.setupReview)
        }
    }

    private var isNameStep: Bool {
        switch step {
        case .playerA, .partnerA, .playerB, .partnerB: return true
        default: return false
        }
    }

    @ViewBuilder private var stepContent: some View {
        switch step {
        case .matchType:
            option(copy.text(.singles), selected: kind == .single) { kind = .single }
            option(copy.text(.doubles), selected: kind == .double) { kind = .double }
            option(copy.text(.mixed), selected: kind == .mixed) { kind = .mixed }
        case .playerA:
            nameField(copy.text(.playerA), value: $nameA)
        case .partnerA:
            nameField(copy.text(.partnerA), value: $partnerA)
        case .mixedA:
            genderOptions(for: $genderA, partner: $genderPartnerA)
        case .playerB:
            nameField(copy.text(.playerB), value: $nameB)
        case .partnerB:
            nameField(copy.text(.partnerB), value: $partnerB)
        case .mixedB:
            genderOptions(for: $genderB, partner: $genderPartnerB)
        case .sets:
            option(copy.text(.oneSet), selected: bestOfSets == 1) { bestOfSets = 1 }
            option(copy.text(.bestOfThree), selected: bestOfSets == 3) { bestOfSets = 3 }
            option(copy.text(.bestOfFive), selected: bestOfSets == 5) { bestOfSets = 5 }
        case .games:
            option("4", selected: gamesPerSet == 4) { gamesPerSet = 4 }
            option("6", selected: gamesPerSet == 6) { gamesPerSet = 6 }
        case .tiebreak:
            option("7", selected: tiebreakTo == 7) { tiebreakTo = 7 }
            option("10", selected: tiebreakTo == 10) { tiebreakTo = 10 }
        case .noAd:
            option(copy.text(.setupNo), selected: !noAd) { noAd = false }
            option(copy.text(.setupYes), selected: noAd) { noAd = true }
        case .decidingMTB:
            option(copy.text(.setupYes), selected: decidingMTB) { decidingMTB = true }
            option(copy.text(.setupNo), selected: !decidingMTB) { decidingMTB = false }
        case .firstServer:
            option(serverLabel(0), selected: firstServer == 0) { firstServer = 0 }
            option(serverLabel(1), selected: firstServer == 1) { firstServer = 1 }
        case .summary:
            VStack(spacing: 7) {
                summaryRow(copy.text(.matchType), matchKindLabel)
                summaryRow(copy.text(.playerA), display(nameA, fallback: copy.text(.me)) + partnerSummary(partnerA))
                summaryRow(copy.text(.playerB), display(nameB, fallback: copy.text(.opponent)) + partnerSummary(partnerB))
                summaryRow(copy.text(.bestOfSets), setsLabel)
                summaryRow(copy.text(.gamesPerSet), "\(gamesPerSet)")
                summaryRow(copy.text(.tieBreakTo), "\(tiebreakTo)")
                summaryRow(copy.text(.noAd), noAd ? copy.text(.setupYes) : copy.text(.setupNo))
                if bestOfSets > 1 {
                    summaryRow(copy.text(.decidingMTB), decidingMTB ? copy.text(.setupYes) : copy.text(.setupNo))
                }
                summaryRow(copy.text(.firstServer), serverLabel(firstServer))
            }
        }
    }

    private func nameField(_ title: String, value: Binding<String>) -> some View {
        VStack(spacing: 8) {
            TextField(title, text: value)
                .font(.system(size: 15, weight: .semibold))
                .textFieldStyle(.plain)
                .padding(10)
                .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
            Text(copy.text(.setupNameHint))
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func genderOptions(for player: Binding<String>, partner: Binding<String>) -> some View {
        VStack(spacing: 8) {
            option(copy.text(.setupMale), selected: player.wrappedValue == "m") {
                player.wrappedValue = "m"
                partner.wrappedValue = "w"
            }
            option(copy.text(.setupFemale), selected: player.wrappedValue == "w") {
                player.wrappedValue = "w"
                partner.wrappedValue = "m"
            }
            Text(copy.text(.setupMixedHint))
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func option(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
            goForward()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 17, weight: .semibold))
                    .accessibilityHidden(true)
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 0)
            }
            .foregroundStyle(selected ? Color.black : Color.white)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(selected ? accent : Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var navigation: some View {
        if step == .summary {
            Button(action: startMatch) {
                Text(copy.text(.startMatch))
                    .font(.system(size: 13, weight: .black))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(accent)
        } else if isNameStep {
            Button(action: goForward) {
                Text(copy.text(.setupNext))
                    .font(.system(size: 13, weight: .bold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(accent)
        }

        if stepIndex > 0 {
            Button(copy.text(.setupBack), action: goBack)
                .buttonStyle(.bordered)
                .font(.system(size: 11, weight: .semibold))
        } else if canResume {
            Button(copy.text(.resumeMatch), action: onResume)
                .buttonStyle(.bordered)
                .font(.system(size: 11, weight: .semibold))
        }
    }

    private var matchKindLabel: String {
        switch kind {
        case .single: return copy.text(.singles)
        case .double: return copy.text(.doubles)
        case .mixed: return copy.text(.mixed)
        }
    }

    private var setsLabel: String {
        switch bestOfSets {
        case 1: return copy.text(.oneSet)
        case 5: return copy.text(.bestOfFive)
        default: return copy.text(.bestOfThree)
        }
    }

    private func display(_ name: String, fallback: String) -> String {
        let value = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? fallback : value
    }

    private func partnerSummary(_ partner: String) -> String {
        kind == .single ? "" : " / " + display(partner, fallback: copy.text(.partner))
    }

    private func serverLabel(_ side: Int) -> String {
        let name = side == 0 ? display(nameA, fallback: copy.text(.me)) : display(nameB, fallback: copy.text(.opponent))
        if kind == .single { return name }
        return "\(copy.text(.team)) \(side == 0 ? "A" : "B") · \(name)"
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Spacer(minLength: 2)
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .multilineTextAlignment(.trailing)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
    }

    private func goForward() {
        let allSteps = steps
        guard let index = allSteps.firstIndex(of: step), index + 1 < allSteps.count else { return }
        step = allSteps[index + 1]
    }

    private func goBack() {
        let allSteps = steps
        guard let index = allSteps.firstIndex(of: step), index > 0 else { return }
        step = allSteps[index - 1]
    }

    private func startMatch() {
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
            genders: [
                genderA, kind == .mixed ? (genderA == "m" ? "w" : "m") : genderPartnerA,
                genderB, kind == .mixed ? (genderB == "m" ? "w" : "m") : genderPartnerB
            ]
        )
        onStart(session)
    }
}
