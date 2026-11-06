import ApplicationServices
import Foundation

/// Yo Max: decides whether the focused element can take pasted text.
///
/// It only says `.notEditable` when that is clear (nothing has focus, or the focus is a
/// button, list, window and so on). Browsers and Electron apps often report a generic
/// group or web area; then the answer is `.unknown` and Yo Max pastes as before.
enum YoMaxTextFieldDetector {
    enum Result: String {
        case editable
        case notEditable
        case unknown
    }

    private static let messagingTimeout: Float = 0.15

    /// Roles that never take typed text.
    private static let nonTextRoles: Set<String> = [
        "AXButton", "AXCheckBox", "AXRadioButton", "AXPopUpButton", "AXMenuButton", "AXSlider",
        "AXList", "AXOutline", "AXTable", "AXRow", "AXCell", "AXColumn", "AXBrowser",
        "AXImage", "AXStaticText", "AXLink", "AXWindow", "AXScrollArea", "AXSplitGroup",
        "AXToolbar", "AXTabGroup", "AXMenu", "AXMenuBar", "AXMenuItem", "AXDisclosureTriangle",
    ]

    static func focusedElementState() -> Result {
        guard AXIsProcessTrusted() else { return .unknown }

        let systemWide = AXUIElementCreateSystemWide()
        AXUIElementSetMessagingTimeout(systemWide, messagingTimeout)

        let read = AccessibilityFocusReader.focusedElement(in: systemWide)
        guard let element = read.element else {
            // No focused element at all (desktop, an empty window): nothing to paste into.
            return read.error == .noValue ? .notEditable : .unknown
        }
        AXUIElementSetMessagingTimeout(element, messagingTimeout)

        let role = AccessibilityFocusReader.stringAttribute(kAXRoleAttribute as CFString, from: element)
        if let editable = AccessibilityFocusReader.editableState(of: element, role: role) {
            return editable ? .editable : .notEditable
        }

        // Checked before "settable value": a slider or checkbox has a settable value too.
        if let role, nonTextRoles.contains(role) {
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
