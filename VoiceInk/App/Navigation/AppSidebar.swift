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
            sidebarSection(ViewType.primaryItems)
                .padding(.top, 10)

            Spacer(minLength: 16)

            sidebarSection(ViewType.secondaryItems)
                .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Yo Max: the Tarmax laptop sidebar, a floating card 12 pt from the edges (radius 24, --shadow-float).
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppTheme.Brand.elevFloat)
                .shadow(color: AppTheme.Brand.ink.opacity(0.08), radius: 8, y: 4)
        )
        .padding(12)
    }

    // Yo Max: the Tarmax page behind the floating sidebar card, and no divider.
    private var sidebarBackground: some View {
        AppTheme.Surface.window
            .ignoresSafeArea(.container, edges: .top)
    }

    private var sidebarDivider: some View {
        Color.clear.frame(width: 0)
    }

    private func sidebarSection(_ items: [ViewType]) -> some View {
        VStack(spacing: 3) {
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

    var icon: String {
        switch self {
        case .dashboard: return "gauge.medium"
        case .transcribeAudio: return "waveform.path"
        case .history: return "doc.text.fill"
        case .models: return "cpu"
        case .modes: return "sparkles.square.fill.on.square"
        case .audio: return "mic.fill"
        case .dictionary: return "text.book.closed.fill"
        case .settings: return "gearshape.fill"
        case .license: return "checkmark.seal.fill"
        }
    }

    var sidebarIconStyle: SidebarIconStyle {
        switch self {
        case .dashboard:
            return .init(background: AppTheme.Sidebar.dashboard)
        case .modes:
            return .init(background: AppTheme.Sidebar.modes)
        case .models:
            return .init(background: AppTheme.Sidebar.models)
        case .audio:
            return .init(background: AppTheme.Sidebar.fallback)
        case .dictionary:
            return .init(background: AppTheme.Sidebar.dictionary)
        case .history:
            return .init(background: AppTheme.Sidebar.audio)
        case .transcribeAudio:
            return .init(background: AppTheme.Sidebar.transcribeAudio)
        case .settings:
            return .init(background: AppTheme.Sidebar.fallback)
        case .license:
            return .init(background: AppTheme.Sidebar.license)
        }
    }
}

private struct SidebarIconStyle {
    let background: Color
    var foreground: Color = AppTheme.Sidebar.iconForeground  // Yo Max: lime sign on brand-dark
}

private struct SidebarItemButton: View {
    let viewType: ViewType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                SidebarIconTile(
                    systemName: viewType.icon,
                    style: viewType.sidebarIconStyle
                )

                Text(viewType.title)
                    .font(.yoMax(13.5, weight: .medium))  // Yo Max: Aeonik 500
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .foregroundStyle(isSelected ? selectedForegroundColor : AppTheme.Text.primary)
            .padding(.leading, 8)
            .padding(.trailing, 10)
            .frame(height: 38)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(rowBackground)
            .contentShape(Capsule())  // Yo Max: Tarmax pill
        }
        .buttonStyle(.plain)
        .help(viewType.title)
        .accessibilityLabel(viewType.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.easeInOut(duration: 0.12), value: isSelected)
    }

    private var rowBackground: some View {
        Capsule()  // Yo Max: the lime Tarmax pill
            .fill(rowBackgroundColor)
    }

    private var rowBackgroundColor: Color {
        if isSelected {
            return AppTheme.Sidebar.selectedRow  // Yo Max: the lime Tarmax pill
        }

        return .clear
    }

    private var rowBorderColor: Color {
        isSelected ? selectedForegroundColor.opacity(0.18) : .clear
    }

    private var selectedForegroundColor: Color {
        AppTheme.Sidebar.selectedRowText  // Yo Max: ink on lime
    }
}

private struct SidebarIconTile: View {
    let systemName: String
    let style: SidebarIconStyle

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(style.background)
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.white.opacity(0.18))
                        .frame(height: 11)
                        .blendMode(.screen)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.24), lineWidth: 0.5)
                }
                .shadow(color: Color.black.opacity(0.18), radius: 1.2, y: 1)

            Image(systemName: systemName)
                .font(.yoMax(14.5, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(style.foreground)
                .shadow(color: Color.black.opacity(0.16), radius: 0.5, y: 0.5)
        }
        .frame(width: 24, height: 24)
    }
}
