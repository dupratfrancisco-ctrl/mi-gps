import SwiftUI
import UIKit

/// Se entera de cuando se cierra la app (deslizándola hacia arriba) para sacar la Isla Dinámica
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Si quedó una Isla Dinámica de una vez anterior (app cerrada), la saco
        LiveActivityManager.shared.endAll()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Al cerrar la app se cierra la Isla Dinámica (espera a que iOS la saque antes de terminar)
        LiveActivityManager.shared.endAllAndWait()
    }
}

@main
struct MiGPSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            WebView(url: URL(string: "https://dupratfrancisco-ctrl.github.io/mi-gps/?app=ios")!)
                .ignoresSafeArea()
                .background(Color(red: 241/255, green: 240/255, blue: 236/255))
        }
        .onChange(of: scenePhase) { _, phase in
            // Si la app queda en segundo plano sin estar navegando, no tiene por qué quedar la isla
            if phase == .background && !LiveActivityManager.shared.isNavigating {
                LiveActivityManager.shared.endAll()
            }
        }
    }
}
