import ActivityKit
import Foundation

/// Datos de la Actividad en vivo (Isla Dinámica y pantalla bloqueada).
struct NavAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var arrow: Double      // giro de la flecha en grados (0 = derecho)
        var dist: String       // "250 m"
        var msg: String        // "Gire a la izquierda en Av. Alberdi"
        var eta: Date          // hora de llegada
        var rest: String       // "12 min · 5,0 km"
        var limit: Int?        // límite de velocidad
        var arrived: Bool
    }
    var destination: String
}
