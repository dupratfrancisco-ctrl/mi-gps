import SwiftUI

@main
struct MiGPSApp: App {
    var body: some Scene {
        WindowGroup {
            WebView(url: URL(string: "https://dupratfrancisco-ctrl.github.io/mi-gps/?app=ios")!)
                .ignoresSafeArea()
                .background(Color(red: 14/255, green: 17/255, blue: 22/255))
                .preferredColorScheme(.dark)
        }
    }
}
