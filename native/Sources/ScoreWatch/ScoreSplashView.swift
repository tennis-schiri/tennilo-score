import SwiftUI

/// Shared branded startup animation, sized by the container.
/// Watch launch is wired here; reusable unchanged by a future iPhone app target.
struct ScoreSplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animated = false

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.12, green: 0.25, blue: 0.35),
                             Color(red: 0.035, green: 0.08, blue: 0.14)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                Circle()
                    .stroke(Color.cyan.opacity(0.35), lineWidth: 1)
                    .frame(width: side * 0.70, height: side * 0.70)
                    .rotationEffect(.degrees(animated ? 360 : 0))
                Circle()
                    .trim(from: 0.03, to: 0.20)
                    .stroke(Color(red: 0.75, green: 0.97, blue: 0.43),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: side * 0.70, height: side * 0.70)
                    .rotationEffect(.degrees(animated ? 360 : 0))
                Image("ScoreBrand")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geo.size.width * 0.8, 230))
                    .shadow(color: .black.opacity(0.6), radius: 10, y: 5)
                    .scaleEffect(animated && !reduceMotion ? 1 : 0.92)
                    .opacity(animated || reduceMotion ? 1 : 0.7)
                VStack {
                    Spacer()
                    Text("READY · SET · PLAY")
                        .font(.system(size: 9, weight: .black))
                        .kerning(1.4)
                        .foregroundStyle(.cyan.opacity(0.8))
                        .padding(.bottom, max(12, side * 0.07))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            if !reduceMotion {
                withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                    animated = true
                }
            } else {
                animated = true
            }
        }
        .accessibilityLabel("TENNILO Score")
    }
}
