import SwiftUI

@main
struct MiGPSApp: App {
    var body: some Scene {
        WindowGroup {
            WebView(url: URL(string: "https://dupratfrancisco-ctrl.github.io/mi-gps/?app=ios")!)
                .ignoresSafeArea()
                .background(Color(red: 241/255, green: 240/255, blue: 236/255))
                .preferredColorScheme(.light)
        }
    }
}
