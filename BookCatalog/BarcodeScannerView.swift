import AVFoundation
import SwiftUI
import UIKit

struct BarcodeScannerView: View {
    let onISBNScanned: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var authorization = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var message: String?

    var body: some View {
        Group {
            switch authorization {
            case .authorized:
                ZStack {
                    CameraPreview(
                        onISBNScanned: onISBNScanned,
                        onUnsupportedBarcode: {
                            message = "That barcode is not a supported ISBN-13."
                        },
                        onConfigurationError: {
                            message = "The camera could not be configured for scanning."
                        }
                    )
                    .ignoresSafeArea()

                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white, lineWidth: 3)
                        .frame(width: 280, height: 160)
                        .accessibilityHidden(true)

                    VStack {
                        Spacer()
                        Text("Point your camera at an ISBN barcode.")
                            .font(.headline)
                            .padding()
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.bottom, 44)
                    }
                }
            case .notDetermined:
                ProgressView("Requesting camera access…")
            case .denied, .restricted:
                ContentUnavailableView {
                    Label("Camera access is needed", systemImage: "camera.fill")
                } description: {
                    Text("Allow camera access in Settings to scan an ISBN barcode.")
                } actions: {
                    Button("Open Settings") {
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(settingsURL)
                    }
                    .buttonStyle(.borderedProminent)
                }
            @unknown default:
                ContentUnavailableView("Camera unavailable", systemImage: "camera.fill")
            }
        }
        .navigationTitle("Scan book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .task {
            await requestCameraAccessIfNeeded()
        }
        .alert("Scanning", isPresented: showsMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message ?? "")
        }
    }

    private var showsMessage: Binding<Bool> {
        Binding(get: { message != nil }, set: { if !$0 { message = nil } })
    }

    private func requestCameraAccessIfNeeded() async {
        guard authorization == .notDetermined else { return }
        authorization = await AVCaptureDevice.requestAccess(for: .video) ? .authorized : .denied
    }
}

private struct CameraPreview: UIViewRepresentable {
    let onISBNScanned: (String) -> Void
    let onUnsupportedBarcode: () -> Void
    let onConfigurationError: () -> Void

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        context.coordinator.configure(in: view)
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}

    static func dismantleUIView(_ uiView: CameraPreviewUIView, coordinator: Coordinator) {
        coordinator.stopScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onISBNScanned: onISBNScanned,
            onUnsupportedBarcode: onUnsupportedBarcode,
            onConfigurationError: onConfigurationError
        )
    }

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        private let session = AVCaptureSession()
        private let onISBNScanned: (String) -> Void
        private let onUnsupportedBarcode: () -> Void
        private let onConfigurationError: () -> Void
        private var hasScannedISBN = false

        init(
            onISBNScanned: @escaping (String) -> Void,
            onUnsupportedBarcode: @escaping () -> Void,
            onConfigurationError: @escaping () -> Void
        ) {
            self.onISBNScanned = onISBNScanned
            self.onUnsupportedBarcode = onUnsupportedBarcode
            self.onConfigurationError = onConfigurationError
        }

        func configure(in view: CameraPreviewUIView) {
            guard let camera = AVCaptureDevice.default(for: .video) else {
                onConfigurationError()
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: camera)
                let output = AVCaptureMetadataOutput()

                guard session.canAddInput(input), session.canAddOutput(output) else {
                    onConfigurationError()
                    return
                }

                session.addInput(input)
                session.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: .main)
                guard output.availableMetadataObjectTypes.contains(.ean13) else {
                    onConfigurationError()
                    return
                }
                output.metadataObjectTypes = [.ean13]
                view.previewLayer.session = session
                session.startRunning()
            } catch {
                onConfigurationError()
            }
        }

        func stopScanning() {
            session.stopRunning()
        }

        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard !hasScannedISBN,
                  let code = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let value = code.stringValue
            else {
                return
            }

            guard let isbn = ISBNBarcodeValidator.isbn(from: value) else {
                onUnsupportedBarcode()
                return
            }

            hasScannedISBN = true
            session.stopRunning()
            onISBNScanned(isbn)
        }
    }
}

private final class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        previewLayer.videoGravity = .resizeAspectFill
    }
}
