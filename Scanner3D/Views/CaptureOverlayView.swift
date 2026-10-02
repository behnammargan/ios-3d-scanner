import SwiftUI
import RealityKit

struct CaptureOverlayView: View {
    @ObservedObject var model: CaptureModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            if let session = model.session {
                // Official Apple AR guidance & camera viewport for 3D capture
                ObjectCaptureView(session: session)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }

            // Overlay controls
            VStack {
                // Top Cancel bar
                HStack {
                    Button(action: {
                        model.cancelScan()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                    .padding()

                    Spacer()
                }

                Spacer()

                // Bottom State Controls
                VStack(spacing: 14) {
                    switch model.scanState {
                    case .scanning:
                        scanningControls

                    case .finishingScan:
                        HStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Saving captured scan frames...")
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(16)

                    case .reconstructing(let progress):
                        VStack(spacing: 10) {
                            Text("Reconstructing 3D Model (\(Int(progress * 100))%)")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            ProgressView(value: progress)
                                .accentColor(.green)
                                .frame(width: 220)
                            Text("Generating mesh, LiDAR depth & textures...")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(18)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(18)

                    case .failed(let message):
                        VStack(spacing: 10) {
                            Text("Notice")
                                .font(.headline)
                                .foregroundColor(.orange)
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Button("Try Again") {
                                model.cancelScan()
                                dismiss()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color.black.opacity(0.9))
                        .cornerRadius(16)
                        .padding(.horizontal, 32)

                    default:
                        EmptyView()
                    }
                }
                .padding(.bottom, 44)
            }
        }
    }

    @ViewBuilder
    private var scanningControls: some View {
        switch model.sessionState {
        case .initializing:
            HStack(spacing: 10) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Text("Initializing LiDAR & Camera...")
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(14)

        case .ready:
            VStack(spacing: 8) {
                Text("Point camera at your object on a table")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)

                Button(action: {
                    model.startDetecting()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "viewfinder")
                        Text("1. Set 3D Box")
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(radius: 6)
                }
            }

        case .detecting:
            VStack(spacing: 8) {
                Text("Box detected! Tap to begin scanning")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)

                Button(action: {
                    model.startCapturing()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "record.circle")
                        Text("2. Start 3D Scan")
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(radius: 6)
                }
            }

        case .capturing:
            VStack(spacing: 8) {
                Text("Walk slowly around the object in a circle")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)

                Button(action: {
                    model.userRequestsFinish()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("3. Finish & Build 3D Model")
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(radius: 6)
                }
            }

        default:
            Button(action: {
                model.userRequestsFinish()
            }) {
                Text("Finish")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
    }
}
