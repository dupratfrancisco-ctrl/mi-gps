import SwiftUI

@main
struct MiGPSApp: App {
    init() {
        // Si quedó una Isla Dinámica de una vez anterior (app cerrada), la saco
        LiveActivityManager.shared.endAll()
    }

    var body: some Scene {
        WindowGroup {
            WebView(url: URL(string: "https://dupratfrancisco-ctrl.github.io/mi-gps/?app=ios")!)
                .ignoresSafeArea()
                .background(Color(red: 241/255, green: 240/255, blue: 236/255))
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    // Al cerrar la app (deslizarla hacia arriba) se cierra la Isla Dinámica
                    LiveActivityManager.shared.endAllAndWait()
                }
        }
    }
}
