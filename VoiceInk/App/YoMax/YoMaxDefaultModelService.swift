import Combine
import Foundation
import os

/// Yo Max: makes local Whisper Large v3 Turbo in Dutch the default transcription setup.
///
/// Onboarding still downloads Parakeet V3 (fast start, useful for comparison). Once onboarding
/// is complete, this service downloads Whisper Large v3 Turbo in the background and, when it is
/// available, switches the starter modes that still use Parakeet V3 to Whisper Turbo + Dutch.
/// This happens once per onboarding; afterwards the user's own model choice is respected.
enum YoMaxDefaults {
    static let whisperModelName = "ggml-large-v3-turbo"
    static let parakeetModelName = "parakeet-tdt-0.6b-v3"
    static let language = "nl"

    /// Set once the starter modes were switched to Whisper Turbo. Cleared by "Reset Onboarding".
    static let switchDoneKey = "YoMaxDidSwitchToWhisperTurbo"
    /// Set once the automatic Whisper Turbo download was started, so a model the user deleted
    /// on purpose is not downloaded again.
    static let downloadStartedKey = "YoMaxDidStartWhisperTurboDownload"

    /// Keep the transcription model in memory between dictations (default on).
    static let keepModelLoadedKey = "YoMaxKeepModelLoaded"

    static var keepModelLoaded: Bool {
        UserDefaults.standard.object(forKey: keepModelLoadedKey) as? Bool ?? true
    }

    /// Show the copy card at the top of the screen when there is no text field (default on).
    static let copyPanelKey = "YoMaxShowCopyPanelWithoutTextField"

    static var showCopyPanel: Bool {
        UserDefaults.standard.object(forKey: copyPanelKey) as? Bool ?? true
    }
}

@MainActor
final class YoMaxDefaultModelService {
    static let shared = YoMaxDefaultModelService()

    private static let whisperModelName = YoMaxDefaults.whisperModelName
    private static let parakeetModelName = YoMaxDefaults.parakeetModelName
    private static let language = YoMaxDefaults.language
    private static let switchDoneKey = YoMaxDefaults.switchDoneKey
    private static let downloadStartedKey = YoMaxDefaults.downloadStartedKey

    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "YoMaxDefaultModel")
    private let defaults = UserDefaults.standard
    private var subscription: AnyCancellable?
    private weak var whisperModelManager: WhisperModelManager?

    private init() {}

    nonisolated static func resetForNewOnboarding(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: YoMaxDefaults.switchDoneKey)
    }

    func start(whisperModelManager: WhisperModelManager) {
        guard defaults.bool(forKey: OnboardingSettings.completedV2Key) else { return }
        guard !defaults.bool(forKey: Self.switchDoneKey) else { return }

        self.whisperModelManager = whisperModelManager

        if isWhisperTurboDownloaded(whisperModelManager) {
            switchStarterModesToWhisper()
            return
        }

        subscription = whisperModelManager.$availableModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] models in
                guard let self, models.contains(where: { $0.name == Self.whisperModelName }) else { return }
                self.switchStarterModesToWhisper()
                self.subscription = nil
            }

        if !defaults.bool(forKey: Self.downloadStartedKey), let model = whisperTurboModel {
            logger.notice("Starting automatic Whisper Turbo download")
            defaults.set(true, forKey: Self.downloadStartedKey)
            whisperModelManager.startDownload(model)
        }
    }

    /// Loads the active mode's Whisper model at launch so the first dictation is fast too.
    func preloadCurrentModel(
        transcriptionModelManager: TranscriptionModelManager,
        whisperModelManager: WhisperModelManager
    ) {
        guard YoMaxDefaults.keepModelLoaded,
            let model = ModeRuntimeResolver.transcriptionConfiguration(
                transcriptionModelManager: transcriptionModelManager
            )?.model,
            model.provider == .whisper,
            whisperModelManager.whisperContext == nil,
            let file = whisperModelManager.availableModels.first(where: { $0.name == model.name })
        else { return }

        Task { @MainActor in
            do {
                try await whisperModelManager.loadModel(file)
                self.logger.notice("Preloaded \(model.name, privacy: .public)")
            } catch {
                self.logger.error("Preload failed: \(error, privacy: .public)")
            }
        }
    }

    private var whisperTurboModel: WhisperModel? {
        TranscriptionModelRegistry.models
            .compactMap { $0 as? WhisperModel }
            .first { $0.name == Self.whisperModelName }
    }

    private func isWhisperTurboDownloaded(_ manager: WhisperModelManager) -> Bool {
        manager.availableModels.contains { $0.name == Self.whisperModelName }
    }

    private func switchStarterModesToWhisper() {
        guard !defaults.bool(forKey: Self.switchDoneKey) else { return }

        let manager = ModeManager.shared
        var switched = 0
        for config in manager.configurations
        where StarterModeCatalog.ids.contains(config.id)
            && (config.selectedTranscriptionModelName == nil
                || config.selectedTranscriptionModelName == Self.parakeetModelName)
        {
            var updated = config
            updated.selectedTranscriptionModelName = Self.whisperModelName
            updated.selectedLanguage = Self.language
            manager.updateConfiguration(updated)
            switched += 1
        }

        defaults.set(Self.language, forKey: "SelectedLanguage")
        defaults.set(true, forKey: Self.switchDoneKey)
        logger.notice("Switched \(switched, privacy: .public) starter modes to Whisper Turbo (nl)")
    }
}
