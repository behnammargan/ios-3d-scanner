import SwiftUI

struct ScannedItem: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    let date: Date
}

struct IdentifiableURL: Identifiable {
    var id: String { url.absoluteString }
    let url: URL
}

struct ContentView: View {
    @StateObject private var model = CaptureModel()
    @State private var isScanning = false
    @State private var previewItem: IdentifiableURL?
    @State private var pastScans: [ScannedItem] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header card
                VStack(spacing: 8) {
                    Image(systemName: "cube.transparent")
                        .font(.system(size: 56))
                        .foregroundColor(.blue)

                    Text("LiDAR 3D Scanner")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Scan real-world objects into high-detail 3D USDZ models directly on your iPhone.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                // Start Scan Button
                Button(action: {
                    model.startNewScan()
                    isScanning = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.title2)
                        Text("Start New 3D Scan")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .disabled(!model.isSupported)

                if !model.isSupported {
                    Text("⚠️ This feature requires an iPhone with LiDAR (iPhone 12 Pro or newer).")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Scanned Models Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Saved 3D Scans")
                        .font(.headline)
                        .padding(.horizontal, 24)

                    if pastScans.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary)
                            Text("No 3D scans yet. Tap 'Start New 3D Scan' to begin!")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                    } else {
                        List {
                            ForEach(pastScans) { item in
                                Button(action: {
                                    previewItem = IdentifiableURL(url: item.url)
                                }) {
                                    HStack {
                                        Image(systemName: "arkit")
                                            .foregroundColor(.blue)
                                        VStack(alignment: .leading) {
                                            Text(item.name)
                                                .font(.body)
                                                .fontWeight(.medium)
                                            Text(item.date, style: .date)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .onDelete(perform: deleteScan)
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }

                Spacer()
            }
            .navigationTitle("Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadSavedScans)
            .fullScreenCover(isPresented: $isScanning) {
                CaptureOverlayView(model: model)
            }
            .sheet(item: $previewItem) { item in
                ModelPreviewView(modelURL: item.url)
            }
            .onChange(of: model.scanState) { _, newState in
                if case .completed(let url) = newState {
                    isScanning = false
                    previewItem = IdentifiableURL(url: url)
                    loadSavedScans()
                }
            }
        }
    }

    private func loadSavedScans() {
        let fileManager = FileManager.default
        guard let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        do {
            let folders = try fileManager.contentsOfDirectory(at: docDir, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles)
            var items: [ScannedItem] = []

            for folder in folders where folder.hasDirectoryPath {
                let modelFile = folder.appendingPathComponent("model.usdz")
                if fileManager.fileExists(atPath: modelFile.path) {
                    let attrs = try? fileManager.attributesOfItem(atPath: modelFile.path)
                    let modDate = attrs?[.modificationDate] as? Date ?? Date()
                    items.append(ScannedItem(name: folder.lastPathComponent, url: modelFile, date: modDate))
                }
            }
            self.pastScans = items.sorted(by: { $0.date > $1.date })
        } catch {
            print("Error loading scans: \(error)")
        }
    }

    private func deleteScan(at offsets: IndexSet) {
        let fileManager = FileManager.default
        for index in offsets {
            let item = pastScans[index]
            let parentFolder = item.url.deletingLastPathComponent()
            try? fileManager.removeItem(at: parentFolder)
        }
        pastScans.remove(atOffsets: offsets)
    }
}
