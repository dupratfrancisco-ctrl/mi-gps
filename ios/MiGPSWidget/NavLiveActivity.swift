import ActivityKit
import WidgetKit
import SwiftUI

private let verde = Color(red: 0, green: 0.63, blue: 0.35)

struct NavLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NavAttributes.self) { context in
            // Pantalla bloqueada
            LockScreenView(state: context.state)
                .activityBackgroundTint(Color(red: 0.09, green: 0.11, blue: 0.13))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 6) {
                        AppBadge(size: 18, showName: true)
                        TurnArrow(state: context.state, size: 30)
                    }
                    .padding(.leading, 6)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Llegás")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(context.state.eta, style: .time)
                            .font(.headline)
                            .monospacedDigit()
                    }
                    .padding(.trailing, 6)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.dist)
                        .font(.title2.bold())
                        .foregroundStyle(verde)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 4) {
                        Text(context.state.msg)
                            .font(.subheadline)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                        Text(context.state.rest)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                AppBadge(size: 20, showName: false)
            } compactTrailing: {
                HStack(spacing: 3) {
                    TurnArrow(state: context.state, size: 12)
                    Text(context.state.dist)
                        .font(.caption.bold())
                        .foregroundStyle(verde)
                        .monospacedDigit()
                        .lineLimit(1)
                }
            } minimal: {
                AppBadge(size: 20, showName: false)
            }
            .keylineTint(verde)
        }
    }
}

/// Logo de Mi GPS (y opcionalmente el nombre)
struct AppBadge: View {
    let size: CGFloat
    let showName: Bool
    var body: some View {
        HStack(spacing: 5) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
            if showName {
                Text("Mi GPS")
                    .font(.system(size: size * 0.7, weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
    }
}

struct TurnArrow: View {
    let state: NavAttributes.ContentState
    let size: CGFloat
    var body: some View {
        Image(systemName: state.arrived ? "flag.checkered" : "arrow.up")
            .font(.system(size: size, weight: .heavy))
            .foregroundStyle(verde)
            .rotationEffect(.degrees(state.arrived ? 0 : state.arrow))
    }
}

struct LockScreenView: View {
    let state: NavAttributes.ContentState
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
        AppBadge(size: 18, showName: true)
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(verde)
                Image(systemName: state.arrived ? "flag.checkered" : "arrow.up")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(state.arrived ? 0 : state.arrow))
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 3) {
                Text(state.dist)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(state.msg)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(2)
                HStack(spacing: 4) {
                    Text("Llegás")
                    Text(state.eta, style: .time)
                    if !state.rest.isEmpty { Text("· " + state.rest) }
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            }
            Spacer(minLength: 0)

            if let limit = state.limit {
                ZStack {
                    Circle().fill(.white)
                    Circle().stroke(Color.red, lineWidth: 5)
                    Text("\(limit)")
                        .font(.headline.bold())
                        .foregroundStyle(.black)
                }
                .frame(width: 46, height: 46)
            }
        }
        }
        .padding(16)
    }
}
