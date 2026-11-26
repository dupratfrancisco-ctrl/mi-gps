import ActivityKit
import Foundation

/// Crea, actualiza y cierra la Actividad en vivo de la navegación.
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var activity: Activity<NavAttributes>?

    func handle(type: String, body: [String: Any]) {
        switch type {
        case "navStart":
            start(destination: body["dest"] as? String ?? "Destino", state: state(from: body))
        case "navUpdate":
            if activity == nil {
                start(destination: body["dest"] as? String ?? "Destino", state: state(from: body))
            } else {
                update(state(from: body))
            }
        case "navEnd":
            end()
        default:
            break
        }
    }

    private func state(from b: [String: Any]) -> NavAttributes.ContentState {
        let etaMs = (b["eta"] as? Double) ?? Date().timeIntervalSince1970 * 1000
        return NavAttributes.ContentState(
            arrow: (b["arrow"] as? Double) ?? 0,
            dist: b["dist"] as? String ?? "",
            msg: b["msg"] as? String ?? "",
            eta: Date(timeIntervalSince1970: etaMs / 1000),
            rest: b["rest"] as? String ?? "",
            limit: (b["limit"] as? Double).map { Int($0) },
            arrived: b["arrived"] as? Bool ?? false
        )
    }

    private func start(destination: String, state: NavAttributes.ContentState) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        for old in Activity<NavAttributes>.activities {
            Task { await old.end(nil, dismissalPolicy: .immediate) }
        }
        do {
            activity = try Activity.request(
                attributes: NavAttributes(destination: destination),
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("No se pudo iniciar la Actividad en vivo:", error)
        }
    }

    private func update(_ state: NavAttributes.ContentState) {
        guard let activity else { return }
        Task { await activity.update(ActivityContent(state: state, staleDate: nil)) }
    }

    private func end() {
        for a in Activity<NavAttributes>.activities {
            Task { await a.end(nil, dismissalPolicy: .immediate) }
        }
        activity = nil
    }
}
