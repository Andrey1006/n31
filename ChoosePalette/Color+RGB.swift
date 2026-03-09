import SwiftUI
import UIKit

extension Color {
    
    func toHex() -> String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    static func rgb(_ red: Int, _ green: Int, _ blue: Int, opacity: Double = 1) -> Color {
        Color(
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: opacity
        )
    }

    
    static func hex(_ hex: String) -> Color? {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let value = Int(s, radix: 16) else { return nil }
        let r = (value >> 16) & 0xFF
        let g = (value >> 8) & 0xFF
        let b = value & 0xFF
        return .rgb(r, g, b)
    }
}
