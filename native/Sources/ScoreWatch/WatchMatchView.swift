import SwiftUI

struct WatchMatchView: View {
    @State private var session = ScoreSessionStore.load()
    @State private var activeBanner: MatchNotice?
    @State private var bannerToken = UUID()
    @State private var showRestartConfirmation = false
    @State private var saveError: String?
    @AppStorage("scoreLanguage") private var languageCode = ScoreLanguage.systemDefault
    @AppStorage("scoreConfigured") private var scoreConfigured = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingConfiguration = false
    @State private var showingSplash = true

    private var copy: ScoreCopy { ScoreCopy(code: languageCode) }

    private let homeColor = Color(red: 0.76, green: 0.96, blue: 0.39)
    private let awayColor = Color(red: 0.45, green: 0.81, blue: 0.97)

    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.075, blue: 0.12).ignoresSafeArea()
            if !scoreConfigured || showingConfiguration {
                WatchMatchConfiguration(
                    previous: session,
                    canResume: scoreConfigured,
                    onStart: { configuredSession in
                        session = configuredSession
                        scoreConfigured = true
                        showingConfiguration = false
                        dismissBanner()
                        persist()
                    },
                    onResume: { showingConfiguration = false }
                )
            } else {
            ScrollView {
                VStack(spacing: 7) {
                    HStack {
                        Text("TENNILO SCORE").font(.system(size: 9, weight: .black))
                        Spacer(minLength: 4)
                        Text(session.match.phase == .matchTiebreak ? "MTB" : session.match.phase == .tiebreak ? "TB" : "\(copy.text(.set)) \(session.match.completed.count + 1)")
                            .font(.system(size: 9, weight: .bold))
                        Button(languageCode.uppercased()) {
                            languageCode = languageCode == "de" ? "en" : "de"
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(homeColor)
                        .accessibilityLabel(copy.text(.changeLanguage))
                    }
                    .foregroundStyle(.white.opacity(0.72))

                    HStack(spacing: 3) {
                        scoreRow(.a, color: homeColor)
                        scoreRow(.b, color: awayColor)
                    }
                    .padding(.bottom, 1)

                    pointButton(.a, color: homeColor)
                    pointButton(.b, color: awayColor)

                    HStack(spacing: 6) {
                        Button(copy.text(.undo)) { undo() }
                            .buttonStyle(.bordered)
                            .disabled(session.undoHistory.isEmpty)
                            .font(.system(size: 10, weight: .bold))
                        Button(copy.text(.newMatchShort)) { showRestartConfirmation = true }
                            .buttonStyle(.bordered)
                            .font(.system(size: 10, weight: .bold))
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
            }

            if let banner = activeBanner, !session.match.isFinished {
                bannerView(banner)
                    .contentShape(Rectangle())
                    .onTapGesture { dismissBanner() }
                    .zIndex(3)
            }
            if session.match.isFinished && !session.finishedBannerDismissed {
                matchFinishedView
                    .contentShape(Rectangle())
                    .onTapGesture {
                        session.finishedBannerDismissed = true
                        persist()
                    }
                    .zIndex(4)
            }
            }
            if showingSplash {
                ScoreSplashView()
                    .transition(.opacity)
                    .zIndex(20)
            }
        }
        .onAppear {
            let delay = reduceMotion ? 0.25 : 1.8
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.35)) {
                    showingSplash = false
                }
            }
        }
        .confirmationDialog(copy.text(.confirmNewMatch), isPresented: $showRestartConfirmation) {
            Button(copy.text(.newMatch), role: .destructive) { startNewMatch() }
            Button(copy.text(.cancel), role: .cancel) { }
        }
        .alert(copy.text(.saveFailed), isPresented: Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })) {
            Button("OK", role: .cancel) { saveError = nil }
        } message: {
            Text(saveError ?? copy.text(.saveFailedExplanation))
        }
    }

    private func displayName(for side: Side) -> String {
        let i = side.rawValue
        guard session.playerNames.indices.contains(i) else { return "\(copy.text(.team)) \(i + 1)" }
        let name = session.playerNames[i]
        if side == .a && name == "ICH" { return copy.text(.me) }
        if side == .b && name == "GEGNER" { return copy.text(.opponent) }
        return name
    }

    private var winningTeamName: String {
        let winningSide = session.match.winner ?? .a
        let name = displayName(for: winningSide)
        guard session.matchKind != .single,
              session.partnerNames.indices.contains(winningSide.rawValue) else { return name }
        let partner = session.partnerNames[winningSide.rawValue]
        return partner.isEmpty ? name : name + " / " + partner
    }

    private func scoreRow(_ side: Side, color: Color) -> some View {
        let i = side.rawValue
        return VStack(spacing: 2) {
            HStack(spacing: 2) {
                Text(displayName(for: side))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if session.match.currentServer == side && !session.match.isFinished {
                    Image(systemName: "tennisball.fill")
                }
            }
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(color)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(session.match.sets[i])").font(.system(size: 10, weight: .medium))
                Text("\(session.match.games[i])").font(.system(size: 18, weight: .heavy))
            }
            .foregroundStyle(.white)
            Text(session.match.pointLabel(for: side))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 9))
    }

    private func pointButton(_ side: Side, color: Color) -> some View {
        Button {
            award(side)
        } label: {
            HStack(spacing: 6) {
                Text(side == .a ? copy.text(.me) : copy.text(.opponent))
                    .font(.system(size: 15, weight: .black))
                Spacer(minLength: 0)
                Text("+1")
                    .font(.system(size: 17, weight: .black, design: .rounded))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 53)
            .background(color, in: RoundedRectangle(cornerRadius: 13))
        }
        .buttonStyle(.plain)
        .disabled(session.match.isFinished)
    }

    private func bannerView(_ notice: MatchNotice) -> some View {
        VStack(spacing: 13) {
            Text(noticeTitle(notice))
                .font(.system(size: 18, weight: .black))
                .multilineTextAlignment(.center)
                .foregroundStyle(homeColor)
            Text(notice == .decidingPoint ? copy.text(.noAdExplanation) : copy.text(.continueAfterNotice))
                .font(.system(size: 11, weight: .medium))
                .multilineTextAlignment(.center)
            Text(copy.text(.tapToClose))
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
        .background(Color(red: 0.08, green: 0.16, blue: 0.26))
    }

    private var matchFinishedView: some View {
        VStack(spacing: 10) {
            Text(copy.text(.matchEnded))
                .font(.system(size: 10, weight: .black))
            Text(copy.text(.winner))
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(homeColor)
            Text(winningTeamName)
                .font(.system(size: 18, weight: .bold))
                .multilineTextAlignment(.center)
            Text(finalResult)
                .font(.system(size: 12, weight: .bold))
                .multilineTextAlignment(.center)
            Text("\(copy.text(.duration)) \(elapsedTime)")
                .font(.system(size: 11, weight: .medium))
            Text(copy.text(.tapToClose))
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(10)
        .background(Color(red: 0.07, green: 0.14, blue: 0.24))
    }

    private var elapsedTime: String {
        let seconds = max(0, Int((session.finishedAt ?? Date()).timeIntervalSince(session.startedAt)))
        return String(format: "%02d:%02d:%02d", seconds / 3600, seconds % 3600 / 60, seconds % 60)
    }

    private var finalResult: String {
        session.match.completed.map { set in
            if set.isMatchTiebreak { return "MTB \(set.games[0]):\(set.games[1])" }
            let ordinary = "\(set.games[0]):\(set.games[1])"
            guard let tb = set.tiebreakPoints else { return ordinary }
            return "\(ordinary) (TB \(tb[0]):\(tb[1]))"
        }.joined(separator: " · ")
    }

    private func noticeTitle(_ notice: MatchNotice) -> String {
        switch notice {
        case .changeEnds: return copy.text(.changeEnds)
        case .setBreak: return copy.text(.setBreak)
        case .changeEndsAndSetBreak: return copy.text(.changeEndsAndBreak)
        case .decidingPoint: return copy.text(.decidingPoint)
        case .matchFinished: return copy.text(.matchEnded)
        }
    }

    private func award(_ side: Side) {
        guard activeBanner == nil, !session.match.isFinished else { return }
        session.awardPoint(to: side)
        persist()
        if let notice = session.match.notice, notice != .matchFinished {
            activeBanner = notice
            let token = UUID()
            bannerToken = token
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if bannerToken == token { dismissBanner() }
            }
        }
    }

    private func undo() {
        guard activeBanner == nil else { return }
        if session.undo() { persist() }
    }

    private func dismissBanner() {
        activeBanner = nil
        bannerToken = UUID()
    }

    private func startNewMatch() {
        // Keep the completed/current session until the next setup is confirmed.
        showingConfiguration = true
        dismissBanner()
    }

    private func persist() {
        do { try ScoreSessionStore.save(session) }
        catch { saveError = error.localizedDescription }
    }
}
