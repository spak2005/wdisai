import SwiftUI

struct HomeScreen: View {
    var appVM: AppViewModel
    @State private var showPhotoPicker = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "eye.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.accent)

            VStack(spacing: 8) {
                Text("What Do I See AI?")
                    .font(.largeTitle.bold())

                Text("Snap an item. Get a description.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 14) {
                Button {
                    appVM.navigateToCamera()
                } label: {
                    Label("Scan Item", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    showPhotoPicker = true
                } label: {
                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal, 24)

            Text("Your photo is sent to OpenAI to generate a description.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)
        }
        .sheet(isPresented: $showPhotoPicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                appVM.navigateToResult(with: image)
            }
            .ignoresSafeArea()
        }
    }
}
