import AppKit
import os

/// Yo Max: paste where you started dictating.
///
/// VoiceInk pastes into whatever app is in front when the text is ready. If you switch
/// windows or screens while you are still talking, the text lands somewhere else (or nowhere).
/// Yo Max remembers the app that was in front when the recording started and, if another app
/// is in front at paste time, brings that app back before pasting.
@MainActor
enum YoMaxPasteTarget {
    private static let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "YoMaxPasteTarget")
    private static var startApp: NSRunningApplication?

    /// Call when a recording starts.
    static func rememberFrontmostApp() {
        let front = NSWorkspace.shared.frontmostApplication
        // Never remember Yo Max itself (its own windows or the recorder panel).
        if let front, front.processIdentifier != ProcessInfo.processInfo.processIdentifier {
            startApp = front
        } else {
            startApp = nil
        }
    }

    /// Call right before pasting. Returns once the start app is in front again (or after a short wait).
    static func restoreIfNeeded() async {
        guard let app = startApp, !app.isTerminated else { return }
        startApp = nil
        let front = NSWorkspace.shared.frontmostApplication
        guard front?.processIdentifier != app.processIdentifier else { return }

        logger.notice("Bringing back \(app.bundleIdentifier ?? "?", privacy: .public) before pasting (front: \(front?.bundleIdentifier ?? "none", privacy: .public))")
        app.activate()
        // Wait until macOS really made it frontmost, so the paste goes to its key window.
        for _ in 0..<20 {
            if NSWorkspace.shared.frontmostApplication?.processIdentifier == app.processIdentifier { break }
            try? await Task.sleep(for: .milliseconds(25))
        }
        // Give the window a moment to become key and restore its text focus.
        try? await Task.sleep(for: .milliseconds(80))
    }
}
