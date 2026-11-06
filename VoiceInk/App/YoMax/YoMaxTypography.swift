import AppKit
import SwiftUI

/// Yo Max: Tarmax typography (Aeonik 400 / 500 / 700).
///
/// Aeonik is a paid font, so it is never bundled with the app or committed to git.
/// When it is installed on the Mac (~/Library/Fonts), Yo Max uses it; otherwise it falls
/// back to the system font, so a shared copy of the app still looks right.
extension Font {
    static func yoMax(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name = YoMaxTypography.aeonikName(for: weight)
        if YoMaxTypography.isInstalled(name) {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: weight)
    }
}

enum YoMaxTypography {
    /// The body size on macOS.
    static let bodySize: CGFloat = 13

    static func aeonikName(for weight: Font.Weight) -> String {
        switch weight {
        case .bold, .heavy, .black:
            return "Aeonik-Bold"
        case .medium, .semibold:
            return "Aeonik-Medium"
        default:
            return "Aeonik-Regular"
        }
    }

    private static var cache: [String: Bool] = [:]
    private static let lock = NSLock()

    static func isInstalled(_ postScriptName: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if let known = cache[postScriptName] { return known }
        let installed = NSFont(name: postScriptName, size: bodySize) != nil
        cache[postScriptName] = installed
        return installed
    }
}
