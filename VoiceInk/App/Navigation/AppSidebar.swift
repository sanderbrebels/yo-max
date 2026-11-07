import SwiftUI

struct AppSidebar: View {
    @Binding var selectedView: ViewType

    var body: some View {
        ZStack(alignment: .trailing) {
            sidebarBackground
            sidebarDivider
            sidebarContent
        }
        .frame(width: 220)
        .frame(maxHeight: .infinity)
        .onAppear {
            ViewType.assertSidebarItemsCoverAllCases()
        }
    }

    private var sidebarContent: some View {
        VStack(spacing: 0) {
            SidebarBrand()  // Yo Max: app icon, name and maker
                .padding(.top, 6)
                .padding(.bottom, 14)

            sidebarSection(ViewType.primaryItems)

            Spacer(minLength: 16)

            // Yo Max: a link to Tarmax (schets zijbalk-merk.html, variant A).
            SidebarLinkButton(title: "Tarmax", icon: "bicycle", url: SidebarBrand.tarmaxURL)
                .padding(.horizontal, 10)
                .padding(.bottom, 2)

            sidebarSection(ViewType.secondaryItems)
                .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Yo Max (Flow elevation, variant A): the sidebar lies flat on the window page; no card.
    }

    private var sidebarBackground: some View {
        AppTheme.Surface.window
            .ignoresSafeArea(.container, edges: .top)
    }

    private var sidebarDivider: some View {
        Color.clear.frame(width: 0)
    }

    private func sidebarSection(_ items: [ViewType]) -> some View {
        VStack(spacing: 2) {
            ForEach(items) { viewType in
                SidebarItemButton(
                    viewType: viewType,
                    isSelected: selectedView == viewType
                ) {
                    selectedView = viewType
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

private extension ViewType {
    var title: LocalizedStringKey {
        switch self {
        case .transcribeAudio:
            return "Transcribe"
        case .history:
            return "History"
        default:
            return LocalizedStringKey(rawValue)
        }
    }

    static let primaryItems: [ViewType] = [
        .dashboard,
        .modes,
        .transcribeAudio,
        .history,
        .dictionary,
        .models,
        .audio,
    ]

    #if LOCAL_BUILD
        // Yo Max: local builds are always licensed, so the VoiceInk Pro purchase page is hidden.
        static let secondaryItems: [ViewType] = [
            .settings,
        ]
    #else
        static let secondaryItems: [ViewType] = [
            .settings,
            .license,
        ]
    #endif

    static func assertSidebarItemsCoverAllCases() {
        #if DEBUG
            let sidebarItems = primaryItems + secondaryItems
            assert(Set(sidebarItems) == Set(allCases) && sidebarItems.count == allCases.count)
        #endif
    }

    /// Yo Max: Phosphor icon names (see `PhosphorIcon`); bold beside text, fill when chosen.
    var icon: String {
        switch self {
        case .dashboard: return "squares-four"
        case .transcribeAudio: return "waveform"
        case .history: return "clock-counter-clockwise"
        case .models: return "cpu"
        case .modes: return "sparkle"
        case .audio: return "microphone"
        case .dictionary: return "book-open-text"
        case .settings: return "gear-six"
        case .license: return "seal-check"
        }
    }
}

private struct SidebarItemButton: View {
    let viewType: ViewType
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                // Yo Max: Phosphor, 1 em beside the label; bold, and fill for the chosen page (Tarmax).
                PhosphorIcon(viewType.icon, weight: isSelected ? .fill : .bold, size: PhosphorIcon.textSize)
                    .foregroundStyle(isSelected ? AppTheme.Sidebar.selectedIcon : AppTheme.Sidebar.icon)

                Text(viewType.title)
                    .font(.yoMax(13.5, weight: .medium))  // Yo Max: Aeonik 500
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .foregroundStyle(isSelected ? AppTheme.Sidebar.selectedRowText : AppTheme.Text.primary)
            .padding(.horizontal, 10)
            .frame(height: 36)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(rowBackground)
            .contentShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sidebarRow, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .help(viewType.title)
        .accessibilityLabel(viewType.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.easeOut(duration: 0.15), value: isSelected)
        .animation(.easeOut(duration: 0.15), value: isHovering)
    }

    // Yo Max (variant A "Zacht"): a soft neutral fill for the chosen page, half of it on hover.
    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: AppTheme.Radius.sidebarRow, style: .continuous)
            .fill(isSelected ? AppTheme.Sidebar.selectedRow : (isHovering ? AppTheme.Sidebar.hoverRow : .clear))
    }
}

// Yo Max: the brand block at the top of the sidebar.
private struct SidebarBrand: View {
    static let maker = "by Sander Brebels"
    static let tarmaxURL = URL(string: "https://tarmax.app")!
    private static let iconSize: CGFloat = 34

    var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .interpolation(.high)
                .frame(width: Self.iconSize, height: Self.iconSize)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: "Yo Max")
                    .font(.yoMax(15, weight: .medium))
                    .foregroundStyle(AppTheme.Text.primary)
                Text(verbatim: Self.maker)
                    .font(.yoMax(11.5))
                    .foregroundStyle(AppTheme.Text.secondary)
            }
            .lineLimit(1)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
    }
}

// Yo Max: a sidebar row that opens a website; the arrow says it leaves Yo Max.
private struct SidebarLinkButton: View {
    let title: String
    let icon: String
    let url: URL

    @State private var isHovering = false

    var body: some View {
        Button {
            NSWorkspace.shared.open(url)
        } label: {
            HStack(spacing: 10) {
                PhosphorIcon(icon, size: PhosphorIcon.textSize)
                    .foregroundStyle(AppTheme.Sidebar.icon)

                Text(verbatim: title)
                    .font(.yoMax(13.5, weight: .medium))
                    .foregroundStyle(AppTheme.Text.primary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                PhosphorIcon("arrow-up-right", size: PhosphorIcon.smallSize)
                    .foregroundStyle(AppTheme.Sidebar.icon)
            }
            .padding(.horizontal, 10)
            .frame(height: 36)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.sidebarRow, style: .continuous)
                    .fill(isHovering ? AppTheme.Sidebar.hoverRow : .clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sidebarRow, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovering)
        .help(url.absoluteString)
        .accessibilityLabel(Text(verbatim: "\(title), \(url.host() ?? "")"))
        .accessibilityAddTraits(.isLink)
    }
}
