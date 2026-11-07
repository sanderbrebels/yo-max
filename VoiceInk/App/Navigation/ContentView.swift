import OSLog
import SwiftUI

enum ViewType: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case modes = "Modes"
    case models = "AI Models"
    case transcribeAudio = "Transcribe Audio"
    case history = "History"
    case audio = "Audio"
    case dictionary = "Dictionary"
    case settings = "Settings"
    case license = "VoiceInk Pro"

    var id: String { rawValue }
}

final class MainWindowNavigation: ObservableObject {
    static let shared = MainWindowNavigation()

    @Published var selectedView: ViewType = .dashboard
    @Published var dictionarySettingsRequested = false

    private init() {}

    func navigate(to destination: String) {
        guard let viewType = ViewType(rawValue: destination) else {
            return
        }

        navigate(to: viewType)
    }

    func navigate(to destination: ViewType) {
        selectedView = destination
    }

    func openDictionarySettings() {
        dictionarySettingsRequested = true
        navigate(to: .dictionary)
    }
}

struct ContentView: View {
    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "ContentView")
    @EnvironmentObject private var navigation: MainWindowNavigation

    var body: some View {
        HStack(spacing: 0) {
            AppSidebar(selectedView: $navigation.selectedView)

            detailContent
        }
        // Yo Max: resizable window instead of a fixed 950 pt width.
        .frame(
            minWidth: AppWindowLayout.resizableMinimumWidth, maxWidth: .infinity,
            minHeight: AppWindowLayout.resizableMinimumHeight, maxHeight: .infinity)
        .onAppear {
            logger.notice("ContentView appeared")
        }
        .onDisappear {
            logger.notice("ContentView disappeared")
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToDestination)) { notification in
            if let destination = notification.userInfo?["destination"] as? String {
                logger.notice("navigateToDestination received: \(destination, privacy: .public)")
                navigation.navigate(to: destination)
            }
        }
    }

    // Yo Max (Flow elevation, 2026-11-07): the pages sit in one white panel with a hairline,
    // a step above the window page on which the sidebar lies.
    @ViewBuilder
    private var detailContent: some View {
        let panel = RoundedRectangle(cornerRadius: AppTheme.Radius.panel, style: .continuous)

        detailView(for: navigation.selectedView)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Surface.contentPanel)
            .clipShape(panel)
            .overlay(panel.strokeBorder(AppTheme.Border.panel, lineWidth: 1))
            .padding(.trailing, Self.panelInset)
            .padding(.bottom, Self.panelInset)
            .background(detailBackground)
    }

    private static let panelInset: CGFloat = 10

    private var detailBackground: some View {
        AppTheme.Surface.window
            .ignoresSafeArea(.container, edges: .top)
    }

    @ViewBuilder
    private func detailView(for viewType: ViewType) -> some View {
        switch viewType {
        case .dashboard:
            DashboardView()
        case .models:
            ModelManagementView()
        case .transcribeAudio:
            AudioTranscribeView()
        case .history:
            HistoryView()
        case .audio:
            AudioSetupView()
        case .dictionary:
            DictionarySettingsView()
        case .modes:
            ModeView()
        case .settings:
            SettingsView()
        case .license:
            LicenseManagementView()
        }
    }
}
