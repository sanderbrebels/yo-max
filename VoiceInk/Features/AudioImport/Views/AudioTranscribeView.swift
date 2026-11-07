import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct AudioTranscribeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var engine: VoiceInkEngine
    @ObservedObject private var modeManager = ModeManager.shared
    @StateObject private var transcriptionManager = AudioTranscriptionManager.shared
    @State private var isDropTargeted = false
    @State private var showModePopover = false
    @State private var expandedItemId: UUID?

    private var selectedMode: ModeConfig? {
        modeManager.currentEffectiveConfiguration
    }

    var body: some View {
        Group {
            if transcriptionManager.queue.isEmpty {
                emptyStateView
            } else {
                queueFormView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrop(of: [.fileURL, .data, .audio, .movie], isTargeted: $isDropTargeted) { providers in
            handleDroppedFiles(providers)
            return true
        }
        .overlay {
            if isDropTargeted && !transcriptionManager.queue.isEmpty {
                dropOverlay
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openFileForTranscription)) { notification in
            if let url = notification.userInfo?["url"] as? URL {
                transcriptionManager.addToQueue(urls: [url])
            }
        }
        .onChange(of: transcriptionManager.lastCompletedItemId) { _, newId in
            if let newId {
                withAnimation(.easeInOut(duration: 0.3)) {
                    expandedItemId = newId
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Surface.window.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 2, dash: [8])
                            )
                            .foregroundColor(isDropTargeted ? AppTheme.Accent.primary : .gray.opacity(0.5))
                    )
                    .animation(.easeInOut(duration: 0.15), value: isDropTargeted)

                VStack(spacing: 14) {
                    Image(yoMax: "arrow.down.doc")
                        .font(.yoMax(32))
                        .foregroundColor(isDropTargeted ? AppTheme.Accent.primary : .gray)

                    Text("Drop audio or video files here")
                        .font(.yoMax(13, weight: .medium))

                    Text("or")
                        .foregroundColor(AppTheme.Text.secondary)

                    Button("Choose Files") {
                        selectFiles()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(32)
            }
            .frame(maxWidth: 480, maxHeight: 200)

            Text("Supports WAV, MP3, M4A, AIFF, MP4, MOV, AAC, FLAC, CAF, AMR, OGG, OPUS, 3GP")
                .font(.yoMax(10))
                .foregroundColor(AppTheme.Text.secondary)
                .padding(.top, 12)

            Spacer()
        }
        .padding()
    }

    // MARK: - Queue Form View

    private var queueFormView: some View {
        VStack(spacing: 0) {
            topBar
            Divider()

            Form {
                ForEach(transcriptionManager.queue) { item in
                    Section {
                        AudioFileRow(
                            item: item,
                            isExpanded: expandedItemId == item.id,
                            onToggleExpand: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    expandedItemId = expandedItemId == item.id ? nil : item.id
                                }
                            },
                            onRemove: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    transcriptionManager.removeFromQueue(id: item.id)
                                    if expandedItemId == item.id { expandedItemId = nil }
                                }
                            },
                            onRetry: {
                                transcriptionManager.retryItem(id: item.id)
                                startProcessing()
                            }
                        )
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .safeAreaInset(edge: .bottom) {
                Text("Drop files anywhere to add more")
                    .font(.yoMax(10))
                    .foregroundColor(AppTheme.Text.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 10) {
            let count = transcriptionManager.queue.count
            Text(String(localized: "\(count) files"))
                .font(.yoMax(11))
                .foregroundColor(AppTheme.Text.secondary)

            Button {
                selectFiles()
            } label: {
                HStack(spacing: 4) {
                    Image(yoMax: "plus")
                        .font(.yoMax(12, weight: .medium))
                    Text("Add")
                        .font(.yoMax(12, weight: .medium))
                }
                .foregroundColor(AppTheme.Text.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(AppTheme.Surface.controlActive)
                )
            }
            .buttonStyle(.plain)
            .help("Add files")

            Spacer()

            modePicker

            if transcriptionManager.isProcessingQueue {
                Button {
                    transcriptionManager.cancelProcessing()
                } label: {
                    HStack(spacing: 4) {
                        Image(yoMax: "stop.fill")
                            .font(.yoMax(10, weight: .medium))
                        Text("Cancel")
                            .font(.yoMax(12, weight: .medium))
                    }
                    .foregroundColor(AppTheme.Status.error)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(AppTheme.Status.error.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
                .help("Cancel transcription")
            } else if transcriptionManager.hasPendingItems {
                Button {
                    startProcessing()
                } label: {
                    HStack(spacing: 4) {
                        Image(yoMax: "play.fill")
                            .font(.yoMax(10, weight: .medium))
                        Text("Start")
                            .font(.yoMax(12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AppTheme.Accent.primary)
                            .shadow(color: AppTheme.Accent.shadow, radius: 2, x: 0, y: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(selectedMode == nil)
                .opacity(selectedMode == nil ? 0.5 : 1.0)
                .help(selectedMode == nil ? "Select an enabled mode to start" : "Start transcription")
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    transcriptionManager.clearAll()
                    expandedItemId = nil
                }
            } label: {
                HStack(spacing: 4) {
                    Image(yoMax: "xmark.bin")
                        .font(.yoMax(12, weight: .medium))
                    Text("Clear")
                        .font(.yoMax(12, weight: .medium))
                }
                .foregroundColor(AppTheme.Text.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(AppTheme.Surface.controlActive)
                )
            }
            .buttonStyle(.plain)
            .help("Clear all items")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
    }

    private var modePicker: some View {
        HStack(spacing: 6) {
            Text("Mode")
                .font(.yoMax(12, weight: .semibold))
                .foregroundColor(AppTheme.Text.secondary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            if modeManager.enabledConfigurations.isEmpty {
                Text("None")
                    .font(.yoMax(12, weight: .medium))
                    .foregroundColor(AppTheme.Text.secondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            } else if let selectedMode {
                Button {
                    showModePopover.toggle()
                } label: {
                    HStack(spacing: 6) {
                        ModeIconView(icon: selectedMode.icon, size: selectedMode.icon.kind == .emoji ? 13 : 11)
                            .frame(width: 16)
                        Text(selectedMode.name)
                            .font(.yoMax(12, weight: .medium))
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Image(yoMax: "chevron.up.chevron.down")
                            .font(.yoMax(9, weight: .semibold))
                            .foregroundColor(AppTheme.Text.secondary)
                    }
                    .foregroundColor(AppTheme.Text.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .frame(maxWidth: 160, alignment: .leading)
                    .background(
                        Capsule()
                            .fill(AppTheme.Surface.subtle)
                    )
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.Accent.fillSubtle, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showModePopover, arrowEdge: .bottom) {
                    ModePopover(selectedModeId: selectedMode.id) { mode in
                        selectMode(mode)
                    }
                }
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    private func selectMode(_ mode: ModeConfig) {
        modeManager.setActiveConfiguration(mode)
        showModePopover = false
    }

    private func startProcessing() {
        guard let selectedMode else { return }
        transcriptionManager.startProcessing(modelContext: modelContext, engine: engine, mode: selectedMode)
    }

    // MARK: - Drop Overlay

    private var dropOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(AppTheme.Accent.primary, style: StrokeStyle(lineWidth: 2, dash: [8]))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Accent.fillSubtle)
            )
            .overlay {
                Text("Drop to add files")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(AppTheme.Accent.primary)
            }
            .padding(16)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.15), value: isDropTargeted)
    }

    // MARK: - File Handling

    private func selectFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.audio, .movie]

        if panel.runModal() == .OK {
            transcriptionManager.addToQueue(urls: panel.urls)
        }
    }

    private func handleDroppedFiles(_ providers: [NSItemProvider]) {
        let typeIdentifiers = [
            UTType.fileURL.identifier,
            UTType.audio.identifier,
            UTType.movie.identifier,
            UTType.data.identifier,
            "public.file-url",
        ]

        for provider in providers {
            for typeIdentifier in typeIdentifiers {
                if provider.hasItemConformingToTypeIdentifier(typeIdentifier) {
                    provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { item, error in
                        if let error = error {
                            print("Error loading dropped file: \(error)")
                            return
                        }

                        var fileURL: URL?

                        if let url = item as? URL {
                            fileURL = url
                        } else if let data = item as? Data {
                            if let url = URL(dataRepresentation: data, relativeTo: nil) {
                                fileURL = url
                            } else if let urlString = String(data: data, encoding: .utf8),
                                let url = URL(string: urlString)
                            {
                                fileURL = url
                            }
                        } else if let urlString = item as? String {
                            fileURL = URL(string: urlString)
                        }

                        if let finalURL = fileURL {
                            DispatchQueue.main.async {
                                self.transcriptionManager.addToQueue(urls: [finalURL])
                            }
                        }
                    }
                    break
                }
            }
        }
    }
}
