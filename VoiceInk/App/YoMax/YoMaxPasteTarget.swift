import AppKit
import ApplicationServices
import os

/// Yo Max: paste where you started dictating.
///
/// VoiceInk pastes into whatever app is in front when the text is ready. If you switch
/// windows or screens while you are still talking, the text lands somewhere else (or nowhere).
/// Yo Max remembers the app and window that were in front when the recording started and,
/// if another app is in front at paste time, brings them back before pasting.
///
/// Since macOS 14 a background app may not activate another app (`activate()` is only a
/// request and is usually refused), so this goes through Accessibility: set the app frontmost,
/// raise the remembered window, and only then fall back to `activate()`.
@MainActor
enum YoMaxPasteTarget {
    private static let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "YoMaxPasteTarget")
    private static var startApp: NSRunningApplication?
    private static var startWindow: AXUIElement?

    /// Call when a recording starts.
    static func rememberFrontmostApp() {
        startApp = nil
        startWindow = nil
        guard let front = NSWorkspace.shared.frontmostApplication,
            front.processIdentifier != ProcessInfo.processInfo.processIdentifier  // never Yo Max itself
        else { return }
        startApp = front
        if AXIsProcessTrusted() {
            let appElement = AXUIElementCreateApplication(front.processIdentifier)
            AXUIElementSetMessagingTimeout(appElement, 0.15)
            var value: CFTypeRef?
            if AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &value) == .success,
                let value, CFGetTypeID(value) == AXUIElementGetTypeID()
            {
                startWindow = (value as! AXUIElement)
            }
        }
    }

    /// Call right before pasting. Returns once the start app is in front again (or after a short wait).
    static func restoreIfNeeded() async {
        guard let app = startApp, !app.isTerminated else { return }
        let window = startWindow
        startApp = nil
        startWindow = nil
        let front = NSWorkspace.shared.frontmostApplication
        guard front?.processIdentifier != app.processIdentifier else { return }

        logger.notice("Bringing back \(app.bundleIdentifier ?? "?", privacy: .public) before pasting (front: \(front?.bundleIdentifier ?? "none", privacy: .public))")

        if AXIsProcessTrusted() {
            let appElement = AXUIElementCreateApplication(app.processIdentifier)
            AXUIElementSetMessagingTimeout(appElement, 0.2)
            let frontmost = AXUIElementSetAttributeValue(appElement, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
            if let window {
                AXUIElementSetAttributeValue(window, kAXMainAttribute as CFString, kCFBooleanTrue)
                AXUIElementPerformAction(window, kAXRaiseAction as CFString)
            }
            logger.notice("AX frontmost result=\(frontmost.rawValue, privacy: .public) window=\(window != nil, privacy: .public)")
        }

        if !(await waitUntilFrontmost(app, attempts: 12)) {
            app.activate(options: [.activateAllWindows])
            _ = await waitUntilFrontmost(app, attempts: 12)
        }

        let ok = NSWorkspace.shared.frontmostApplication?.processIdentifier == app.processIdentifier
        logger.notice("Start app frontmost before paste: \(ok, privacy: .public)")
        // Give the window a moment to become key and restore its text focus.
        try? await Task.sleep(for: .milliseconds(120))
    }

    private static func waitUntilFrontmost(_ app: NSRunningApplication, attempts: Int) async -> Bool {
        for _ in 0..<attempts {
            if NSWorkspace.shared.frontmostApplication?.processIdentifier == app.processIdentifier { return true }
            try? await Task.sleep(for: .milliseconds(25))
        }
        return NSWorkspace.shared.frontmostApplication?.processIdentifier == app.processIdentifier
    }
}
