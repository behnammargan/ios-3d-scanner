import Foundation
import RealityKit
import SwiftUI
import Combine

/// State of the scanning and photogrammetry process
enum AppScanState {
    case ready
    case scanning
    case finishingScan
    case reconstructing(progress: Double)
    case completed(modelURL: URL)
    case failed(message: String)
}

@MainActor
class CaptureModel: ObservableObject {
    @Published var scanState: AppScanState = .ready
    @Published var session: ObjectCaptureSession?
    @Published var reconstructionProgress: Double = 0.0

    private var scanDirectory: URL?
    private var imagesDirectory: URL?
    private var outputModelURL: URL?
    private var cancellables = Set<AnyCancellable>()
    private var photogrammetrySession: PhotogrammetrySession?

    init() {
        checkSupport()
    }

    /// Check if this device supports ObjectCaptureSession (LiDAR / Neural Engine)
    var isSupported: Bool {
        ObjectCaptureSession.isSupported
    }

    private func checkSupport() {
        if !isSupported {
            scanState = .failed(message: "Object Capture requires a device with LiDAR and A14 Bionic or newer.")
        }
    }

    /// Prepares local directories and begins a new scanning session
    func startNewScan() {
        guard isSupported else { return }

        // Create a unique temporary directory for this scan
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let scanFolder = docDir.appendingPathComponent("Scan_\(timestamp)", isDirectory: true)
        let imagesFolder = scanFolder.appendingPathComponent("Images", isDirectory: true)
        let modelFile = scanFolder.appendingPathComponent("model.usdz")

        do {
            try FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true)
            self.scanDirectory = scanFolder
            self.imagesDirectory = imagesFolder
            self.outputModelURL = modelFile
        } catch {
            scanState = .failed(message: "Failed to create capture directory: \(error.localizedDescription)")
            return
        }

        // Initialize ObjectCaptureSession
        let newSession = ObjectCaptureSession()
        self.session = newSession

        // Observe session state
        observeSession(newSession)

        // Start capture into the images directory
        newSession.start(imagesDirectory: imagesFolder)
        scanState = .scanning
    }

    private func observeSession(_ session: ObjectCaptureSession) {
        cancellables.removeAll()

        session.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .completed:
                    self.finishScanningAndReconstruct()
                case .failed(let error):
                    self.scanState = .failed(message: "Capture session error: \(error.localizedDescription)")
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    /// Signals the capture session to finalize photos and start 3D reconstruction
    func userRequestsFinish() {
        guard let session = session, session.state == .capturing else { return }
        scanState = .finishingScan
        session.finish()
    }

    /// Cancels the scan and cleans up resources
    func cancelScan() {
        session?.cancel()
        session = nil
        photogrammetrySession?.cancel()
        photogrammetrySession = nil
        scanState = .ready
    }

    /// Runs on-device photogrammetry to turn captured photos/depth into USDZ model
    private func finishScanningAndReconstruct() {
        guard let imagesDir = imagesDirectory, let outputURL = outputModelURL else {
            scanState = .failed(message: "Missing image directory for reconstruction.")
            return
        }

        scanState = .reconstructing(progress: 0.0)

        Task {
            do {
                // Configure PhotogrammetrySession with on-device detail
                var configuration = PhotogrammetrySession.Configuration()
                configuration.isObjectMaskingEnabled = true

                let pSession = try PhotogrammetrySession(input: imagesDir, configuration: configuration)
                self.photogrammetrySession = pSession

                // Request USDZ generation at reduced or medium detail for on-device speed
                try pSession.process(requests: [
                    .modelFile(url: outputURL, detail: .reduced)
                ])

                for try await output in pSession.outputs {
                    switch output {
                    case .requestProgress(_, let fractionComplete):
                        await MainActor.run {
                            self.reconstructionProgress = fractionComplete
                            self.scanState = .reconstructing(progress: fractionComplete)
                        }
                    case .requestComplete(_, _):
                        await MainActor.run {
                            self.scanState = .completed(modelURL: outputURL)
                        }
                    case .requestError(_, let error):
                        await MainActor.run {
                            self.scanState = .failed(message: "Reconstruction error: \(error.localizedDescription)")
                        }
                    case .processingComplete:
                        break
                    default:
                        break
                    }
                }
            } catch {
                await MainActor.run {
                    self.scanState = .failed(message: "Failed to generate 3D model: \(error.localizedDescription)")
                }
            }
        }
    }
}
