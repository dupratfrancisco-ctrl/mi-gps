import SwiftUI
import WebKit
import CoreLocation

/// Muestra la app web de Mi GPS, guarda su configuración en el teléfono
/// y maneja la Isla Dinámica y el GPS en segundo plano durante la navegación.
struct WebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .default()
        config.userContentController.add(context.coordinator, name: "migps")

        // La configuración guardada en el teléfono se le pasa a la página antes de que cargue
        let saved = SettingsStore.all()
        if let data = try? JSONSerialization.data(withJSONObject: saved),
           let json = String(data: data, encoding: .utf8) {
            let script = WKUserScript(source: "window.__nativeStore = \(json);",
                                      injectionTime: .atDocumentStart, forMainFrameOnly: true)
            config.userContentController.addUserScript(script)
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 241/255, green: 240/255, blue: 236/255, alpha: 1)
        webView.scrollView.backgroundColor = webView.backgroundColor
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.bounces = false
        webView.allowsBackForwardNavigationGestures = false
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        webView.load(URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate, CLLocationManagerDelegate {
        weak var webView: WKWebView?
        private let locationManager = CLLocationManager()
        private var navigating = false

        override init() {
            super.init()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.activityType = .automotiveNavigation
            locationManager.requestWhenInUseAuthorization()
            // Brújula del teléfono: usa el mismo permiso de ubicación, no hay que aceptar nada más
            locationManager.headingFilter = 2
            if CLLocationManager.headingAvailable() { locationManager.startUpdatingHeading() }
        }

        private var lastHeadingSent = Date.distantPast
        func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            guard let webView, Date().timeIntervalSince(lastHeadingSent) > 0.08 else { return }
            let h = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
            guard h >= 0 else { return }
            lastHeadingSent = Date()
            webView.evaluateJavaScript("window.__nativeHeading && window.__nativeHeading(\(h))", completionHandler: nil)
        }

        // Si la página pide la brújula o el movimiento, se lo doy sin preguntar cada vez
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView, requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin,
                     initiatedByFrame frame: WKFrameInfo, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            decisionHandler(.grant)
        }

        // Mensajes de la página
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let body = message.body as? [String: Any], let type = body["type"] as? String else { return }
            switch type {
            case "store":
                if let key = body["key"] as? String {
                    SettingsStore.set(key, body["value"] as? String)
                }
            case "navStart":
                startBackgroundGPS()
                LiveActivityManager.shared.handle(type: type, body: body)
            case "navEnd":
                stopBackgroundGPS()
                LiveActivityManager.shared.handle(type: type, body: body)
            default:
                if type == "navUpdate" && !navigating { startBackgroundGPS() }
                LiveActivityManager.shared.handle(type: type, body: body)
            }
        }

        // GPS en segundo plano mientras navegás (mantiene viva la app y la Isla Dinámica)
        private func startBackgroundGPS() {
            navigating = true
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.showsBackgroundLocationIndicator = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
        }

        private func stopBackgroundGPS() {
            navigating = false
            locationManager.stopUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = false
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard navigating, let loc = locations.last, let webView else { return }
            let js = "window.__nativeLoc && window.__nativeLoc(\(loc.coordinate.latitude), \(loc.coordinate.longitude), \(loc.speed), \(loc.course))"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }

        // Los links que abren otra ventana se abren en Safari
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url { UIApplication.shared.open(url) }
            return nil
        }

        // Si se cae la conexión al abrir, reintenta en unos segundos
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak webView] in webView?.reload() }
        }
    }
}

/// Configuración de la app guardada en el teléfono (destinos, P del auto, etc.)
enum SettingsStore {
    private static let key = "migpsStore"
    static func all() -> [String: String] {
        UserDefaults.standard.dictionary(forKey: key) as? [String: String] ?? [:]
    }
    static func set(_ k: String, _ v: String?) {
        var d = all()
        if let v { d[k] = v } else { d.removeValue(forKey: k) }
        UserDefaults.standard.set(d, forKey: key)
    }
}
