import AVFoundation
import SwiftUI

// MARK: - UIImagePickerController wrapper (camera + photo library)

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onImagePicked: onImagePicked) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        init(onImagePicked: @escaping (UIImage) -> Void) { self.onImagePicked = onImagePicked }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - CameraScreen

struct CameraScreen: View {
    var appVM: AppViewModel

    @State private var cameraAuthorized = false
    @State private var cameraDenied = false
    @State private var showCamera = false
    @State private var checkDone = false

    var body: some View {
        Group {
            if !checkDone {
                ProgressView("Checking camera access…")
            } else if cameraDenied {
                deniedView
            } else {
                readyView
            }
        }
        .navigationTitle("Camera")
        .navigationBarTitleDisplayMode(.inline)
        .task { await checkPermission() }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                appVM.navigateToResult(with: image)
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Subviews

    private var readyView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("Ready to scan")
                .font(.title3)
                .foregroundStyle(.secondary)
            Button {
                showCamera = true
            } label: {
                Label("Open Camera", systemImage: "camera.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 40)
            Spacer()
        }
    }

    private var deniedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "camera.badge.ellipsis")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("Camera Access Required")
                .font(.title3.bold())
            Text("This app needs camera access to scan items. Please enable it in Settings.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }

    // MARK: - Permission check

    private func checkPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            cameraAuthorized = true
            cameraDenied = false
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            cameraAuthorized = granted
            cameraDenied = !granted
        default:
            cameraAuthorized = false
            cameraDenied = true
        }
        checkDone = true
        if cameraAuthorized {
            showCamera = true
        }
    }
}
