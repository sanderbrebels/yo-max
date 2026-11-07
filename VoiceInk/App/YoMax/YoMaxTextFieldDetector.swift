import AppKit
import ApplicationServices
import Foundation
import os

/// Yo Max: decides whether the focused element can take pasted text.
///
/// It asks the frontmost app (never Yo Max itself: the recorder panel can become key and
/// would otherwise answer). It only says `.notEditable` when the focus is clearly a control
/// (button, checkbox, menu and so on); "nothing focused" counts as unknown. Browsers and Electron apps often report
/// a generic group or web area; then the answer is `.unknown` and Yo Max pastes as before.
enum YoMaxTextFieldDetector {
    enum Result: String {
        case editable
        case notEditable
        case unknown
    }

    private static let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "YoMaxTextFieldDetector")
    private static let messagingTimeout: Float = 0.15

    /// Roles that always take typed text.
    private static let textRoles: Set<String> = [
        "AXTextField", "AXTextArea", "AXComboBox", "AXSearchField", "AXSecureTextField",
    ]

    /// Roles that never take typed text. Kept short on purpose: tables and cells (Numbers,
    /// Excel), scroll areas and static text can sit around or inside something you paste into.
    private static let nonTextRoles: Set<String> = [
        "AXButton", "AXCheckBox", "AXRadioButton", "AXPopUpButton", "AXMenuButton", "AXSlider",
        "AXImage", "AXLink", "AXToolbar", "AXMenu", "AXMenuBar", "AXMenuItem", "AXDisclosureTriangle",
    ]

    static func focusedElementState() -> Result {
        let result = evaluate()
        logger.notice("Focused element state: \(result.rawValue, privacy: .public)")
        return result
    }

    private static func evaluate() -> Result {
        guard AXIsProcessTrusted(),
            let app = NSWorkspace.shared.frontmostApplication,
            app.processIdentifier != ProcessInfo.processInfo.processIdentifier
        else { return .unknown }

        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        AXUIElementSetMessagingTimeout(appElement, messagingTimeout)

        let read = AccessibilityFocusReader.focusedElement(in: appElement)
        guard let element = read.element else {
            // "Nothing focused" is not proof: Electron apps (Claude, Slack, Notion, VS Code)
            // answer this while the caret is in a text field. Paste as VoiceInk does.
            return .unknown
        }
        AXUIElementSetMessagingTimeout(element, messagingTimeout)

        let role = AccessibilityFocusReader.stringAttribute(kAXRoleAttribute as CFString, from: element)
        if let role, textRoles.contains(role) {
            return .editable
        }
        if AccessibilityFocusReader.boolAttribute("AXEditable" as CFString, from: element) == true {
            return .editable
        }
        // Checked before "settable value": a slider or checkbox has a settable value too.
        if let role, nonTextRoles.contains(role) {
            logger.notice("Not a text field: role=\(role, privacy: .public) app=\(app.bundleIdentifier ?? "?", privacy: .public)")
            return .notEditable
        }

        var settable: DarwinBoolean = false
        if AXUIElementIsAttributeSettable(element, kAXValueAttribute as CFString, &settable) == .success,
            settable.boolValue
        {
            return .editable
        }
        return .unknown
    }
}
