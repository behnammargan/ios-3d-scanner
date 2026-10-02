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

                // State indicator & actions
                VStack(spacing: 16) {
                    switch model.scanState {
                    case .scanning:
                        Button(action: {
                            model.userRequestsFinish()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Finish & Process")
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .shadow(radius: 6)
                        }

                    case .finishingScan:
                        HStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Finalizing capture frames...")
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(16)

                    case .reconstructing(let progress):
                        VStack(spacing: 8) {
                            Text("Reconstructing 3D Mesh (\(Int(progress * 100))%)")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                            ProgressView(value: progress)
                                .accentColor(.green)
                                .frame(width: 200)
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(16)

                    case .failed(let message):
                        VStack(spacing: 8) {
                            Text("Scanning Failed")
                                .font(.headline)
                                .foregroundColor(.red)
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Button("Dismiss") {
                                model.cancelScan()
                                dismiss()
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(16)
                        .padding(.horizontal, 32)

                    default:
                        EmptyView()
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}
