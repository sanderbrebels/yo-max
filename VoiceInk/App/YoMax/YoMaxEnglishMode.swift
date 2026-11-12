import Carbon.HIToolbox
import Foundation
import os

/// Yo Max: an "English" mode for dictating whole English sentences.
///
/// The default mode transcribes with Whisper fixed to Dutch (`nl`), which turns English speech
/// into Dutch. This mode uses Whisper in English (`en`) and the "English" cleanup prompt, which
/// never translates. It gets its own shortcut (right Option by default), so fn stays Dutch.
///
/// Runs once: an existing mode called "English" is reused, otherwise a new one is created.
/// Afterwards the user's own changes (language, prompt, shortcut) are respected.
@MainActor
enum YoMaxEnglishMode {
    static let modeId = UUID(uuidString: "10000000-0000-0000-0000-0000000000E1")!
    static let name = "English"
    static let language = "en"
    static let setupDoneKey = "YoMaxDidSetUpEnglishMode"

    static var defaultShortcut: Shortcut {
        .modifierOnly(keyCode: UInt16(kVK_RightOption), modifierFlags: [.option])
    }

    private static let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "YoMaxEnglishMode")

    static func setUpIfNeeded(defaults: UserDefaults = .standard) {
        guard defaults.bool(forKey: OnboardingSettings.completedV2Key) else { return }
        guard !defaults.bool(forKey: setupDoneKey) else { return }

        let manager = ModeManager.shared
        let base = manager.getDefaultConfiguration()

        let existing =
            manager.getConfiguration(with: modeId)
            ?? manager.configurations.first {
                $0.name.trimmingCharacters(in: .whitespaces).caseInsensitiveCompare(name) == .orderedSame
            }

        var config =
            existing
            ?? ModeConfig(
                id: modeId,
                name: name,
                icon: .symbol("globe"),
                isAIEnhancementEnabled: true,
                isEnabled: true,
                isDefault: false
            )

        config.selectedLanguage = language
        config.isAIEnhancementEnabled = true
        config.selectedPrompt = PromptTemplates.englishPromptId.uuidString
        config.isEnabled = true
        if config.selectedTranscriptionModelName == nil || config.selectedTranscriptionModelName?.isEmpty == true {
            config.selectedTranscriptionModelName =
                base?.selectedTranscriptionModelName ?? YoMaxDefaults.whisperModelName
        }
        // Same AI provider and model as the everyday (default) mode.
        if let base, base.id != config.id {
            config.selectedAIProvider = base.selectedAIProvider
            config.selectedAIModel = base.selectedAIModel
            config.isTextFormattingEnabled = base.isTextFormattingEnabled
            config.useScreenCapture = false
        }

        if existing == nil {
            manager.addConfiguration(config)
        } else {
            manager.updateConfiguration(config)
        }

        let action = ShortcutAction.mode(config.id)
        if ShortcutStore.shortcut(for: action) == nil {
            ShortcutStore.setShortcut(defaultShortcut, for: action)
        }

        defaults.set(true, forKey: setupDoneKey)
        let shortcut = ShortcutStore.shortcut(for: action)?.displayString ?? "none"
        logger.notice(
            "English mode ready (reused=\(existing != nil, privacy: .public)) shortcut=\(shortcut, privacy: .public)"
        )
    }
}
