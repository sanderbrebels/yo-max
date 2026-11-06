import AppKit
import SwiftUI

/// Yo Max: when there is no text field to paste into, show the transcript in a small
/// Tarmax card at the top of the screen, with a Copy button (like Wispr Flow).
@MainActor
final class YoMaxCopyPanelController {
    static let shared = YoMaxCopyPanelController()

    private static let width: CGFloat = 540  // the 520 pt card plus room for its shadow
    private static let topMargin: CGFloat = 12
    private static let visibleDuration: Duration = .seconds(15)

    private var panel: NSPanel?
    private var hideTask: Task<Void, Never>?
    private var isHovering = false

    private init() {}

    func show(text: String) {
        hide()

        let view = YoMaxCopyPanelView(
            text: text,
            onCopy: { [weak self] in
                _ = ClipboardManager.copyToClipboard(text)
                self?.scheduleHide(after: .milliseconds(900))
            },
            onClose: { [weak self] in self?.hide() },
            onHover: { [weak self] hovering in
                self?.isHovering = hovering
                if !hovering { self?.scheduleHide(after: .seconds(4)) }
            }
        )

        let hosting = NSHostingView(rootView: view)
        hosting.frame.size = hosting.fittingSize
        let size = NSSize(width: Self.width, height: hosting.fittingSize.height)

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false  // the card draws its own Tarmax shadow
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.contentView = hosting

        let screen = NSScreen.screens.first { $0.frame.contains(NSEvent.mouseLocation) } ?? NSScreen.main
        if let visible = screen?.visibleFrame {
            panel.setFrameOrigin(
                NSPoint(
                    x: visible.midX - size.width / 2,
                    y: visible.maxY - size.height - Self.topMargin
                )
            )
        }

        panel.alphaValue = 0
        panel.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.24  // Tarmax --dur
            panel.animator().alphaValue = 1
        }

        self.panel = panel
        scheduleHide(after: Self.visibleDuration)
    }

    func hide() {
        hideTask?.cancel()
        hideTask = nil
        guard let panel else { return }
        self.panel = nil
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.16  // Tarmax --dur-fast
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
        })
    }

    private func scheduleHide(after delay: Duration) {
        hideTask?.cancel()
        hideTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled, let self, !self.isHovering else { return }
            self.hide()
        }
    }
}

private struct YoMaxCopyPanelView: View {
    let text: String
    let onCopy: () -> Void
    let onClose: () -> Void
    let onHover: (Bool) -> Void

    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("No text field. Copied to clipboard.")
                    .font(.yoMax(12, weight: .medium))
                    .foregroundStyle(AppTheme.Text.secondary)

                Spacer(minLength: 8)

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.yoMax(11, weight: .medium))
                        .foregroundStyle(AppTheme.Brand.ink)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(AppTheme.Brand.fillStrong))
                }
                .buttonStyle(.plain)
                .help("Close")
            }

            ScrollView {
                Text(text)
                    .font(.yoMax(14))
                    .foregroundStyle(AppTheme.Text.primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 160)
            .fixedSize(horizontal: false, vertical: true)

            HStack {
                Spacer()
                Button {
                    copied = true
                    onCopy()
                } label: {
                    Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.yoMax(13, weight: .medium))
                        .foregroundStyle(AppTheme.Brand.onAccent)
                        .padding(.horizontal, 16)
                        .frame(height: 34)
                        .background(Capsule().fill(AppTheme.Brand.accent))
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(width: 520)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppTheme.Brand.elevFloat)
                .shadow(color: AppTheme.Brand.ink.opacity(0.08), radius: 8, y: 4)  // --shadow-float
        )
        .padding(10)
        .onHover(perform: onHover)
    }
}
